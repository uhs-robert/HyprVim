-- vim/lib/init.lua
-- Internal dispatch primitives. Required by vim/init.lua; not called directly from submaps.

--- @class VimLib
VimLib = {}

VimLib.count = require("vim.lib.count")
VimLib.hypr = require("hypr")
VimLib.motion = require("vim.lib.motion")
VimLib.line_motion = require("vim.lib.line_motion")

return VimLib
