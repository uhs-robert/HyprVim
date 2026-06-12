-- keys/submaps/modes/g-visual.lua

local Submap = require("lib.submap") ---@class HyprVimSubmap
local vim = require("vim") ---@class Vim
local Hypr = require("hypr") ---@class HyprVimHyprland
local common = require("keys.submaps.common")

local send = Hypr.send
local function visual() Submap.enter("VISUAL") end

Submap.define({
  name = "G-VISUAL",
  escape = "VISUAL",
  back = "previous",
  catchall = "stay",
  binds = {
    -- stylua: ignore start
    { "e",         function() vim.motion.send_sequence({ { "CTRL SHIFT", "LEFT" }, { "SHIFT", "LEFT" } }) visual() end, "Prev end of word" },
    { "g",         function() send("CTRL SHIFT", "HOME") visual() end, "First line" },
    { "SHIFT + g", function() send("CTRL SHIFT", "END")  visual() end, "Last line"  },
    { "n",         function() vim.count.clear() Submap.reset() vim.editor.open({ copy_selected = true, after_submap = "NORMAL" }) end,                     "Edit in Vim (Normal)" },
    { "i",         function() vim.count.clear() Submap.reset() vim.editor.open({ copy_selected = true, insert_mode = true, after_submap = "NORMAL" }) end, "Edit in Vim (Insert)" },
    table.unpack(common.footer()),
    -- stylua: ignore end
  },
}).setup()
