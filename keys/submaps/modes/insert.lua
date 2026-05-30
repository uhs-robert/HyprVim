-- keys/submaps/modes/insert.lua

local Submap = require("lib.submap") ---@class HyprVimSubmap
local config = require("config") ---@class HyprVimConfigModule

local LEADER = config.keys.leader or "SUPER"
local ACT = config.keys.activate or "ESCAPE"
local EXIT = config.keys.exit or "ESCAPE"

Submap.define({
  name = "INSERT",
  escape = "NORMAL",
  back = false,
  binds = {
    { LEADER .. " + " .. ACT, Submap.reset },
    { LEADER .. " + " .. EXIT, Submap.reset },
  },
}).setup()
