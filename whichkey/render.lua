#!/usr/bin/env lua
-- whichkey/render.lua

local script_path = debug.getinfo(1, "S").source:sub(2)
local dir = script_path:match("(.*/)") or "./"
local root = dir .. "../"
package.path = root .. "?.lua;" .. root .. "?/init.lua;" .. package.path

math.randomseed(os.time())

local Utils = require("lib.utils") ---@class HyprVimUtils
local read_file = Utils.read_file
local write_file = Utils.write_file
local file_exists = Utils.file_exists
local pread = Utils.pread
local sh_escape = Utils.sh_escape

local Eww = require("whichkey.lib.eww") ---@class Eww
local Items = require("whichkey.lib.items") ---@class Items
local Config = require("config") ---@class HyprVimConfigModule

--- @class Render
local Render = {}

Render.state_dir = Config.state_dir or ((os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hyprvim")
Render.eww_dir = Eww.dir
Render.position = (Config.which_key and Config.which_key.position) or "bottom-right"

os.execute("mkdir -p '" .. Render.state_dir .. "'")

--- Returns true if submap is still the active one (or is GLOBAL).
--- Reads current-submap state file; used to abort stale HUD renders.
--- @param submap string
--- @return boolean
local function is_submap_active(submap)
  if submap == "GLOBAL" then return true end
  return read_file(Render.state_dir .. "/current-submap") == submap
end

local POSITIONS = Eww.POSITIONS

--- Close HUD and return true (for use as `if close_if(cond) then return end`).
--- @param cond boolean
--- @return boolean
local function close_if(cond)
  if cond then Render.close() end
  return cond
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Hide the HUD and clear the visible state file.
function Render.close()
  local ec = "eww -c " .. sh_escape(Eww.dir)
  local parts = { ec .. " update visible=false >/dev/null 2>&1" }
  for _, pos in ipairs(POSITIONS) do
    parts[#parts + 1] = ec .. " close whichkey-" .. pos .. " >/dev/null 2>&1"
  end
  parts[#parts + 1] = "rm -f " .. sh_escape(Render.state_dir .. "/whichkey-visible")
  os.execute("(" .. table.concat(parts, "; ") .. ") &")
end

--- Toggle the HUD: close if visible, otherwise show the current submap (or GLOBAL).
function Render.toggle()
  if file_exists(Render.state_dir .. "/whichkey-visible") then
    Render.close()
    return
  end
  local current = read_file(Render.state_dir .. "/current-submap")
  local target = (current ~= "" and current ~= "reset") and current or "GLOBAL"
  local screen = pread("hyprctl -j monitors 2>/dev/null | jq -r '.[] | select(.focused) | .name' 2>/dev/null")
  Render.show(target, screen)
end

--- Write one-shot skip flag for the listener.
--- @param target string|nil  submap name to target, or nil for next submap
function Render.set_skip(target)
  local f = io.open(Render.state_dir .. "/whichkey-skip-next", "w")
  if f then f:close() end
  if target and target ~= "" then write_file(Render.state_dir .. "/whichkey-skip-target", target) end
end

--- Write one-shot delay override for the listener.
--- @param ms number  delay in milliseconds
function Render.set_delay(ms) write_file(Render.state_dir .. "/whichkey-next-delay", tostring(ms)) end

--- Render the HUD for the given submap.
--- @param submap string
--- @param screen string|nil  monitor name; queries focused monitor if omitted
function Render.show(submap, screen)
  submap = submap or ""
  screen = screen or ""

  if submap == "reset" or submap == "hide" then submap = "" end

  if submap ~= "" and submap ~= "GLOBAL" then
    if close_if(not is_submap_active(submap)) then return end
    write_file(Render.state_dir .. "/current-submap", submap)
  elseif submap == "" then
    os.execute("rm -f " .. sh_escape(Render.state_dir .. "/current-submap"))
  end

  if close_if(submap == "") then return end

  if screen == "" then
    screen = pread("hyprctl -j monitors 2>/dev/null | jq -r '.[] | select(.focused) | .name' 2>/dev/null")
  end

  local items, items_tmp, num_items = Items.resolve(submap)
  if close_if(num_items == 0) then return end

  local function jq_items(expr)
    return pread("jq -c " .. sh_escape(expr) .. " " .. sh_escape(items_tmp) .. " 2>/dev/null")
  end

  -- Monitor geometry
  local info = pread(
    "hyprctl -j monitors 2>/dev/null | jq -r --arg n "
      .. sh_escape(screen)
      .. " '.[] | select(.name == $n) | \"\\(.width)x\\(.height)x\\(.scale)\"' 2>/dev/null"
  )
  if info == "" then info = "1920x1080x1.0" end
  local pw, ph, ps = info:match("^(%d+)x(%d+)x([%d%.]+)")
  local lw = math.floor((tonumber(pw) or 1920) / (tonumber(ps) or 1))
  local lh = math.floor((tonumber(ph) or 1080) / (tonumber(ps) or 1))

  local pos = Render.position
  if not pos:find("center") and (16 + 30 + (num_items * 26) + 90) > lh * 0.8 then pos = "bottom-center" end

  local window = "whichkey-" .. pos
  local title = submap == "GLOBAL" and "Global Bindings" or submap

  Eww.run("update visible=false")
  Eww.update_layout(pos, title, items, lw, jq_items)
  os.remove(items_tmp)

  if not is_submap_active(submap) then return end

  for _, p in ipairs(POSITIONS) do
    if "whichkey-" .. p ~= window then Eww.run("close whichkey-" .. p) end
  end

  if not Eww.open_window(window, screen) then return end

  -- Final stale check: the submap may have changed while eww was opening the window.
  if not is_submap_active(submap) then
    Render.close()
    return
  end

  write_file(Render.state_dir .. "/whichkey-current-window", window)
  local vf = io.open(Render.state_dir .. "/whichkey-visible", "w")
  if vf then vf:close() end
  Eww.run("update visible=true")
end

--------------------------------------------------------------------------------
-- Script entry point (called as subprocess by whichkey-listen.lua)
--------------------------------------------------------------------------------

if arg and arg[0] and arg[0]:match("render%.lua$") then
  local argv = arg
  local cmd = argv[1] or ""

  if cmd:sub(1, 1) == "-" then
    local i = 1
    while i <= #argv do
      local a = argv[i]
      if a == "-s" or a == "--skip" then
        local target = (argv[i + 1] and argv[i + 1]:sub(1, 1) ~= "-") and argv[i + 1] or nil
        Render.set_skip(target)
        i = i + (target and 2 or 1)
      elseif a:sub(1, 7) == "--skip=" then
        Render.set_skip(a:sub(8))
        i = i + 1
      elseif a == "-d" or a == "--delay" then
        Render.set_delay(tonumber(argv[i + 1]) or 0)
        i = i + 2
      elseif a:sub(1, 8) == "--delay=" then
        Render.set_delay(tonumber(a:sub(9)) or 0)
        i = i + 1
      elseif a == "-c" or a == "--close" then
        Render.close()
        os.exit(0)
      else
        i = i + 1
      end
    end
  elseif cmd == "info" or cmd == "--info" then
    Render.toggle()
  else
    Render.show(cmd, argv[2])
  end
end

return Render
