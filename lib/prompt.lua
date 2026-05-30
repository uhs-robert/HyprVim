-- lib/prompt/init.lua
-- Non-blocking prompt helper.  Spawns the configured terminal as a full-width
-- bottom bar so the compositor thread is never blocked waiting for user input.
-- The result is written to a state file by the shell, then read back inside a
-- global callback that is dispatched by hyprctl once the terminal exits.

local Config = require("config") ---@class HyprVimConfigModule
local Hypr = require("hypr") ---@class HyprVimHyprland

--- @class Prompt
local Prompt = {}

---Shell-escape `s` for use in a single-quoted argument.
---@param s string
---@return string
local function sq(s) return "'" .. s:gsub("'", "'\\''") .. "'" end

---Build the terminal command that displays a prompt and writes input to state_file.
---@param label      string    prompt label shown to the user
---@param opts       {wm_class?: string, completions?: string[]}
---@param state_file string    path where the result should land
---@return string
local function build_cmd(label, opts, state_file)
  local wm_class = opts.wm_class or "hyprvim-prompt"
  local script = os.tmpname()
  local f = io.open(script, "w")
  if f then
    local comp_block = ""
    if opts.completions and #opts.completions > 0 then
      local wl = sq(table.concat(opts.completions, " "))
      comp_block = "_hv_complete() {\n"
        .. "    local words=" .. wl .. "\n"
        .. "    local matches\n"
        .. "    mapfile -t matches < <(compgen -W \"$words\" -- \"$READLINE_LINE\")\n"
        .. "    if [ \"${#matches[@]}\" -eq 1 ]; then\n"
        .. "        READLINE_LINE=\"${matches[0]}\"\n"
        .. "        READLINE_POINT=\"${#matches[0]}\"\n"
        .. "    elif [ \"${#matches[@]}\" -gt 1 ]; then\n"
        .. "        printf '\\n'\n"
        .. "        printf '  %s\\n' \"${matches[@]}\"\n"
        .. "    fi\n"
        .. "}\n"
        .. "bind -x '\"\\t\": _hv_complete'\n"
    end
    f:write(
      "trap 'rm -f " .. sq(script) .. "' EXIT\n"
      .. comp_block
      .. "read -e -r -p " .. sq(label) .. " __hv_in\n"
      .. "printf '%s' \"$__hv_in\" > " .. sq(state_file) .. "\n"
    )
    f:close()
  end
  return Config.term_cmd(wm_class) .. " bash " .. sq(script)
end

---Show a prompt without blocking the compositor.
---`callback` is called once with the entered string, or nil if cancelled.
---@param label    string
---@param opts     {wm_class?: string, completions?: string[]}
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

  Hypr.cmd_then_dispatch(build_cmd(label, opts, state_file), "_hv_prompt_cb()")()
end

return Prompt
