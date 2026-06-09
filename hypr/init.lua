local Submap = require("lib.submap") ---@class HyprVimSubmap

--- @class HyprVimHyprland
local Hyprland = {}

--- @param mods string modifier string ("CTRL", "CTRL SHIFT", "" for none)
--- @param key string key name ("RIGHT", "HOME", "c", etc.)
--- @param window? string target window (default: activewindow)
function Hyprland.send(mods, key, window)
  hl.dispatch(hl.dsp.send_shortcut({ mods = mods, key = key, window = window or "activewindow" }))
end

--- @param shortcuts {[1]: string, [2]: string, [3]?: string}[] entries as {mods, key[, window]}
function Hyprland.send_all(shortcuts)
  for _, s in ipairs(shortcuts) do
    Hyprland.send(s[1], s[2], s[3])
  end
end

--- @param name string submap name
function Hyprland.switch_mode(name) Submap.enter(name) end

--- Return to NORMAL mode.
function Hyprland.normal() Submap.enter("NORMAL") end

--- Exit vim mode entirely (back to plain Hyprland binds).
function Hyprland.exit_vim()
  require("lib.clipboard").restore_pre_vim()
  Submap.reset()
  Submap.previous = nil
end

--- Temporarily suspend vim mode for a prompt; preserves submap state so it can be restored.
function Hyprland.suspend_vim() Submap.reset({ is_temporary = true }) end

--- Focus a specific window by its hex address.
---@param addr string  hex window address (e.g. "0x1234abcd")
function Hyprland.focus_window(addr) hl.dispatch(hl.dsp.focus({ window = "address:" .. addr })) end

--- Close the active window gracefully.
function Hyprland.close_window() hl.dispatch(hl.dsp.window.close()) end

--- Force-kill the active window.
function Hyprland.kill_window() hl.dispatch(hl.dsp.window.kill()) end

--- Toggle floating on the active window.
function Hyprland.toggle_floating() hl.dispatch(hl.dsp.window.float()) end

--- Toggle fullscreen (mode 1 = maximize).
function Hyprland.toggle_fullscreen() hl.dispatch(hl.dsp.window.fullscreen(1)) end

--- Toggle pin (show on all workspaces).
function Hyprland.toggle_pin() hl.dispatch(hl.dsp.window.pin()) end

--- Toggle pseudo-tiling.
function Hyprland.toggle_pseudo() hl.dispatch(hl.dsp.window.pseudo()) end

--- Center the active floating window.
function Hyprland.center_window() hl.dispatch(hl.dsp.window.center()) end

--- @param value number opacity 0.0–1.0
function Hyprland.set_opacity(value) hl.dispatch(hl.dsp.window.set_prop("alpha", tostring(value))) end

--- @param delta integer +1 or -1
function Hyprland.workspace_rel(delta)
  hl.dispatch(hl.dsp.workspace.move("e" .. (delta >= 0 and "+" or "") .. tostring(delta)))
end

--- @param n integer workspace number
function Hyprland.focus_workspace(n) hl.dispatch(hl.dsp.workspace.move(tostring(n))) end

--- @param n integer workspace number
function Hyprland.move_to_workspace(n) hl.dispatch(hl.dsp.window.move(tostring(n))) end

---@type table<string, integer>
local NOTIFY_ICONS = {
  warning = 0,
  info = 1,
  hint = 2,
  error = 3,
  confused = 4,
  ok = 5,
}

---@param msg     string
---@param icon    string|nil   `"warning"`, `"info"`, `"hint"`, `"error"`, `"confused"`, `"ok"` (default `"info"`)
---@param time_ms integer|nil  display duration in ms (default 3000)
---@param color   string|nil   hex color e.g. `"rgb(ff0000)"` (default `"0"` = icon default)
function Hyprland.notify(msg, icon, time_ms, color)
  local icon_id = NOTIFY_ICONS[icon or "info"] or NOTIFY_ICONS.info
  time_ms = time_ms or 3000
  color = color or "0"
  hl.dispatch(hl.dsp.exec_cmd(string.format("hyprctl notify %d %d %s %q", icon_id, time_ms, color, "HyprVim: " .. msg)))
end

--- Reload Hyprland config.
function Hyprland.reload() hl.dispatch(hl.dsp.exec_cmd("hyprctl reload")) end

--- @param cmd string
function Hyprland.exec(cmd) hl.dispatch(hl.dsp.exec_cmd(cmd)) end

--- Run cmd, then dispatch a Lua expr via hyprctl once it exits.
--- Acts as shell --block: awaits the shell command before dispatching.
--- @param cmd string            Shell command to run
--- @param dispatch_expr string  hl.dsp.* Lua expression, e.g. 'hl.dsp.submap("Cursor")'
--- @return fun()
function Hyprland.cmd_then_dispatch(cmd, dispatch_expr)
  return function() hl.dispatch(hl.dsp.exec_cmd(cmd .. " ; hyprctl dispatch '" .. dispatch_expr .. "'")) end
end

return Hyprland
