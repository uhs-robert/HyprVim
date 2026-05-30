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
local LEADER = config.keys.leader or "SUPER"
local ACT = config.keys.activate or "ESCAPE"
local EXIT = config.keys.exit or "ESCAPE"

local function send(mods, key) hl.dispatch(hl.dsp.send_shortcut({ mods = mods, key = key })) end

local normal = Submap.switch("NORMAL")
local visual = Submap.switch("VISUAL")
local reset = Submap.switch("reset")
local va = motion.action_visual
local vm = motion.action
local va_seq = motion.action_seq

-- ── Visual actions ────────────────────────────────────────────────────────────
-- stylua: ignore start
local function open_editor(insert)
  return function() count.clear() reset() oe.open({ copy_selected = true, insert_mode = insert or false, after_submap = "NORMAL" }) end
end

local function change_sel()    reg.handle_delete("CTRL", "x", "INSERT") end
local function delete_sel()    reg.handle_delete("CTRL", "x", "NORMAL") end
local function backspace_sel() wk.close() reg.handle_delete("", "BackSpace", "NORMAL") end
local function delete_bol()    send("SHIFT", "HOME") send("", "Delete") normal() end
local function yank_sel()      reg.handle_yank("CTRL", "c", "NORMAL") end
local function yank_bol()      motion.send_sequence({ { "", "END" }, { "SHIFT", "HOME" } }) reg.handle_yank("CTRL", "c", "NORMAL") end
local function paste_sel()     reg.handle_paste("CTRL", "v", "NORMAL") end
local function sel_bol()       send("SHIFT", "HOME") end
local function sel_eol()       send("SHIFT", "END") end
local function sel_page_down() send("SHIFT", "PAGE_DOWN") end
local function sel_page_up()   send("SHIFT", "PAGE_UP") end
local function sel_last_line() send("CTRL SHIFT", "END") end

---Return an action that passes a CTRL+key shortcut through without leaving visual mode.
---@param key string
---@return fun()
local function fmt(key) return function() send("CTRL", key) end end

---Return an action that passes a CTRL+key shortcut and returns to normal mode.
---@param key string
---@return fun()
local function passthrough(key) return function() send("CTRL", key) normal() end end
-- stylua: ignore end

local footer = {
  { "SPACE", wk.toggle },
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
  back = function()
    wk.close()
    normal()
  end,
  catchall = "stay",
  binds = function()
    local rows = {
      -- stylua: ignore start
      -- Count
      { "0", count.handle_zero_visual },
      -- Mode switches
      { "g", Submap.switch("G-VISUAL"), "+Goto" },
      -- Editor
      { LEADER .. " + n", open_editor(false), "Edit in Vim (Normal)" },
      { LEADER .. " + i", open_editor(true),  "Edit in Vim (Insert)" },
      -- Char motions
      { "h",         va("h"), "Left",          { repeating = true } },
      { "j",         va("j"), "Down",          { repeating = true } },
      { "k",         va("k"), "Up",            { repeating = true } },
      { "l",         va("l"), "Right",         { repeating = true } },
      { "SHIFT + h", va("H"), "Start of line", { repeating = true } },
      { "SHIFT + j", va("J"), "J",             { repeating = true } },
      { "SHIFT + k", va("K"), "K",             { repeating = true } },
      { "SHIFT + l", va("L"), "End of line",   { repeating = true } },
      -- Word
      { "b",         va("b"), "Prev word",     { repeating = true } },
      { "e",         va("e"), "Next end word", { repeating = true } },
      { "w",         va("w"), "Next word",     { repeating = true } },
      { "SHIFT + b", va("B"), nil,             { repeating = true } },
      { "SHIFT + e", va("E"), nil,             { repeating = true } },
      { "SHIFT + w", va("W"), nil,             { repeating = true } },
      -- Paragraph
      { "SHIFT + BRACKETLEFT",  va_seq({ { "SHIFT", "HOME" }, { "CTRL SHIFT", "UP" } }),   "Paragraph start", { repeating = true } },
      { "SHIFT + BRACKETRIGHT", va_seq({ { "SHIFT", "END" },  { "CTRL SHIFT", "DOWN" } }), "Paragraph end",   { repeating = true } },
      -- Line / page
      { "SHIFT + MINUS", sel_bol,       "Start of line", { repeating = true } },
      { "SHIFT + 4",     sel_eol,       "End of line",   { repeating = true } },
      { "CTRL + e",      sel_page_down, "Page down",     { repeating = true } },
      { "CTRL + y",      sel_page_up,   "Page up",       { repeating = true } },
      { "SHIFT + g",     sel_last_line, "Last line",     { repeating = true } },
      -- Undo
      { "u",        vm("u"),        "Undo", { repeating = true } },
      { "SHIFT + u", vm("u"),       nil,    { repeating = true } },
      { "CTRL + r",  vm("CTRL + r"), "Redo", { repeating = true } },
      -- Change / delete / yank / paste
      { "c",         change_sel,    "Change"                                  },
      { "SHIFT + x", backspace_sel, "BackSpace",  { repeating = true }        },
      { "x",         delete_sel,    nil,          { repeating = true }        },
      { "d",         delete_sel,    "Delete",     { repeating = true }        },
      { "SHIFT + d", delete_bol,    "Delete to line start"                    },
      { "y",         yank_sel,      "Yank"                                    },
      { "SHIFT + y", yank_bol,      "Yank to line start"                      },
      { "p",         paste_sel,     "Paste",      { repeating = true }        },
      { "SHIFT + p", paste_sel,     nil,          { repeating = true }        },
      -- Normal shortcuts passthrough
      { "CTRL + x", passthrough("x"), nil, { repeating = true } },
      { "CTRL + p", passthrough("v"), nil, { repeating = true } },
      { "CTRL + v", passthrough("v"), nil, { repeating = true } },
      { "CTRL + b", fmt("b"),         nil, { repeating = true } },
      { "CTRL + i", fmt("i"),         nil, { repeating = true } },
      { "CTRL + u", fmt("u"),         nil, { repeating = true } },
      { "CTRL + s", fmt("s"),         nil, { repeating = true } },
      -- Sub-submaps
      { "i",         Submap.switch("V-INSIDE"), "+Inner"  },
      { "SHIFT + i", Submap.switch("V-INSIDE")            },
      { "a",         Submap.switch("V-AROUND"), "+Around" },
      { "SHIFT + a", Submap.switch("V-AROUND")            },
      -- stylua: ignore end
    }
    for i = 1, 9 do
      table.insert(rows, { tostring(i), function() count.append(tostring(i)) end })
    end
    for _, row in ipairs(footer) do
      table.insert(rows, row)
    end
    return rows
  end,
}).setup()

-- ---------------------------------------------------------------------------
-- V-INSIDE / V-AROUND (text objects in visual mode)
-- ---------------------------------------------------------------------------

local function visual_text_object(name, parent_name, word_seq, para_seq)
  local parent = Submap.switch(parent_name)
  Submap.define({
    name = name,
    escape = "NORMAL",
    back = function()
      wk.close()
      parent()
    end,
    catchall = "stay",
    binds = {
      -- stylua: ignore start
      { "w",         function() motion.send_sequence(word_seq) parent() end, "Word"      },
      { "SHIFT + w", function() motion.send_sequence(word_seq) parent() end              },
      { "p",         function() motion.send_sequence(para_seq) parent() end, "Paragraph" },
      { "SHIFT + p", function() motion.send_sequence(para_seq) parent() end              },
      { "SPACE",     wk.toggle },
      { LEADER .. " + " .. ACT, reset },
      { LEADER .. " + " .. EXIT, reset },
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
