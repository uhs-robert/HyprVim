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
  local windows = hl.get_workspace_windows(ws) or {}
  for i, w in ipairs(windows) do
    hl.timer(function() hl.dispatch(action("address:" .. w.address)) end, { timeout = 50 * i, type = "oneshot" })
  end
end

---Switch back to the active submap after an async operation suspends vim mode.
local function restore_submap()
  local current = require("lib.submap").current
  if current and current ~= "reset" then require("hypr").switch_mode(current) end
end

---Show a formatted command reference in a floating terminal.
---@return true
local function show_help()
  local help_file = Config.install_dir .. "/docs/command-help.md"
  _G._hv_help_done = function()
    _G._hv_help_done = nil
    restore_submap()
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
    local to_close = {}
    for _, w in ipairs(hl.get_workspace_windows(ws) or {}) do
      if w.address ~= win.address then to_close[#to_close + 1] = w end
    end
    for i, w in ipairs(to_close) do
      hl.timer(function() hl.dispatch(hl.dsp.window.close("address:" .. w.address)) end, { timeout = 50 * i, type = "oneshot" })
    end
  end,
  split      = function() hl.dispatch(hl.dsp.layout("preselect d")) end,
  vsplit     = function() hl.dispatch(hl.dsp.layout("preselect r")) end,
  float      = function() Hypr.toggle_floating() end,
  fullscreen = function() Hypr.toggle_fullscreen() end,
  pin        = function() Hypr.toggle_pin() end,
  center     = function() Hypr.center_window() end,
  pseudo     = function() Hypr.toggle_pseudo() end,
  dim        = function() Hypr.toggle_dim() end,
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
  picker     = function() hl.dispatch(hl.dsp.exec_cmd("pidof hyprpicker || (hyprpicker | wl-copy)")) end,
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
  h = "help", close = "q", kill = "q!",
  write = "w", save = "w",
  write_quit = "wq", save_quit = "wq",
  quit = "q",
  close_workspace = "qa", kill_workspace = "qa!",
}
for alias, canonical in pairs(aliases) do commands[alias] = commands[canonical] end

if Config.commands then
  for name, fn in pairs(Config.commands) do commands[name] = fn end
end

