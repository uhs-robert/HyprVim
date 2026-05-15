-- keys/submaps/modes/insert.lua

local leader = (require("config").keys or {}).leader   or "SUPER"
local act    = (require("config").keys or {}).activate or "ESCAPE"

local function b(keys, fn) hl.bind(keys, fn) end
local function submap(n)   hl.dispatch(hl.dsp.submap(n)) end

hl.define_submap("INSERT", "reset", function()
  b(leader .. " + " .. act, function() hl.dispatch(hl.dsp.submap("reset")) end)
  b("ESCAPE",               function() submap("NORMAL") end)
end)
