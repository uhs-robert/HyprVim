-- whichkey/init.lua
-- Public API for the WhichKey HUD system.

local dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)") or "./"
local root = dir .. "../"
package.path = root .. "?.lua;" .. root .. "?/init.lua;" .. package.path

local Render = require("whichkey.render") ---@class Render
local Utils = require("lib.utils") ---@class HyprVimUtils
local sh_escape = Utils.sh_escape

--- @class WhichKey
local WhichKey = {}

--- Show the HUD for a submap.
--- @type fun(submap: string, screen?: string)
WhichKey.show = Render.show

--- Hide the HUD.
--- @type fun()
WhichKey.close = Render.close

--- Write a one-shot skip flag consumed by the listener on the next submap entry.
--- @type fun(target?: string)
WhichKey.set_skip = Render.set_skip

--- Write a one-shot delay override consumed by the listener on the next submap entry.
--- @type fun(ms: number)
WhichKey.set_delay = Render.set_delay

--- Toggle the HUD for the current submap.
--- Spawns render.lua as a subprocess to avoid blocking Hyprland's Lua event loop.
function WhichKey.toggle()
  local state_dir = Render.state_dir
  local vf = io.open(state_dir .. "/whichkey-visible", "r")
  if vf then
    vf:close()
    Render.close()
    return
  end

  local f = io.open(state_dir .. "/current-submap", "r")
  local current = f and f:read("*a"):gsub("%s+$", "") or ""
  if f then f:close() end
  local target = (current ~= "" and current ~= "reset") and current or "GLOBAL"

  local mon = hl.get_active_monitor and hl.get_active_monitor()
  local screen = (mon and mon.name) or ""

  os.execute("(lua " .. sh_escape(dir .. "render.lua") .. " " .. sh_escape(target) .. " " .. sh_escape(screen) .. ") &")
end

--- Cancel any pending HUD timer. Call from keybind actions that immediately exit
--- an operator-pending submap so the HUD does not flash after the action completes.
function WhichKey.cancel_pending() require("whichkey.listen").cancel_pending() end

--- Register Hyprland event handlers for the which-key HUD.
--- Called by hyprvim's setup() when which_key.enabled is true.
--- @param Config table  merged hyprvim config from config.lua
function WhichKey.start(Config) require("whichkey.listen").init(Config) end

return WhichKey
