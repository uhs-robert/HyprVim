-- keys/submaps/modes/insert.lua

local Submap = require("lib.submap") ---@class HyprVimSubmap
local Hypr = require("hypr") ---@class HyprVimHyprland
local config = require("config") ---@class HyprVimConfigModule

local LEADER = config.keys.leader or "SUPER"
local ACT = config.keys.activate or "ESCAPE"
local EXIT = config.keys.exit or "ESCAPE"

Submap.define({
  name = "INSERT",
  escape = "NORMAL",
  back = false,
  binds = {
    { LEADER .. " + " .. ACT, Hypr.exit_vim },
    { LEADER .. " + " .. EXIT, Hypr.exit_vim },
  },
}).setup()
