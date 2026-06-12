-- vim/init.lua
-- Public API for the vim engine. Submaps require("hyprvim.vim") to call into this.
--
-- Usage from a submap callback:
--   local vim = require("vim")
--   vim.motion.send("j")          -- move down
--   vim.count.append("3")         -- accumulate count
--   vim.marks.set("a")            -- set mark a
--   vim.registers.handle_yank("CTRL", "c", { collapse = true })

local root = debug.getinfo(1, "S").source:sub(2):match("(.*/)") or "./"
package.path = root .. "?.lua;" .. root .. "?/init.lua;" .. package.path

-- stylua: ignore
local lib      = require("vim.lib") ---@class VimLib
local exit     = require("vim.exit")
local features = require("vim.features") ---@class VimFeatures
local commands = require("vim.commands") ---@class VimCommands
local Window   = require("hypr.window") ---@class HyprVimWindow

local function setup(Config) Window.init(Config) end

-- stylua: ignore
--- @class Vim
local Vim = {
  setup       = setup,
  exit        = exit,
  -- lib
  count       = lib.count,
  motion      = lib.motion,
  line_motion = lib.line_motion,
  hypr        = lib.hypr,
  -- features
  marks       = features.marks,
  registers   = features.registers,
  find        = features.find,
  replace     = features.replace,
  -- commands
  command     = commands.command,
  editor      = commands.editor,
}

return Vim
