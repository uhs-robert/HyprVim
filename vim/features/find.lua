-- vim/features/find.lua
-- f/F/t/T character search and //?/*/#  document search.
-- Find operations require a prompt dialog and clipboard interaction, so they
-- exit vim mode for input, then re-enter once the search term is submitted.

local Hypr = require("hypr") ---@class HyprVimHyprland
local Config = require("config") ---@class HyprVimConfigModule

--- @class Find
local Find = {}

---@return string  absolute path to the find state file
local function state_path() return Config.state_dir .. "/find-state.json" end

---Read the flat-string/boolean JSON state file into a table.
---@return table<string, string>
local function state_read()
  local f = io.open(state_path(), "r")
  if not f then return {} end
  local s = f:read("*a")
  f:close()
  local t = {}
  for k, v in s:gmatch('"([^"]+)"%s*:%s*"([^"]*)"') do
    t[k] = v
  end
  -- booleans stored as strings
  for k, v in s:gmatch('"([^"]+)"%s*:%s*(true)') do
    t[k] = v
  end
  for k, v in s:gmatch('"([^"]+)"%s*:%s*(false)') do
    t[k] = v
  end
  return t
end

---Serialise `t` and write it to the find state file.
---@param t table<string, string>
local function state_write(t)
  local parts = {}
  for k, v in pairs(t) do
    if v == "true" or v == "false" then
      parts[#parts + 1] = string.format('  "%s": %s', k, v)
    else
      parts[#parts + 1] = string.format('  "%s": "%s"', k, (tostring(v):gsub('"', '\\"')))
    end
  end
  table.sort(parts)
  local json = "{\n" .. table.concat(parts, ",\n") .. "\n}\n"
  local f = io.open(state_path(), "w")
  if f then
    f:write(json)
    f:close()
  end
end

---@param key     string
---@param default string|nil
---@return string
local function state_get(key, default) return state_read()[key] or default or "" end

---@param key   string
---@param value string|boolean
local function state_set(key, value)
  local t = state_read()
  t[key] = tostring(value)
  state_write(t)
end

---Show a prompt dialog and return the entered text, or nil on cancel/empty.
---@param label    string
---@param wm_class string|nil  window class for the prompt window (default `"hyprvim-find"`)
---@return string|nil
local function prompt(label, wm_class)
  wm_class = wm_class or "hyprvim-find"
  local tool = Config.applications.menu
  local cmd
  if tool == "rofi" then
    cmd = string.format(
      'rofi -dmenu -p %q -theme-str "window{width:600px;height:80px;}" -class %q 2>/dev/null',
      label,
      wm_class
    )
  else
    cmd = string.format("%s -p %q 2>/dev/null", tool, label)
  end

  local p = io.popen(cmd)
  if not p then return nil end
  local result = p:read("*a"):gsub("%s+$", "")
  p:close()
  return (result ~= "") and result or nil
end

---Write `text` to the Wayland clipboard; uses `text/plain` MIME for single characters
---to avoid triggering autocomplete in applications that inspect MIME types.
---@param text string
local function clipboard_write(text)
  local flag = (#text == 1) and "--type text/plain" or ""
  local p = io.popen("wl-copy " .. flag, "w")
  if p then
    p:write(text)
    p:close()
  end
end

---@return string  current Wayland clipboard contents, or `""` on failure
local function clipboard_read()
  local p = io.popen("wl-paste --no-newline 2>/dev/null")
  if not p then return "" end
  local s = p:read("*a") or ""
  p:close()
  return s
end

---Open the app's find bar (Ctrl+F), paste `term`, and commit the search.
---Persists all state so `n`/`N`/`;`/`,` can repeat or reverse later.
---@param term      string   search string
---@param direction string   `"forward"` or `"backward"`
---@param term_type string   state key: `"char_term"` or `"find_term"`
---@param is_till   boolean  true when called from `t`/`T` (cursor stops before match)
local function do_find(term, direction, term_type, is_till)
  state_set("active", "true")
  state_set("direction", direction)
  state_set(term_type, term)
  state_set("last_action_direction", direction)
  state_set("last_action_term_type", term_type)
  state_set("till", is_till and "true" or "false")

  clipboard_write(term)

  -- Open find bar, paste term, dismiss autocomplete, run search.
  -- Uses hl.timer chains to avoid blocking the event loop.
  Hypr.send("CTRL", "f")
  hl.timer(function()
    Hypr.send("CTRL", "v")
    hl.timer(function()
      Hypr.send("", "space")
      Hypr.send("", "BackSpace")
      hl.timer(function()
        Hypr.send("", "Return")
        Hypr.normal()
      end, { timeout = 50, type = "oneshot" })
    end, { timeout = 50, type = "oneshot" })
  end, { timeout = 150, type = "oneshot" })
end

---Exit vim mode, show the search prompt, then call `do_find` with the entered term.
---@param term_type string   `"char_term"` or `"find_term"`
---@param direction string   `"forward"` or `"backward"`
---@param is_till   boolean
local function prompt_and_find(term_type, direction, is_till)
  local label = (term_type == "char_term") and "Find: " or "Search: "

  -- Exit vim so the user can type in the prompt without interference.
  Hypr.exit_vim()

  hl.timer(function()
    local term = prompt(label, "hyprvim-find")
    if not term or term == "" then
      Hypr.normal()
      return
    end
    -- Strip newlines/trailing whitespace.
    term = term:gsub("[\r\n]", ""):gsub("%s+$", "")
    Hypr.normal()
    hl.timer(function() do_find(term, direction, term_type, is_till) end, { timeout = 50, type = "oneshot" })
  end, { timeout = 100, type = "oneshot" })
end

---Repeat the last find: F3/Shift+F3 while the find bar is open, else re-run `do_find`.
---@param term_type string   `"char_term"` or `"find_term"`
---@param flip      boolean  true to reverse direction (i.e. `N` vs `n`)
local function repeat_find(term_type, flip)
  local active = state_get("active", "false")
  local direction = state_get("direction", "forward")
  local term = state_get(term_type, "")

  if active == "true" then
    local use_shift = (direction == "backward")
    if flip then use_shift = not use_shift end
    Hypr.send(use_shift and "SHIFT" or "", "F3")
  else
    if term == "" then
      Hypr.normal()
      return
    end
    local new_dir = direction
    if flip then new_dir = (direction == "forward") and "backward" or "forward" end
    do_find(term, new_dir, term_type, false)
  end
end

---Select the word under the cursor via keyboard shortcuts, copy it, and search for it.
---Implements `*` (forward) and `#` (backward).
---@param direction string  `"forward"` or `"backward"`
local function word_under_cursor(direction)
  -- Select word: CTRL+RIGHT positions at end, CTRL+SHIFT+LEFT selects back.
  Hypr.send("CTRL", "RIGHT")
  hl.timer(function()
    Hypr.send("CTRL SHIFT", "LEFT")
    hl.timer(function()
      Hypr.send("CTRL", "c")
      hl.timer(function()
        local term = clipboard_read():gsub("[\r\n]", ""):gsub("%s+$", "")
        -- First word only.
        term = term:match("^%S+") or term
        Hypr.send("", "RIGHT") -- deselect
        if term == "" then
          Hypr.normal()
          return
        end
        do_find(term, direction, "find_term", false)
      end, { timeout = 200, type = "oneshot" })
    end, { timeout = 150, type = "oneshot" })
  end, { timeout = 100, type = "oneshot" })
end

-- Public API — all map directly to vim motions:
--   f/F  char forward/backward       t/T  till forward/backward
--   /    search forward              ?    search backward
--   */#  word under cursor           n/N  repeat/reverse search
--   ;/,  repeat/reverse char find

function Find.char_forward() prompt_and_find("char_term", "forward", false) end
function Find.char_backward() prompt_and_find("char_term", "backward", false) end
function Find.char_till_forward() prompt_and_find("char_term", "forward", true) end
function Find.char_till_backward() prompt_and_find("char_term", "backward", true) end
function Find.search_forward() prompt_and_find("find_term", "forward", false) end
function Find.search_backward() prompt_and_find("find_term", "backward", false) end
function Find.forward_word() word_under_cursor("forward") end
function Find.backward_word() word_under_cursor("backward") end
function Find.next_search() repeat_find("find_term", false) end
function Find.prev_search() repeat_find("find_term", true) end
function Find.next_char() repeat_find("char_term", false) end
function Find.prev_char() repeat_find("char_term", true) end

---Dismiss the active find bar and clean up till/active state.
---Called when leaving NORMAL mode so the app's find UI is not left open.
function Find.deactivate()
  local active = state_get("active", "false")
  if active == "true" then Hypr.send("", "Escape") end
  if state_get("till", "false") == "true" then
    Hypr.send("", "LEFT")
    state_set("till", "false")
  end
  state_set("active", "false")
end

return Find
