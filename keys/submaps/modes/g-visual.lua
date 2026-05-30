-- keys/submaps/modes/g-visual.lua

local Submap = require("lib.submap") ---@class HyprVimSubmap
local vim = require("vim") ---@class Vim
local wk = require("whichkey") ---@class WhichKey
local config = require("config") ---@class HyprVimConfigModule
local LEADER = config.keys.leader or "SUPER"
local ACT = config.keys.activate or "ESCAPE"
local EXIT = config.keys.exit or "ESCAPE"

local function send(mods, key) hl.dispatch(hl.dsp.send_shortcut({ mods = mods, key = key })) end
local function visual() hl.dispatch(hl.dsp.submap("VISUAL")) end

Submap.define({
  name = "G-VISUAL",
  escape = "VISUAL",
  back = function()
    wk.close()
    visual()
  end,
  catchall = "stay",
  binds = {
    -- stylua: ignore start
    { "e",         function() vim.motion.send_sequence({ { "CTRL", "LEFT" }, { "", "LEFT" } }) visual() end, "Prev end of word" },
    { "g",         function() send("CTRL SHIFT", "HOME") visual() end, "First line" },
    { "SHIFT + g", function() send("CTRL SHIFT", "END")  visual() end, "Last line"  },
    { "n",         function() vim.count.clear() Submap.reset() vim.editor.open({ copy_selected = true, after_submap = "NORMAL" }) end,                     "Edit in Vim (Normal)" },
    { "i",         function() vim.count.clear() Submap.reset() vim.editor.open({ copy_selected = true, insert_mode = true, after_submap = "NORMAL" }) end, "Edit in Vim (Insert)" },
    { "SPACE",     wk.toggle },
    { LEADER .. " + " .. ACT, Submap.reset },
    { LEADER .. " + " .. EXIT, Submap.reset },
    -- stylua: ignore end
  },
}).setup()
