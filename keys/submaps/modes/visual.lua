-- keys/submaps/modes/visual.lua
-- VISUAL, V-I, V-A submaps

local Submap = require("lib.submap") ---@class HyprVimSubmap
local vim = require("vim") ---@class Vim
local motion = vim.motion
local count = vim.count
local reg = vim.registers
local wk = require("whichkey") ---@class WhichKey
local oe = vim.editor
local config = require("config") ---@class HyprVimConfigModule
local LEADER = (config.keys or {}).leader or "SUPER"
local ACT = (config.keys or {}).activate or "ESCAPE"

local function send(mods, key) hl.dispatch(hl.dsp.send_shortcut({ mods = mods, key = key })) end
local function normal() hl.dispatch(hl.dsp.submap("NORMAL")) end
local function visual() hl.dispatch(hl.dsp.submap("VISUAL")) end
local function reset() hl.dispatch(hl.dsp.submap("reset")) end

local footer = {
  { "SPACE",                 wk.toggle },
  { LEADER .. " + " .. ACT, reset },
}

-- ---------------------------------------------------------------------------
-- VISUAL
-- ---------------------------------------------------------------------------

Submap.define({
  name = "VISUAL",
  on_enter = function() count.clear() end,
  escape = function()
    send("", "LEFT")
    send("", "RIGHT")
    normal()
  end,
  back = function() wk.close() normal() end,
  catchall = "stay",
  binds = function()
    local rows = {
      -- stylua: ignore start
      -- Count
      { "0", function() count.handle_zero_visual() end },
      -- Mode switches
      { "g", function() hl.dispatch(hl.dsp.submap("G-VISUAL")) end, "+Goto" },
      -- Editor
      { LEADER .. " + n", function() count.clear() reset() oe.open({ copy_selected = true }) end,                    "Edit in Vim (Normal)" },
      { LEADER .. " + i", function() count.clear() reset() oe.open({ copy_selected = true, insert_mode = true }) end, "Edit in Vim (Insert)" },
      -- Char motions
      { "h",             function() motion.send_raw({ "SHIFT", "LEFT" },  count.get()) end, "Left",  { repeating = true } },
      { "j",             function() motion.send_raw({ "SHIFT", "DOWN" },  count.get()) end, "Down",  { repeating = true } },
      { "k",             function() motion.send_raw({ "SHIFT", "UP" },    count.get()) end, "Up",    { repeating = true } },
      { "l",             function() motion.send_raw({ "SHIFT", "RIGHT" }, count.get()) end, "Right", { repeating = true } },
      { "SHIFT + h",     function() motion.send_raw({ "SHIFT", "HOME" },      count.get()) end, "Start of line", { repeating = true } },
      { "SHIFT + j",     function() motion.send_raw({ "CTRL SHIFT", "DOWN" }, count.get()) end, "J",             { repeating = true } },
      { "SHIFT + k",     function() motion.send_raw({ "CTRL SHIFT", "UP" },   count.get()) end, "K",             { repeating = true } },
      { "SHIFT + l",     function() motion.send_raw({ "SHIFT", "END" },        count.get()) end, "End of line",   { repeating = true } },
      -- Word
      { "b",         function() motion.send_raw({ "CTRL SHIFT", "LEFT" },  count.get()) end, "Prev word",     { repeating = true } },
      { "e",         function() motion.send_raw({ "CTRL SHIFT", "RIGHT" }, count.get()) end, "Next end word", { repeating = true } },
      { "w",         function() motion.send_raw({ "CTRL SHIFT", "RIGHT" }, count.get()) end, "Next word",     { repeating = true } },
      { "SHIFT + b", function() motion.send_raw({ "CTRL SHIFT", "LEFT" },  count.get()) end, nil, { repeating = true } },
      { "SHIFT + e", function() motion.send_raw({ "CTRL SHIFT", "RIGHT" }, count.get()) end, nil, { repeating = true } },
      { "SHIFT + w", function() motion.send_raw({ "CTRL SHIFT", "RIGHT" }, count.get()) end, nil, { repeating = true } },
      -- Paragraph
      { "SHIFT + BRACKETLEFT",  function() motion.send_sequence({ { "SHIFT", "HOME" }, { "CTRL SHIFT", "UP" } }) end,   "Paragraph start", { repeating = true } },
      { "SHIFT + BRACKETRIGHT", function() motion.send_sequence({ { "SHIFT", "END" },  { "CTRL SHIFT", "DOWN" } }) end, "Paragraph end",   { repeating = true } },
      -- Line / page
      { "SHIFT + MINUS", function() send("SHIFT", "HOME") end,      "Start of line", { repeating = true } },
      { "SHIFT + 4",     function() send("SHIFT", "END") end,       "End of line",   { repeating = true } },
      { "CTRL + e",      function() send("SHIFT", "PAGE_DOWN") end, "Page down",     { repeating = true } },
      { "CTRL + y",      function() send("SHIFT", "PAGE_UP") end,   "Page up",       { repeating = true } },
      { "SHIFT + g",     function() send("CTRL SHIFT", "END") end,  "Last line",     { repeating = true } },
      -- Undo
      { "u",       function() motion.send("u") end,          "Undo", { repeating = true } },
      { "SHIFT + u", function() motion.send("u") end,        nil,    { repeating = true } },
      { "CTRL + r",  function() motion.send("CTRL + r") end, "Redo", { repeating = true } },
      -- Change / delete / yank / paste
      { "c",         function() reg.handle_delete("CTRL", "x", "INSERT") end, "Change" },
      { "SHIFT + x", function() wk.close() reg.handle_delete("", "BackSpace", "NORMAL") end, "BackSpace", { repeating = true } },
      { "x",         function() reg.handle_delete("CTRL", "x", "NORMAL") end, nil,     { repeating = true } },
      { "d",         function() reg.handle_delete("CTRL", "x", "NORMAL") end, "Delete", { repeating = true } },
      { "SHIFT + d", function() send("SHIFT", "HOME") send("", "Delete") normal() end, "Delete to line start" },
      { "y",         function() reg.handle_yank("CTRL", "c", "NORMAL") end,   "Yank" },
      { "SHIFT + y", function() motion.send_sequence({ { "", "END" }, { "SHIFT", "HOME" } }) reg.handle_yank("CTRL", "c", "NORMAL") end, "Yank to line start" },
      { "p",         function() reg.handle_paste("CTRL", "v", "NORMAL") end,  "Paste", { repeating = true } },
      { "SHIFT + p", function() reg.handle_paste("CTRL", "v", "NORMAL") end,  nil,     { repeating = true } },
      -- Normal shortcuts passthrough
      { "CTRL + x", function() send("CTRL", "x") normal() end, nil, { repeating = true } },
      { "CTRL + p", function() send("CTRL", "v") normal() end, nil, { repeating = true } },
      { "CTRL + v", function() send("CTRL", "v") normal() end, nil, { repeating = true } },
      { "CTRL + b", function() send("CTRL", "b") end, nil, { repeating = true } },
      { "CTRL + i", function() send("CTRL", "i") end, nil, { repeating = true } },
      { "CTRL + u", function() send("CTRL", "u") end, nil, { repeating = true } },
      { "CTRL + s", function() send("CTRL", "s") end, nil, { repeating = true } },
      -- Sub-submaps
      { "i",         function() hl.dispatch(hl.dsp.submap("V-INSIDE")) end, "+Inner" },
      { "SHIFT + i", function() hl.dispatch(hl.dsp.submap("V-INSIDE")) end },
      { "a",         function() hl.dispatch(hl.dsp.submap("V-AROUND")) end, "+Around" },
      { "SHIFT + a", function() hl.dispatch(hl.dsp.submap("V-AROUND")) end },
      -- stylua: ignore end
    }
    for i = 1, 9 do
      table.insert(rows, { tostring(i), function() count.append(tostring(i)) end })
    end
    for _, row in ipairs(footer) do table.insert(rows, row) end
    return rows
  end,
}).setup()

