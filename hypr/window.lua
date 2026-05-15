-- hypr/window.lua
-- Window-state queries: class detection, terminal routing.

--- @class HyprVimWindow
local Window = {}

---Window classes treated as terminals: they receive raw vim keys instead of GUI shortcuts.
---Overridden by `Window.init` if `Config.terminal_classes` is provided.
---@type table<string, true>
local TERM_CLASSES = {
  kitty = true,
  alacritty = true,
  foot = true,
  wezterm = true,
  ghostty = true,
  ["org.wezfurlong.wezterm"] = true,
}

---Merge config into the window module. Called once at startup.
---@param Config { terminal_classes?: string[] }|nil
function Window.init(Config)
  if Config and Config.terminal_classes then
    TERM_CLASSES = {}
    for _, cls in ipairs(Config.terminal_classes) do
      TERM_CLASSES[cls] = true
    end
  end
end

---Return true if the currently active window is a terminal emulator.
---@return boolean
function Window.is_terminal()
  local win = hl.get_active_window()
  return win ~= nil and TERM_CLASSES[win.class] == true
end

return Window
