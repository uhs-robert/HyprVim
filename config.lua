-- config.lua

local Utils = require("lib.utils") ---@class HyprVimUtils

-- stylua: ignore
local TERM_FLAGS = {
  kitty      = { class = "--class",   exec = "-e" },
  ghostty    = { class = "--class",   exec = "-e" },
  alacritty  = { class = "--class",   exec = "-e" },
  wezterm    = { class = "--class",   exec = "--",  pre = "start" },
  foot       = { class = "--app-id",  exec = "-e" },
  footclient = { class = "--app-id",  exec = "-e" },
  xterm      = { class = "-class",    exec = "-e" },
}

local XDG = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
local XCH = os.getenv("XDG_CACHE_HOME") or ((os.getenv("HOME") or "/tmp") .. "/.cache")
local XCC = os.getenv("XDG_CONFIG_HOME") or ((os.getenv("HOME") or "") .. "/.config")

--- @class HyprVimKeys
--- @field leader?   "SUPER"|"ALT"|"CTRL"|"SHIFT"|"META"|"HYPER"  Hyprland modifier key used as the vim leader
--- @field activate? string  Key name pressed together with leader to enter NORMAL mode (e.g. "ESCAPE")
--- @field exit?     string  Key name pressed together with leader to exit ANY mode (e.g. "SHIFT + ESCAPE")

--- @class HyprVimTermFlags
--- @field class string  Flag used to set the window class (e.g. "--class" or "--app-id")
--- @field exec  string  Flag used to run a command (e.g. "-e" or "--")
--- @field pre?  string  Extra word inserted before class flag (e.g. "start" for wezterm)

--- @class HyprVimApplications
--- @field menu?       "rofi"|"wofi"|"tofi"|"fuzzel"|"dmenu"|"zenity"|"kdialog"  Prompt tool for find/replace/command input
--- @field terminal?   "kitty"|"ghostty"|"alacritty"|"wezterm"|"foot"|"footclient"|"xterm"|string  Terminal used for the help viewer and open-editor feature; built-in flag mappings exist for the listed values, add an entry to `term_flags` for others
--- @field term_flags? table<string,HyprVimTermFlags>  Per-terminal flag overrides; e.g. `{ wezterm = { class = "--class", exec = "--", pre = "start" } }`. nil tries to autoresolve flags from the built-in terminal list.
--- @field lock?       string  Screen lock command executed by `:lock` and the L key in NORMAL mode (e.g. "hyprlock")
--- @field editor?     "vim"|"nvim"  Editor launched by the open-editor feature

--- @class HyprVimNotifications
--- @field all?      boolean  true: enable all notifications, overriding the individual flags below
--- @field marks?    boolean  true: show a desktop notification when a mark is set or jumped to
--- @field warnings? boolean  true: show a notification for recoverable issues (e.g. count clamped)
--- @field errors?   boolean  true: show a notification for hard failures (e.g. mark not set)

--- @class HyprVimAutoShow
--- @field disabled string[]|nil  Submaps that never auto-show the HUD; nil means nothing is suppressed
--- @field enabled  string[]|nil  Only show HUD for these submaps; nil (default) means all except `disabled`

--- @class HyprVimWhichKey
--- @field enabled?  boolean  true: show the which-key HUD on submap entry (requires eww)
--- @field delay_ms? integer  Milliseconds to wait before showing the panel (0 = instant)
--- @field position? "bottom-right"|"bottom-left"|"bottom-center"|"top-right"|"top-left"|"top-center"  Panel anchor position
--- @field auto_show? HyprVimAutoShow

--- @class HyprVimUpdates
--- @field channel? "stable"|"nightly"|"off"|string  "stable" = latest GitHub release (default), "nightly" = git HEAD, "off" = disabled, any other string = pinned release tag or commit SHA

--- @class HyprVimConfig
--- @field keys? HyprVimKeys
--- @field applications? HyprVimApplications
--- @field notifications? HyprVimNotifications
--- @field updates? HyprVimUpdates
--- @field enable_debug? boolean  true: write verbose diagnostic logs to the systemd journal (`journalctl -t hyprvim`)
--- @field max_count? integer     Maximum count digit accumulator; counts above this are silently clamped (default 1000)
--- @field which_key? HyprVimWhichKey
--- @field defaults? HyprVimConfig  Internal: holds the default values before user overrides are merged

--- @class HyprVimInstance : HyprVimConfig
--- @field xdg string         Resolved `$XDG_RUNTIME_DIR`
--- @field state_dir string   Resolved runtime state directory (`$XDG_RUNTIME_DIR/hyprvim`)
--- @field cache_dir string   Resolved cache directory (`$XDG_CACHE_HOME/hyprvim`)
--- @field config_dir string  Resolved user config directory (`$XDG_CONFIG_HOME/hyprvim`)
--- @field which_key HyprVimWhichKey
--- @field setup fun(overrides?: HyprVimConfig|table): HyprVimInstance
--- @field term_cmd fun(class: string): string  Returns the full terminal launch prefix for the given window class

--- @class HyprVimConfigModule : HyprVimConfig
--- @field defaults HyprVimConfig
--- @field setup fun(overrides?: HyprVimConfig|table): HyprVimInstance
--- @field term_cmd fun(class: string): string
local Config = {}

Config.xdg = XDG
Config.state_dir = XDG .. "/hyprvim"
Config.cache_dir = XCH .. "/hyprvim"
Config.config_dir = XCC .. "/hyprvim"

-- stylua: ignore
Config.defaults = {
  keys = {
    leader   = "SUPER",
    activate = "ESCAPE",
    exit     = "SHIFT + ESCAPE",
  },
  applications = {
    menu       = "rofi",
    terminal   = "kitty",
    term_flags = nil,
    lock       = "hyprlock",
    editor     = "nvim",
  },
  notifications = {
    all      = false,
    marks    = false,
    hints    = true,
    warnings = true,
    errors   = true,
  },
  which_key = {
    enabled  = true,
    delay_ms = 0,
    position = "bottom-right",
    auto_show = {
      disabled = { "NORMAL", "VISUAL", "V-LINE", "INSERT" },
      enabled  = nil,
    },
  },
  updates = {
    channel = "stable",
  },
  enable_debug = false,
  max_count    = 1000,
}

--- Merges user overrides into defaults and writes the result onto this module table.
--- After calling setup(), any module that does require("config") gets the configured values.
--- @param overrides HyprVimConfig|table|nil
Config.setup = function(overrides)
  local merged = Utils.deep_extend({}, Config.defaults)
  if overrides then Utils.deep_extend(merged, overrides) end
  for k, v in pairs(merged) do
    Config[k] = v
  end
  return Config --[[@as HyprVimInstance]]
end

---Return the full terminal launch prefix for `class` (e.g. "kitty --class hyprvim-open-vim -e").
---Looks up the configured terminal in the built-in flag table, then merges any user overrides
---from `applications.term_flags`.  Unknown terminals fall back to `--class … -e`.
---@param class string  Wayland app-id / window class to assign
---@return string
function Config.term_cmd(class)
  local term = Config.applications.terminal
  local user = (Config.applications.term_flags or {})[term]
  local flags = user or TERM_FLAGS[term] or { class = "--class", exec = "-e" }
  local parts = { term }
  if flags.pre then parts[#parts + 1] = flags.pre end
  parts[#parts + 1] = flags.class .. " " .. class
  parts[#parts + 1] = flags.exec
  return table.concat(parts, " ")
end

return Config