---Argument-taking commands: name -> handler(args_string).
---@type table<string, fun(args: string)>
local arg_commands = {
  ws             = function(a) Hypr.focus_workspace(tonumber(a) or a) end,
  tab            = function(a) Hypr.focus_workspace(tonumber(a) or a) end,
  workspace      = function(a) Hypr.focus_workspace(tonumber(a) or a) end,
  move           = function(a)
    local x, y = a:match("^([+-]?%d+)%s+([+-]?%d+)$")
    if x then
      hl.dispatch(hl.dsp.window.move({ x = tonumber(x), y = tonumber(y) }))
    else
      Hypr.move_to_workspace(tonumber(a) or a)
    end
  end,
  ["move!"]      = function(a) hl.dispatch(hl.dsp.window.move({ workspace = (tonumber(a) or a), follow = false })) end,
  move_to_workspace = function(a) Hypr.move_to_workspace(tonumber(a) or a) end,
  resize         = function(a) hl.dispatch(hl.dsp.window.resize({ x = -(tonumber(a) or 0), y = 0, relative = true })) end,
  resize_width   = function(a) hl.dispatch(hl.dsp.window.resize({ x = -(tonumber(a) or 0), y = 0, relative = true })) end,
  vresize        = function(a) hl.dispatch(hl.dsp.window.resize({ x = 0, y = -(tonumber(a) or 0), relative = true })) end,
  resize_height  = function(a) hl.dispatch(hl.dsp.window.resize({ x = 0, y = -(tonumber(a) or 0), relative = true })) end,
  size           = function(a)
    local w, h = a:match("^(%d+)%s+(%d+)$")
    if w then hl.dispatch(hl.dsp.window.resize({ x = tonumber(w), y = tonumber(h) })) end
  end,
  resize_exact   = function(a)
    local w, h = a:match("^(%d+)%s+(%d+)$")
    if w then hl.dispatch(hl.dsp.window.resize({ x = tonumber(w), y = tonumber(h) })) end
  end,
  opacity        = function(a)
    if a == "reset" then Hypr.reset_opacity(); return end
    local sa, si, sf = a:match("^([%d%.]+)%s+([%d%.]+)%s+([%d%.]+)$")
    if sa then
      local av, iv, fv = tonumber(sa), tonumber(si), tonumber(sf)
      if av and iv and fv then Hypr.set_opacity(av, iv, fv) end
      return
    end
    local sa2, si2 = a:match("^([%d%.]+)%s+([%d%.]+)$")
    if sa2 then
      local av, iv = tonumber(sa2), tonumber(si2)
      if av and iv then Hypr.set_opacity(av, iv) end
      return
    end
    local v = tonumber(a)
    if v then Hypr.set_opacity(v) end
  end,
  dim                = function(a)
    local win = hl.get_active_window()
    if not win then return end
    local enable = a == "on"
    hl.dispatch(hl.dsp.window.set_prop({ prop = "no_dim", value = enable and "0" or "1" }))
  end,
  active_opacity     = function(a)
    local v = tonumber(a)
    if v then Hypr.set_active_opacity(v) end
  end,
  inactive_opacity   = function(a)
    local v = tonumber(a)
    if v then Hypr.set_inactive_opacity(v) end
  end,
  fullscreen_opacity = function(a)
    local v = tonumber(a)
    if v then Hypr.set_fullscreen_opacity(v) end
  end,
  gaps           = function(a)
    local n = tonumber(a)
    if n then hl.config({ general = { gaps_in = n, gaps_out = n } }) end
  end,
  float          = function(a) hl.dispatch(hl.dsp.window.float({ action = a })) end,
  fullscreen     = function(a) hl.dispatch(hl.dsp.window.fullscreen({ mode = a })) end,
  monitor        = function(a) hl.dispatch(hl.dsp.focus({ monitor = a })) end,
  mon            = function(a) hl.dispatch(hl.dsp.focus({ monitor = a })) end,
  send_monitor   = function(a) hl.dispatch(hl.dsp.window.move({ monitor = a })) end,
  swap           = function(a) hl.dispatch(hl.dsp.window.swap({ direction = a })) end,
  special        = function(a) hl.dispatch(hl.dsp.workspace.toggle_special(a)) end,
  send_special   = function(a) hl.dispatch(hl.dsp.window.move({ workspace = "special:" .. a })) end,
  rename         = function(a) hl.dispatch(hl.dsp.workspace.rename({ name = a })) end,
  prop           = function(a)
    local prop, val = a:match("^(%S+)%s+(.*)")
    if prop then hl.dispatch(hl.dsp.window.set_prop({ prop = prop, value = val })) end
  end,
  focus          = function(a) hl.dispatch(hl.dsp.focus({ window = a })) end,
  zorder         = function(a) hl.dispatch(hl.dsp.window.alter_zorder({ mode = a })) end,
}
-- stylua: ignore end

local COMPLETIONS = {}
for k in pairs(commands) do
  COMPLETIONS[#COMPLETIONS + 1] = k
end
for k in pairs(arg_commands) do
  COMPLETIONS[#COMPLETIONS + 1] = k
end

---Look up and run a command string against the dispatch tables and special prefixes.
---@param cmd string  raw input from the prompt (may have leading/trailing whitespace)
---@return true|nil  true if the command dispatched an async operation
local function execute(cmd)
  cmd = cmd:gsub("^%s+", ""):gsub("%s+$", "")

  local fn = commands[cmd]
  if fn then return fn() end

  local name, args = cmd:match("^(%S+)%s+(.*)")
  if name then
    local afn = arg_commands[name]
    if afn then return afn(args) end
  end

  if cmd:match("^%%?s/") then
    Hypr.send("CTRL", "h")
    return
  end

  local shell_cmd = cmd:match("^!(.+)$")
  if shell_cmd then
    _G._hv_shell_done = function()
      _G._hv_shell_done = nil
      restore_submap()
    end
    Hypr.cmd_then_dispatch(
      Config.term_cmd("hyprvim-shell")
        .. " bash -c "
        .. sq(
          "_hv_tmp=$(mktemp); "
            .. shell_cmd
            .. ' 2>&1 | tee "$_hv_tmp";'
            .. " [ -s \"$_hv_tmp\" ] && { echo; read -rsn1 -p '[done] press any key...'; };"
            .. ' rm -f "$_hv_tmp"'
        ),
      "_hv_shell_done()"
    )()
    return true
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
