-- lib/prompt/init.lua
-- Non-blocking prompt helper. Spawns the configured terminal as a full-width
-- bottom bar so the compositor thread is never blocked waiting for user input.
-- The result is written to a state file by the shell, then read back inside a
-- global callback that is dispatched by hyprctl once the terminal exits.

local Config = require("config") ---@class HyprVimConfigModule
local Hypr = require("hypr") ---@class HyprVimHyprland
local Callback = require("lib.callback") ---@class Callback

--- @class Prompt
local Prompt = {}

local sq = require("lib.utils").sh_escape

---Build the terminal command that displays a prompt and writes input to state_file.
---Returns nil if the prompt script cannot be written.
---@param label      string    prompt label shown to the user
---@param opts       {wm_class?: string, completions?: string[]}
---@param state_file string    path where the result should land
---@return string|nil
local function build_cmd(label, opts, state_file)
  local wm_class = opts.wm_class or "hyprvim-prompt"
  local script = os.tmpname()
  local f = io.open(script, "w")
  if not f then return nil end

  local comp_block = ""
  if opts.completions and #opts.completions > 0 then
    local wl = sq(table.concat(opts.completions, " "))
    comp_block = "_hv_cycle_base=''\n"
      .. "_hv_cycle_idx=-1\n"
      .. "_hv_complete() {\n"
      .. "    local words="
      .. wl
      .. "\n"
      .. "    local matches found m\n"
      .. '    if [ -n "$_hv_cycle_base" ]; then\n'
      .. '        mapfile -t matches < <(compgen -W "$words" -- "$_hv_cycle_base")\n'
      .. "        found=0\n"
      .. '        for m in "${matches[@]}"; do [ "$m" = "$READLINE_LINE" ] && { found=1; break; }; done\n'
      .. '        [ $found -eq 0 ] && { _hv_cycle_base="$READLINE_LINE"; _hv_cycle_idx=-1; }\n'
      .. "    else\n"
      .. '        _hv_cycle_base="$READLINE_LINE"\n'
      .. "    fi\n"
      .. '    mapfile -t matches < <(compgen -W "$words" -- "$_hv_cycle_base")\n'
      .. '    [ "${#matches[@]}" -eq 0 ] && return\n'
      .. '    if [ "${#matches[@]}" -eq 1 ]; then\n'
      .. '        READLINE_LINE="${matches[0]}"\n'
      .. '        READLINE_POINT="${#READLINE_LINE}"\n'
      .. "        _hv_cycle_base=''\n"
      .. "        _hv_cycle_idx=-1\n"
      .. "    else\n"
      .. "        _hv_cycle_idx=$(( (_hv_cycle_idx + 1) % ${#matches[@]} ))\n"
      .. '        READLINE_LINE="${matches[$_hv_cycle_idx]}"\n'
      .. '        READLINE_POINT="${#READLINE_LINE}"\n'
      .. "    fi\n"
      .. "}\n"
      .. "bind -x '\"\\t\": _hv_complete'\n"
  end
  f:write(
    "trap 'rm -f "
      .. sq(script)
      .. "' EXIT\n"
      .. comp_block
      .. "read -e -r -p "
      .. sq(label)
      .. " __hv_in\n"
      .. "printf '%s' \"$__hv_in\" > "
      .. sq(state_file)
      .. "\n"
  )
  f:close()
  return Config.term_cmd(wm_class) .. " bash " .. sq(script)
end

---Show a prompt without blocking the compositor.
---`callback` is called once with the entered string, or nil if cancelled or
---the prompt could not be created.
---@param label    string
---@param opts     {wm_class?: string, completions?: string[]}
---@param callback fun(result: string|nil)
function Prompt.async(label, opts, callback)
  local state_file = os.tmpname()

  local cmd = build_cmd(label, opts, state_file)
  if not cmd then
    Hypr.notify("prompt: failed to write prompt script", "error", 3000)
    callback(nil)
    return
  end

  local dispatch = Callback.register(function()
    local f = io.open(state_file, "r")
    local result = f and f:read("*a"):gsub("%s+$", "") or ""
    if f then
      f:close()
      os.remove(state_file)
    end
    callback(result ~= "" and result or nil)
  end)

  Hypr.cmd_then_dispatch(cmd, dispatch)()
end

return Prompt
