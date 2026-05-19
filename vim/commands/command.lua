-- vim/commands/command.lua
-- Vim-style command mode (:w, :q, :split, :ws N, etc.)

local Hypr = require("hypr") ---@class HyprVimHyprland
local Config = require("config") ---@class HyprVimConfigModule

--- @class Command
local Command = {}

---@return string|nil  user-entered command, or nil if cancelled
local function prompt_command()
  local tool = Config.applications.menu
  local cmd
  if tool == "rofi" then
    cmd = "rofi -dmenu -p \":\" -theme-str 'window{width:600px;}' -class hyprvim-command 2>/dev/null"
  else
    cmd = string.format('%s -p ":" 2>/dev/null', tool)
  end
  local p = io.popen(cmd)
  if not p then return nil end
  local s = p:read("*a"):gsub("%s+$", "")
  p:close()
  return s ~= "" and s or nil
end

---@return string
local function after_path() return require("config").state_dir .. "/command-after" end

---Store which submap to return to after the command prompt closes.
---@param submap string|nil  submap name; defaults to "NORMAL"
function Command.set_after(submap)
  local f = io.open(after_path(), "w")
  if f then
    f:write(submap or "NORMAL")
    f:close()
  end
end

---Read the stored after-submap, remove the state file, and switch to that mode.
function Command.dispatch_after()
  local f = io.open(after_path(), "r")
  local target = "NORMAL"
  if f then
    target = f:read("*a"):gsub("%s+$", "")
    f:close()
    os.remove(after_path())
  end
  Hypr.switch_mode(target ~= "" and target or "NORMAL")
end

---Close or kill every window in the active workspace.
---@param kill boolean  true -> kill (SIGKILL), false -> graceful close
local function close_workspace_windows(kill)
  local ws = hl.get_active_workspace()
  if not ws then return end
  local action = kill and hl.dsp.window.kill or hl.dsp.window.close
  for _, w in ipairs(hl.get_workspace_windows(ws) or {}) do
    hl.dispatch(action({ address = w.address }))
  end
end

---Exact-match dispatch table: command string -> handler.
---@type table<string, fun()>
-- stylua: ignore start
local commands = {
  w      = function() Hypr.send("CTRL", "s") end,
  wq     = function()
    Hypr.send("CTRL", "s")
    hl.timer(function() Hypr.close_window() end, { timeout = 100, type = "oneshot" })
  end,
  q      = function() Hypr.close_window() end,
  ["q!"] = function() Hypr.kill_window() end,
  qa     = function() close_workspace_windows(false) end,
  ["qa!"]= function() close_workspace_windows(true) end,
  only   = function()
    local win = hl.get_active_window()
    local ws = hl.get_active_workspace()
    if not (win and ws) then return end
    for _, w in ipairs(hl.get_workspace_windows(ws) or {}) do
      if w.address ~= win.address then hl.dispatch(hl.dsp.window.close({ address = w.address })) end
    end
  end,
  split      = function() hl.dispatch(hl.dsp.layout("preselect d")) end,
  vsplit     = function() hl.dispatch(hl.dsp.layout("preselect r")) end,
  float      = function() Hypr.toggle_floating() end,
  fullscreen = function() Hypr.toggle_fullscreen() end,
  pin        = function() Hypr.toggle_pin() end,
  center     = function() Hypr.center_window() end,
  pseudo     = function() Hypr.toggle_pseudo() end,
  tabn       = function() Hypr.workspace_rel(1) end,
  tabp       = function() Hypr.workspace_rel(-1) end,
  reload     = function() os.execute("hyprctl reload &") end,
  lock       = function() Hypr.exec(Config.applications.lock) end,
  exit       = function()
    if os.execute("command -v hyprshutdown >/dev/null 2>&1") then
      os.execute("hyprshutdown &")
    else
      hl.dispatch(hl.dsp.exit())
    end
  end,
  e          = function() Hypr.exec(Config.applications.terminal .. " " .. Config.applications.editor) end,
  term       = function() Hypr.exec(Config.applications.terminal) end,
}
-- Aliases
local aliases = {
  sp = "split", vsp = "vsplit", vs = "vsplit",
  f  = "float", fs = "fullscreen", c = "center",
  tn = "tabn",  tp = "tabp",
  r  = "reload", edit = "e", t = "term",
  logout = "exit"
}
for alias, canonical in pairs(aliases) do commands[alias] = commands[canonical] end

---Pattern-match table for parameterised commands (`:ws N`, `:move N`, `:opacity V`, `s/`).
---Each entry is `{ pattern, handler }` where handler receives the first capture (or `""` when there is none).
---@type { [1]: string, [2]: fun(cap: string) }[]
local patterns = {
  { "^ws%s*(%d+)$",        function(n) Hypr.focus_workspace(tonumber(n) or 0) end },
  { "^move%s*(%d+)$",      function(n) Hypr.move_to_workspace(tonumber(n) or 0) end },
  { "^opacity%s+([%d%.]+)$", function(v)
      v = tonumber(v)
      if v and v >= 0 and v <= 1 then Hypr.set_opacity(v) end
    end },
  { "^%%?s/",              function() Hypr.send("CTRL", "h") end },
}
-- stylua: ignore end

---Look up and run a command string against the dispatch table then the pattern list.
---@param cmd string  raw input from the prompt (may have leading/trailing whitespace)
local function execute(cmd)
  cmd = cmd:gsub("^%s+", ""):gsub("%s+$", "")
  local fn = commands[cmd]
  if fn then
    fn()
    return
  end
  for _, p in ipairs(patterns) do
    local cap = cmd:match(p[1])
    if cap ~= nil then
      p[2](cap)
      return
    end
  end
end

---Show the `:` command prompt, execute the entered command, then restore the previous submap.
function Command.prompt()
  Hypr.exit_vim()
  hl.timer(function()
    local cmd = prompt_command()
    Hypr.normal()
    if not cmd or cmd == "" then
      Command.dispatch_after()
      return
    end
    hl.timer(function()
      execute(cmd)
      Command.dispatch_after()
    end, { timeout = 50, type = "oneshot" })
  end, { timeout = 100, type = "oneshot" })
end

return Command
