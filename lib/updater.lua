-- lib/updater.lua

local dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)") or "./"
package.path = dir .. "../?.lua;" .. dir .. "../?/init.lua;" .. package.path

local Utils = require("lib.utils")
local sh = Utils.sh_escape

local root = dir .. "../"
local script = dir .. "../scripts/hyprvim-update"

--- @class Updater
local Updater = {}

--- Run scripts/hyprvim-update in the background for the given op and channel.
--- @param op "check"|"apply"
--- @param channel string
local function run_async(op, channel)
  local is_named = channel == "nightly" or channel == "stable"
  local norm = is_named and channel or "pinned"
  local cmd = sh(script) .. " " .. op .. " " .. norm .. " " .. sh(root)
  if not is_named then cmd = cmd .. " " .. sh(channel) end
  os.execute("(" .. cmd .. ") &")
end

--- Fetch remote state and notify based on the configured update channel.
--- Runs entirely in background, does not block init.
function Updater.check_async()
  local channel = (require("config").updates or {}).channel or "stable"
  if channel == "off" then return end
  run_async("check", channel)
end

--- Apply the update for the current channel. Called by :update command.
function Updater.update()
  local channel = (require("config").updates or {}).channel or "stable"
  if channel == "off" then return end
  run_async("apply", channel)
end

return Updater