-- ---------------------------------------------------------------------------
-- V-INSIDE / V-AROUND (text objects in visual mode)
-- ---------------------------------------------------------------------------

local function visual_text_object(name, parent_name, word_seq, para_seq)
  local function parent() hl.dispatch(hl.dsp.submap(parent_name)) end
  Submap.define({
    name = name,
    escape = "NORMAL",
    back = function() wk.close() parent() end,
    catchall = "stay",
    binds = {
      -- stylua: ignore start
      { "w",         function() motion.send_sequence(word_seq) parent() end, "Word" },
      { "SHIFT + w", function() motion.send_sequence(word_seq) parent() end },
      { "p",         function() motion.send_sequence(para_seq) parent() end, "Paragraph" },
      { "SHIFT + p", function() motion.send_sequence(para_seq) parent() end },
      { "SPACE",     wk.toggle },
      { LEADER .. " + " .. ACT, reset },
      -- stylua: ignore end
    },
  }).setup()
end

visual_text_object(
  "V-INSIDE",
  "VISUAL",
  { { "CTRL", "RIGHT" }, { "CTRL SHIFT", "LEFT" } },
  { { "", "END" }, { "CTRL", "UP" }, { "CTRL SHIFT", "DOWN" } }
)

visual_text_object(
  "V-AROUND",
  "VISUAL",
  { { "CTRL", "LEFT" }, { "CTRL SHIFT", "RIGHT" } },
  { { "", "END" }, { "CTRL", "UP" }, { "CTRL SHIFT", "DOWN" } }
)
