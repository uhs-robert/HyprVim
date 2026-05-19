-- keys/submaps/init.lua
-- Load all submap definitions (order matters: modes before operators before marks).

--- @class SubmapModule
--- @field setup fun()
local Submaps = {}

Submaps.setup = function()
  require("keys.submaps.modes")
  require("keys.submaps.vim-operators")
  require("keys.submaps.vim-marks")
  require("keys.submaps.vim-registers")
  require("keys.submaps.vim-replace-char")
end

return Submaps
