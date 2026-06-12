-- vim/exit.lua
-- Composes the full vim-mode teardown

local Submap = require("lib.submap") ---@class HyprVimSubmap
local Clipboard = require("lib.clipboard") ---@class Clipboard

---Exit vim mode entirely
return function()
  Clipboard.restore_pre_vim()
  Submap.reset()
  Submap.previous = nil
end
