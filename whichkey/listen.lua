-- whichkey/listen.lua
-- Registers hl event handlers for the which-key HUD.

local dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)") or "./"
local root = dir .. "../"
package.path = root .. "?.lua;" .. root .. "?/init.lua;" .. package.path

local Render = require("whichkey.render") ---@class Render
local Utils = require("lib.utils") ---@class HyprVimUtils
local Theme = require("whichkey.theme")
local Submap = require("lib.submap") ---@class HyprVimSubmap
local sh_escape = Utils.sh_escape
local read_file = Utils.read_file

--- @class Listen
local Listen = {}

-- stylua: ignore
local DELAY_SMs = {
  ["D-MOTION"] = 1, ["D-I"] = 1, ["D-A"] = 1, ["D-G"] = 1,
  ["C-MOTION"] = 1, ["C-I"] = 1, ["C-A"] = 1, ["C-G"] = 1,
  ["Y-MOTION"] = 1, ["Y-I"] = 1, ["Y-A"] = 1, ["Y-G"] = 1,
  ["G-MOTION"] = 1, ["G-VISUAL"] = 1, ["R-CHAR"] = 1,
}

--- Returns true if sm is a persistent mode that should not auto-show the HUD.
--- @param sm string
--- @return boolean
local function is_sticky(sm)
  local l = sm:lower()
  return l == "normal" or l == "visual" or l == "v-line"
end

--- Returns true if sm is an operator-pending mode that needs a show delay.
--- @param sm string
--- @return boolean
local function requires_delay(sm) return DELAY_SMs[sm] ~= nil end

--- Extracts and normalises which-key config from the top-level Config table.
--- @param Config table
--- @return { delay_ms: integer, position: string, deny_set: table, allow_set: table, has_allow: boolean }
local function parse_config(Config)
  local wk = Config.which_key or {}
  local auto = wk.auto_show or {}
  local deny_set = {}
  local allow_set = {}
  local has_allow = false
  if type(auto.disabled) == "table" then
    for _, v in ipairs(auto.disabled) do
      deny_set[v] = true
    end
  end
  if type(auto.enabled) == "table" then
    for _, v in ipairs(auto.enabled) do
      allow_set[v] = true
    end
    has_allow = true
  end
  return {
    delay_ms = wk.delay_ms or 100,
    position = wk.position or "bottom-right",
    deny_set = deny_set,
    allow_set = allow_set,
    has_allow = has_allow,
  }
end

--- Returns true if the HUD should be shown automatically for sm.
--- Respects the deny/allow lists from config; falls back to hiding only sticky modes.
--- @param sm string
--- @param config table
--- @return boolean
local function should_auto_show(sm, config)
  if config.deny_set[sm] then return false end
  if config.has_allow then return config.allow_set[sm] == true end
  return not is_sticky(sm)
end

--- Returns the millisecond delay before showing the HUD for sm.
--- next_delay (from the one-shot flag file) overrides everything; otherwise submap_delay_ms
--- (per-submap spec override) takes priority over the global delay_ms, except
--- operator-pending modes that chain from another operator mode always use 0 ms.
--- @param sm string
--- @param prev_sm string
--- @param next_delay string  raw file contents, "" if absent
--- @param delay_ms integer
--- @param submap_delay_ms integer|nil  per-submap override from SubmapSpec.delay_ms
--- @return integer
local function compute_delay(sm, prev_sm, next_delay, delay_ms, submap_delay_ms)
  if next_delay ~= "" then
    return tonumber(next_delay) or 0
  end
  local effective_ms = submap_delay_ms or delay_ms
  if requires_delay(sm) then
    -- Operator-pending chains: no extra delay when coming from another operator mode.
    return (prev_sm ~= "" and requires_delay(prev_sm)) and 0 or effective_ms
  end
  return effective_ms
end

--- Starts the eww daemon in the background (or pings it if already running),
--- then applies the current theme.
--- @param eww_dir string
local function init_eww(eww_dir)
  Theme.apply()
-- stylua: ignore
  os.execute(
    "("
      .. "eww -c "
      .. sh_escape(eww_dir)
      .. " ping >/dev/null 2>&1"
      .. " || eww -c "
      .. sh_escape(eww_dir)
      .. " daemon >/dev/null 2>&1"
      .. ") &"
  )
end

--- Reads one-shot skip/delay flags from state files, consuming them where appropriate.
--- Targetless skips and delay overrides are deleted on read; targeted skips stay until matched.
--- @param state_dir string
--- @return boolean skip_next
--- @return string skip_target
--- @return string next_delay
local function read_oneshot_flags(state_dir)
  local skip_path = state_dir .. "/whichkey-skip-next"
  local target_path = state_dir .. "/whichkey-skip-target"
  local delay_path = state_dir .. "/whichkey-next-delay"

  local skip_next = io.open(skip_path, "r") ~= nil
  local skip_target = read_file(target_path)
  local next_delay = read_file(delay_path)

  -- Consume targetless skip and delay flags immediately; targeted skip stays until matched.
  if skip_next and skip_target == "" then os.execute("rm -f " .. sh_escape(skip_path)) end
  if next_delay ~= "" then os.execute("rm -f " .. sh_escape(delay_path)) end

  return skip_next, skip_target, next_delay
