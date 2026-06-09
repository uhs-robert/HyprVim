-- whichkey/lib/items.lua
-- Builds HUD item JSON arrays for marks, registers, and generic submaps.

local dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)") or "./"
local root = dir .. "../../"
package.path = root .. "?.lua;" .. root .. "?/init.lua;" .. package.path

local Utils = require("lib.utils") ---@class HyprVimUtils
local file_exists = Utils.file_exists
local write_file = Utils.write_file
local pread = Utils.pread
local sh_escape = Utils.sh_escape

local Config = require("config") ---@class HyprVimConfigModule
local Hyprctl = require("whichkey.lib.hyprctl") ---@class HyprCtl

--- @class Items
local Items = {}

-- TODO: build_mark_items exists because hl.bind descriptions cannot be updated or removed
-- per-submap once registered; only hl.unbind exists and it is global. So whichkey reads
-- marks.json directly instead of relying on hyprctl bind descriptions.
-- If Hyprland gains per-submap unbind:
--   - Remove build_mark_items entirely; MARKS/SET-MARK/DELETE-MARK fall through to
--     Hyprctl.build_items like every other submap.
--   - In vim-marks.lua refresh callback, replace the no-op overwrite pattern with
--     hl.unbind calls for deleted mark keys so binds are cleanly removed.
-- Track: https://github.com/hyprwm/Hyprland/discussions/15040
--- @param sm string
--- @return string|nil
function Items.build_mark_items(sm)
  local marks_file = Config.state_dir .. "/marks.json"
  if sm ~= "MARKS" and sm ~= "SET-MARK" and sm ~= "DELETE-MARK" then return nil end

  local marks_jq = 'to_entries | map(select(.value | type == "object")) | map({'
    .. 'key:.key, desc:((.value.class // "?") + '
    .. '(if ((.value.title // "") | length) > 0 then " \\u00b7 " + (.value.title | .[0:20]) else "" end) + '
    .. '" [ws:" + (.value.workspace | tostring) + "]"), class:""}) | '
    .. 'sort_by(if (.key | test("^[a-z]$")) then [0,.key] elif (.key | test("^[A-Z]$")) then [1,.key] else [2,.key] end)'

  -- SET-MARK: show occupied slots; fall through to hyprctl when none so all slots appear.
  if sm == "SET-MARK" then
    if not file_exists(marks_file) then return nil end
    local result = pread("jq -c '" .. marks_jq .. "' " .. sh_escape(marks_file) .. " 2>/dev/null")
    if result == "" or result == "[]" or result == "null" then return nil end
    return result
  end

  -- MARKS / DELETE-MARK: always return a result (never fall through to hyprctl so stale
  -- hl.bind descriptions never leak into the HUD as ghost entries).
  local static_items
  if sm == "DELETE-MARK" then
    static_items = '[{"key":"DELETE","desc":"Clear all marks","class":""},{"key":"ESCAPE","desc":"Exit","class":""}]'
  else
    static_items = '[{"key":"ESCAPE","desc":"Exit","class":""}]'
  end

  if not file_exists(marks_file) then return static_items end

  local result =
    pread("jq -c '(" .. marks_jq .. ") + " .. static_items .. "' " .. sh_escape(marks_file) .. " 2>/dev/null")
  if result == "" or result == "null" then return static_items end
  return result
end

--- @param sm string
--- @return string|nil
function Items.build_register_items(sm)
  if sm ~= "REGISTERS" then return nil end
  local reg_dir = Config.state_dir .. "/registers"
  if not file_exists(reg_dir) then return nil end

  local function reg_read(path)
    local f = io.open(path, "r")
    if not f then return "" end
    local s = (f:read(40) or ""):gsub("[\n\t]", " "):gsub("%s+$", "")
    f:close()
    return s
  end

  local function make_item(key, prefix, content)
    if content == "" then return nil end
    local desc = prefix ~= "" and ("[" .. prefix .. "] " .. content) or content
    if #desc > 45 then desc = desc:sub(1, 42) .. "..." end
    return pread(
      "jq -cn --arg k " .. sh_escape(key) .. " --arg d " .. sh_escape(desc) .. " '{key:$k,desc:$d,class:\"\"}'"
    )
  end

  local items = {}
  local function add(k, p, path)
    local item = make_item(k, p, reg_read(path))
    if item and item ~= "" then items[#items + 1] = item end
  end

  local function trim(s) return s:gsub("[\n\t\r]", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "") end

  local pre_vim_path = Config.state_dir .. "/clipboard_pre_vim"
  if file_exists(pre_vim_path) then
    local f = io.open(pre_vim_path, "r")
    local content = trim(f and (f:read(50) or "") or "")
    if f then f:close() end
    local item = make_item("PLUS", "system", content)
    if item and item ~= "" then items[#items + 1] = item end
  end

  local primary = trim(pread("wl-paste --primary --no-newline 2>/dev/null"))
  local primary_item = make_item("ASTERISK", "primary", primary)
  if primary_item and primary_item ~= "" then items[#items + 1] = primary_item end

  add('"', "default", reg_dir .. '/"')
  add("0", "yank", reg_dir .. "/0")
  for _, n in ipairs({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }) do
    add(n, "del", reg_dir .. "/" .. n)
  end
  for c in ("abcdefghijklmnopqrstuvwxyz"):gmatch(".") do
    add(c, "", reg_dir .. "/" .. c)
  end

  local find_state = Config.state_dir .. "/find-state.json"
  if file_exists(find_state) then
    local term = pread("jq -r '.find_term // \"\"' " .. sh_escape(find_state) .. " 2>/dev/null")
    local item = make_item("/", "search", term)
    if item and item ~= "" then items[#items + 1] = item end
  end

  if #items == 0 then return nil end
  return "[" .. table.concat(items, ",") .. "]"
end

--- Fetches HUD items for submap, writes them to a temp file, and retries once on empty.
--- Returns items JSON, temp file path, and item count. Count 0 means nothing to show.
--- @param submap string
--- @return string items_json, string items_tmp, integer count
function Items.resolve(submap)
  local function fetch()
    return Items.build_mark_items(submap) or Items.build_register_items(submap) or Hyprctl.build_items(submap) or "[]"
  end
  local tmp = Config.state_dir .. "/whichkey-items." .. tostring(math.random(1e9))
  local items = fetch()
  write_file(tmp, items)
  local count = tonumber(pread("jq -c 'length' " .. sh_escape(tmp) .. " 2>/dev/null")) or 0
  if count == 0 then
    -- Retry once hyprctl binds may lag submap transitions
    os.execute("sleep 0.02")
    items = fetch()
    write_file(tmp, items)
    count = tonumber(pread("jq -c 'length' " .. sh_escape(tmp) .. " 2>/dev/null")) or 0
  end
  if count == 0 then os.remove(tmp) end
  return items, tmp, count
end

return Items
