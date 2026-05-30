-- vim/commands/command.lua
-- Vim-style command mode (:w, :q, :split, :ws N, etc.)

local Hypr = require("hypr") ---@class HyprVimHyprland
local Config = require("config") ---@class HyprVimConfigModule
local Updater = require("lib.updater") ---@class Updater
local Prompt = require("lib.prompt") ---@class Prompt

local Command = {} --- @class Command

---@param s string
---@return string
local function sq(s) return "'" .. s:gsub("'", "'\\''") .. "'" end

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

---Show a formatted command reference in a floating terminal.
---@return true
local function show_help()
  local help_file = Config.install_dir .. "/docs/command-help.md"
  _G._hv_help_done = function()
    _G._hv_help_done = nil
    local current = require("lib.submap").current
    if current and current ~= "reset" then require("hypr").switch_mode(current) end
  end
  Hypr.cmd_then_dispatch(
    Config.term_cmd("hyprvim-help") .. " bash -c " .. sq(Config.applications.editor .. " -RM " .. help_file),
    "_hv_help_done()"
  )()
  return true
end

---Exact-match dispatch table: command string -> handler.
---@type table<string, fun()>
-- stylua: ignore start
local commands = {
  w      = function() Hypr.send("CTRL", "S") end,
  wq     = function()
    Hypr.send("CTRL", "S")
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
  update     = function() Updater.update() end,
  lock       = function() Hypr.exec(Config.applications.lock) end,
  exit       = function() end,
  logout     = function()
    if os.execute("command -v hyprshutdown >/dev/null 2>&1") then
      os.execute("hyprshutdown &")
    else
      hl.dispatch(hl.dsp.exit())
    end
  end,
  shutdown   = function() hl.dispatch(hl.dsp.exec_cmd("systemctl poweroff")) end,
  picker     = function() hl.dispatch(hl.dsp.exec_cmd("pidof hyprpicker || hyprpicker | wl-copy")) end,
  e          = function() Hypr.exec(Config.applications.terminal .. " " .. Config.applications.editor) end,
  term       = function() Hypr.exec(Config.applications.terminal) end,
  help       = show_help,
}
-- Aliases
local aliases = {
  sp = "split", vsp = "vsplit", vs = "vsplit",
  f  = "float", fs = "fullscreen", c = "center",
  tn = "tabn",  tp = "tabp",
  r  = "reload", edit = "e", t = "term", terminal = "term",
  poweroff = "shutdown", pick = "picker", hyprpicker = "picker",
  h = "help"
}
for alias, canonical in pairs(aliases) do commands[alias] = commands[canonical] end

-- All completions exposed to the terminal prompt (tab completion).
local COMPLETIONS = {
  "w", "wq", "q", "q!", "qa", "qa!", "only",
  "split", "vsplit", "float", "fullscreen", "pin", "center", "pseudo",
  "tabn", "tabp", "ws", "move", "opacity",
  "reload", "lock", "update", "exit", "logout", "e", "term", "help",
  "sp", "vsp", "vs", "f", "fs", "c", "tn", "tp", "r", "edit", "t",
}

---Pattern-match table for parameterised commands (`:ws N`, `:move N`, `:opacity V`, `s/`).
---Each entry is `{ pattern, handler }` where handler receives the first capture (or `""` when there is none).
---@type { [1]: string, [2]: fun(cap: string): true|nil }[]
local patterns = {
  { "^ws%s*(%d+)$",        function(n) Hypr.focus_workspace(tonumber(n) or 0) end },
  { "^move%s*(%d+)$",      function(n) Hypr.move_to_workspace(tonumber(n) or 0) end },
  { "^opacity%s+([%d%.]+)$", function(v)
      v = tonumber(v)
      if v and v >= 0 and v <= 1 then Hypr.set_opacity(v) end
    end },
  { "^%%?s/",              function() Hypr.send("CTRL", "h") end },
  { "^!(.+)$",            function(shell_cmd)
      _G._hv_shell_done = function()
        _G._hv_shell_done = nil
        local current = require("lib.submap").current
        if current and current ~= "reset" then require("hypr").switch_mode(current) end
      end
      Hypr.cmd_then_dispatch(
        Config.term_cmd("hyprvim-shell") .. " bash -c " .. sq(shell_cmd .. "; echo; read -rsn1 -p '[done] press any key...'"),
        "_hv_shell_done()"
      )()
      return true
    end },
}
-- stylua: ignore end

---Look up and run a command string against the dispatch table then the pattern list.
---@param cmd string  raw input from the prompt (may have leading/trailing whitespace)
---@return true|nil  true if the command dispatched an async operation
local function execute(cmd)
  cmd = cmd:gsub("^%s+", ""):gsub("%s+$", "")
  local fn = commands[cmd]
  if fn then return fn() end
  for _, p in ipairs(patterns) do
    local cap = cmd:match(p[1])
    if cap ~= nil then return p[2](cap) end
  end
end

---Show the `:` command prompt, execute the entered command, then restore the current submap.
function Command.prompt()
  local origin = require("lib.submap").current
  Hypr.suspend_vim()
  hl.timer(function()
    Prompt.async(":", { wm_class = "hyprvim-command", completions = COMPLETIONS }, function(cmd)
      local function restore()
        if origin and origin ~= "reset" then Hypr.switch_mode(origin) end
      end
      if not cmd then
        restore()
        return
      end
      hl.timer(function()
        if not execute(cmd) then restore() end
      end, { timeout = 50, type = "oneshot" })
    end)
  end, { timeout = 100, type = "oneshot" })
end

return Command