end

--- Returns true if the skip flag applies to sm and clears the flag files.
--- A targeted skip only matches when skip_target == sm; an untargeted skip matches any sm.
--- @param skip_next boolean
--- @param skip_target string
--- @param sm string
--- @param state_dir string
--- @return boolean
local function resolve_skip(skip_next, skip_target, sm, state_dir)
  if not skip_next then return false end
  if skip_target ~= "" and skip_target ~= sm then return false end
  os.execute(
    "rm -f " .. sh_escape(state_dir .. "/whichkey-skip-next") .. " " .. sh_escape(state_dir .. "/whichkey-skip-target")
  )
  return true
end

--- Returns a function that spawns render.lua in the background for sm.
--- Guards against stale renders by checking the current-submap state file before rendering.
--- @param eww_dir string
--- @param state_dir string
--- @param render string  path to render.lua
--- @param position string
--- @return fun(sm: string)
local function make_spawner(eww_dir, state_dir, render, position)
  return function(sm)
    local mon = hl.get_active_monitor()
    local screen = (mon and mon.name) or ""
    local csm = state_dir .. "/current-submap"
    os.execute(
      "(eww -c "
        .. sh_escape(eww_dir)
        .. " ping >/dev/null 2>&1"
        .. " || eww -c "
        .. sh_escape(eww_dir)
        .. " daemon >/dev/null 2>&1; "
        .. "cur=$(cat "
        .. sh_escape(csm)
        .. " 2>/dev/null || echo ''); [ \"$cur\" = "
        .. sh_escape(sm)
        .. " ]"
        .. " && HYPRVIM_WHICH_KEY_POSITION="
        .. sh_escape(position)
        .. " lua "
        .. sh_escape(render)
        .. " "
        .. sh_escape(sm)
        .. " "
        .. sh_escape(screen)
        .. ") &"
    )
  end
end

--- Removes the skip-next and skip-target flag files.
--- @param state_dir string
local function clear_skip_files(state_dir)
  os.execute(
    "rm -f " .. sh_escape(state_dir .. "/whichkey-skip-next") .. " " .. sh_escape(state_dir .. "/whichkey-skip-target")
  )
end

--- Returns the keybinds.submap event handler.
--- Tracks previous submap for delay chaining, manages the pending timer,
--- and decides whether to show the HUD immediately, after a delay, or not at all.
--- @param config table  parsed config from parse_config()
--- @param state_dir string
--- @param spawn_render fun(sm: string)
--- @return fun(sm: string)
local function make_submap_handler(config, state_dir, spawn_render)
  state_dir = state_dir or ""
  local last_sm = ""
  local prev_sm = ""
  local pending_timer = nil
  local stale_check_timer = nil

  return function(sm)
    sm = sm or ""
    if sm == last_sm then return end

    prev_sm = last_sm
    last_sm = sm

    if pending_timer then
      pending_timer:set_enabled(false)
      pending_timer = nil
    end

    if stale_check_timer then
      stale_check_timer:set_enabled(false)
      stale_check_timer = nil
    end

    Render.close()

    -- Maintain current-submap state file for stale-render detection.
    if sm ~= "" then
      local f = io.open(state_dir .. "/current-submap", "w")
      if f then
        f:write(sm .. "\n")
        f:close()
      end
    else
      os.execute("rm -f " .. sh_escape(state_dir .. "/current-submap"))
    end

    local skip_next, skip_target, next_delay = read_oneshot_flags(state_dir)

    if sm == "" then
      clear_skip_files(state_dir)
      return
    end
    if sm == "NORMAL" then clear_skip_files(state_dir) end

    local skip_applies = resolve_skip(skip_next, skip_target, sm, state_dir)
    if skip_applies or not should_auto_show(sm, config) then return end

    local spec = Submap.registry[sm]
    local dms = compute_delay(sm, prev_sm, next_delay, config.delay_ms, spec and spec.delay_ms)

    pending_timer = hl.timer(function()
      pending_timer = nil
      if last_sm ~= sm then return end
      spawn_render(sm)
      -- Stale-render guard: if the submap changed while the subprocess was rendering,
      -- the close() that fired during the handler ran before eww opened the window.
      -- Check after a render-completion window and close any now-orphaned HUD.
      local render_sm = sm
      stale_check_timer = hl.timer(function()
        stale_check_timer = nil
        if last_sm ~= render_sm then Render.close() end
      end, { timeout = 500, type = "oneshot" })
    end, { timeout = math.max(dms, 1), type = "oneshot" })
  end
end

--- Initialises the which-key HUD listener.
--- Starts the eww daemon, then registers window.open and keybinds.submap handlers.
--- @param Config table  top-level HyprVim config table
function Listen.init(Config)
  local config = parse_config(Config)
  local eww_dir = Render.eww_dir
  local state_dir = Render.state_dir
  local render = dir .. "render.lua"

  init_eww(eww_dir)

  local spawn_render = make_spawner(eww_dir, state_dir, render, config.position)

  hl.on("window.open", function() Render.close() end)
  hl.on("keybinds.submap", make_submap_handler(config, state_dir, spawn_render))
end

return Listen
