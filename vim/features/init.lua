-- vim/features/init.lua
-- Stateful vim features. Required by vim/init.lua.

--- @class VimFeatures
local VimFeatures = {}

VimFeatures.marks = require("vim.features.marks")
VimFeatures.registers = require("vim.features.registers")
VimFeatures.find = require("vim.features.find")
VimFeatures.replace = require("vim.features.replace")

return VimFeatures
