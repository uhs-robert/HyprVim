-- keys/submaps/modes/v-line.lua
-- V-LINE, G-VLINE submaps

local Submap = require("lib.submap") ---@class HyprVimSubmap
local vim = require("vim") ---@class Vim
local motion = vim.motion
local count = vim.count
local lm = vim.line_motion
local reg = vim.registers
local wk = require("whichkey") ---@class WhichKey
local oe = vim.editor
local Hypr = require("hypr") ---@class HyprVimHyprland
local common = require("keys.submaps.common")

local LEADER = common.keys()

local send = Hypr.send
local function normal() Submap.enter("NORMAL") end
local function visual() hl.dispatch(hl.dsp.submap("VISUAL")) end
local function reset() hl.dispatch(hl.dsp.submap("reset")) end
local function vline() hl.dispatch(hl.dsp.submap("V-LINE")) end

local footer = common.footer()

-- ---------------------------------------------------------------------------
-- V-LINE
-- ---------------------------------------------------------------------------

Submap.define({
  name = "V-LINE",
  on_enter = function()
    count.clear()
    lm.setup()
  end,
  escape = function()
    lm.reset()
    send("", "LEFT")
    send("", "RIGHT")
    normal()
  end,
  back = function()
    wk.close()
    visual()
  end,
  catchall = "stay",
  binds = function()
    local rows = {
      -- stylua: ignore start
      -- Editor
      { LEADER .. " + n", function() count.clear() reset() oe.open({ copy_selected = true, after_submap = "NORMAL" }) end,                    "Edit in Vim (Normal)" },
      { LEADER .. " + i", function() count.clear() reset() oe.open({ copy_selected = true, insert_mode = true, after_submap = "NORMAL" }) end, "Edit in Vim (Insert)" },
      -- Motions
      { "j",                    function() lm.down(count.get()) end,           "Down",           { repeating = true } },
      { "k",                    function() lm.up(count.get()) end,             "Up",             { repeating = true } },
      { "SHIFT + BRACKETLEFT",  function() lm.paragraph_up(count.get()) end,   "Prev paragraph" },
      { "SHIFT + BRACKETRIGHT", function() lm.paragraph_down(count.get()) end, "Next paragraph" },
      { "CTRL + e",             function() send("SHIFT", "PAGE_DOWN") end, "Page down", { repeating = true } },
      { "CTRL + y",             function() send("SHIFT", "PAGE_UP") end,   "Page up",   { repeating = true } },
      { "SHIFT + g",            function() lm.goto_end() vline() end, "Last line", { repeating = true } },
      -- Undo
      { "u",       function() motion.send("u") end,          "Undo", { repeating = true } },
      { "CTRL + r", function() motion.send("CTRL + r") end,  "Redo", { repeating = true } },
      -- Change / delete / yank / paste
      { "c",         function() lm.reset() reg.handle_delete("INSERT") end },
      { "SHIFT + x", function() wk.close() lm.reset() reg.handle_delete("NORMAL") end, "BackSpace", { repeating = true } },
      { "x",         function() lm.reset() reg.handle_delete("NORMAL") end, nil, { repeating = true } },
      { "d",         function() lm.reset() reg.handle_delete("NORMAL") end, "Delete", { repeating = true } },
      { "SHIFT + d", function() lm.reset() send("SHIFT", "HOME") send("", "Delete") normal() end, "Delete to line start" },
      { "y",         function() lm.reset() reg.handle_yank("CTRL", "c", "NORMAL") end, "Yank", { repeating = true } },
      { "p",         function() reg.handle_paste("CTRL", "v", "NORMAL") end, "Paste", { repeating = true } },
      -- Normal shortcuts passthrough
      { "CTRL + x", function() send("CTRL", "x") normal() end, nil, { repeating = true } },
      { "CTRL + p", function() send("CTRL", "v") normal() end, nil, { repeating = true } },
      { "CTRL + v", function() send("CTRL", "v") normal() end, nil, { repeating = true } },
      { "CTRL + b", function() send("CTRL", "b") end, nil, { repeating = true } },
      { "CTRL + i", function() send("CTRL", "i") end, nil, { repeating = true } },
      { "CTRL + u", function() send("CTRL", "u") end, nil, { repeating = true } },
      { "CTRL + s", function() send("CTRL", "s") end, nil, { repeating = true } },
      -- G-VLINE
      { "g",         function() hl.dispatch(hl.dsp.submap("G-VLINE")) end, "+Go Line" },
      -- stylua: ignore end
    }
    for i = 0, 9 do
      table.insert(rows, { tostring(i), function() count.append(tostring(i)) end })
    end
    for _, row in ipairs(footer) do
      table.insert(rows, row)
    end
    return rows
  end,
}).setup()

-- ---------------------------------------------------------------------------
-- G-VLINE
-- ---------------------------------------------------------------------------

Submap.define({
  name = "G-VLINE",
  escape = "NORMAL",
  back = function()
    wk.close()
    visual()
  end,
  catchall = "stay",
  binds = function()
    local rows = {
    -- stylua: ignore start
    { "g",         function() lm.goto_start() vline() end, "First line" },
    { "SHIFT + g", function() lm.goto_end()   vline() end, "Last line"  },
    { "n",         function() count.clear() reset() oe.open({ copy_selected = true, after_submap = "NORMAL" }) end,                    "Edit in Vim (Normal)" },
    { "i",         function() count.clear() reset() oe.open({ copy_selected = true, insert_mode = true, after_submap = "NORMAL" }) end, "Edit in Vim (Insert)" },
      -- stylua: ignore end
    }
    for _, row in ipairs(footer) do
      table.insert(rows, row)
    end
    return rows
  end,
}).setup()
