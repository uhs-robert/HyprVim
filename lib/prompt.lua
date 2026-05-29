-- lib/prompt.lua
-- Non-blocking prompt helper.  Runs a dmenu-style prompt via exec_cmd so the
-- compositor thread is never blocked waiting for user input.  The result is
-- written to a state file by the shell, then read back inside a global callback
-- that is dispatched by hyprctl once the prompt exits.

local Config = require("config") ---@class HyprVimConfigModule
local Hypr = require("hypr") ---@class HyprVimHyprland

--- @class Prompt
local Prompt = {}

---Build the shell command string for the configured menu tool.
---@param label   string      prompt label shown to the user
---@param opts    {wm_class?: string, theme?: string}
---@return string
local function build_cmd(label, opts)
  local tool = Config.applications.menu
  local wm_class = opts.wm_class or "hyprvim-prompt"
  local theme = opts.theme or "window{width:600px;}"
  if tool == "rofi" then
    return string.format("rofi -dmenu -p %q -theme-str %q -class %q 2>/dev/null", label, theme, wm_class)
  else
    return string.format("%s -p %q 2>/dev/null", tool, label)
  end
end

---Show a dmenu-style prompt without blocking the compositor.
---`callback` is called once with the entered string, or nil if cancelled.
---@param label    string
---@param opts     {wm_class?: string, theme?: string}
---@param callback fun(result: string|nil)
function Prompt.async(label, opts, callback)
  local state_file = Config.state_dir .. "/prompt-result"

  _G._hv_prompt_cb = function()
    local f = io.open(state_file, "r")
    local result = f and f:read("*a"):gsub("%s+$", "") or ""
    if f then
      f:close()
      os.remove(state_file)
    end
    _G._hv_prompt_cb = nil
    callback(result ~= "" and result or nil)
  end

  local cmd = build_cmd(label, opts) .. " > " .. state_file
  Hypr.cmd_then_dispatch(cmd, "_hv_prompt_cb()")()
end

return Prompt
