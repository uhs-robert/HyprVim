-- keys/submaps/modes/insert.lua

local Submap = require("lib.submap") ---@class HyprVimSubmap
local config = require("config") ---@class HyprVimConfigModule

local LEADER = (config.keys or {}).leader or "SUPER"
local ACT = (config.keys or {}).activate or "ESCAPE"
local HYPRVIM_ACTIVATE = LEADER .. " + " .. ACT

Submap.define({
  name = "INSERT",
  escape = "NORMAL",
  back = false,
  binds = {
    { HYPRVIM_ACTIVATE, function() hl.dispatch(hl.dsp.submap("reset")) end },
  },
}).setup()
