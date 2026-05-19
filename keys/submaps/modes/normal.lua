-- keys/submaps/modes/normal.lua

local Submap = require("lib.submap") ---@class HyprVimSubmap
local Bind = require("lib.bind") ---@class HyprVimBindLib
local vim = require("vim") ---@class Vim
local wk = require("whichkey") ---@class WhichKey
local config = require("config") ---@class HyprVimConfigModule
local Hypr = require("hypr") ---@class HyprVimHyprland
local LEADER = config.keys.leader or "SUPER"
local EXIT = config.keys.exit or "ESCAPE"

local send = Hypr.send
local cc = vim.count.clear_then_fn
local vm = vim.motion.action
local vm_keys = vim.motion.action_seq

---@param opts { insert?: boolean }|nil
---@return fun()
local function open_vim_editor(opts)
  return function()
    vim.count.clear()
    hl.dispatch(hl.dsp.submap("reset"))
    vim.editor.open({ copy_selected = true, insert_mode = (opts and opts.insert) or false })
  end
end

-- ── Find ──────────────────────────────────────────────────────────────────────
-- stylua: ignore start
local find = {
  char_forward    = cc(vim.find.char_forward),
  char_backward   = cc(vim.find.char_backward),
  till_forward    = cc(vim.find.char_till_forward),
  till_backward   = cc(vim.find.char_till_backward),
  search_forward  = cc(vim.find.search_forward),
  search_backward = cc(vim.find.search_backward),
  forward_word    = cc(vim.find.forward_word),
  backward_word   = cc(vim.find.backward_word),
  next_search     = cc(vim.find.next_search),
  prev_search     = cc(vim.find.prev_search),
  next_char       = cc(vim.find.next_char),
  prev_char       = cc(vim.find.prev_char),
}

-- ── Marks ─────────────────────────────────────────────────────────────────────
local function set_mark()  vim.marks.set_after("NORMAL") hl.dispatch(hl.dsp.submap("SET-MARK")) end
local function jump_mark() vim.marks.set_after("NORMAL") hl.dispatch(hl.dsp.submap("MARKS")) end
local function goto_mark() vim.marks.set_after("reset")  hl.dispatch(hl.dsp.submap("MARKS")) end

-- ── Insert mode ───────────────────────────────────────────────────────────────
local function insert_at_cursor() vim.count.clear() hl.dispatch(hl.dsp.submap("INSERT")) end
local function insert_after()     vim.count.clear() hl.dispatch(hl.dsp.submap("INSERT")) send("", "RIGHT") end
local function insert_eol()       vim.count.clear() hl.dispatch(hl.dsp.submap("INSERT")) send("", "END") end
local function insert_bol()       vim.count.clear() hl.dispatch(hl.dsp.submap("INSERT")) send("", "HOME") end
local function open_below()       vim.count.clear() send("", "END") send("", "Return") hl.dispatch(hl.dsp.submap("INSERT")) end
local function open_above()       vim.count.clear() send("", "HOME") send("", "Return") send("", "Up") hl.dispatch(hl.dsp.submap("INSERT")) end
local function open_below_se()    vim.count.clear() send("", "END") send("SHIFT", "Return") hl.dispatch(hl.dsp.submap("INSERT")) end
local function open_above_se()    vim.count.clear() send("", "HOME") send("SHIFT", "Return") send("", "Up") hl.dispatch(hl.dsp.submap("INSERT")) end

-- ── Change / delete / paste / indent ─────────────────────────────────────────
local function change_eol()    vim.count.clear() vim.motion.send_raw({ "SHIFT", "End" }, 1) vim.registers.handle_delete("CTRL", "x", "INSERT") end
local function delete_eol()    vim.motion.send_raw({ "SHIFT", "End" }, 1) vim.registers.handle_delete("CTRL", "x", "NORMAL") end
local function delete_before() vim.motion.send_raw({ "SHIFT", "LEFT" }, 1) vim.registers.handle_delete("CTRL", "x", "NORMAL") end
local function delete_under()  vim.motion.send_raw({ "SHIFT", "RIGHT" }, 1) vim.registers.handle_delete("CTRL", "x", "NORMAL") end
local function paste()         vim.registers.handle_paste("CTRL", "v", "NORMAL") end
local function indent_line()   send("", "HOME") send("", "tab") end
local function unindent_line() send("", "HOME") send("SHIFT", "tab") end

-- ── Misc ──────────────────────────────────────────────────────────────────────
local function line_start()     vim.count.clear() send("", "HOME") end
local function line_end()       vim.count.clear() send("", "END") end
local function last_line()      vim.count.clear() send("CTRL", "END") end
local function backspace_move() wk.close() vim.motion.send("h") end
local function escape_gui()     vim.count.clear() send("", "ESCAPE") end
local function escape_normal()  vim.count.clear() wk.close() vim.find.deactivate() Hypr.send("", "Escape", "active") end
local function exit_vim()       vim.count.clear() hl.dispatch(hl.dsp.submap("reset")) end
-- stylua: ignore end

Submap.define({
  name = "NORMAL",
  escape = false,
  catchall = "stay",
  binds = function()
    -- stylua: ignore start
    Bind.key("h",          vm("h"),                          "Left")
    Bind.key("j",          vm("j"),                          "Down")
    Bind.key("k",          vm("k"),                          "Up")
    Bind.key("l",          vm("l"),                          "Right")
    Bind.key("SHIFT + h",  vm("0", { clear_count = true }),  "Start of line")
    Bind.key("SHIFT + l",  vm("$", { clear_count = true }),  "End of line")
    Bind.key("SHIFT + j",  vm_keys({ { "CTRL", "DOWN" }, { "", "HOME" } }), "Down to next line start", { repeating = true })
    Bind.key("SHIFT + k",  vm_keys({ { "CTRL", "UP" },   { "", "HOME" } }), "Up to prev line start",   { repeating = true })
    Bind.key("CTRL + h",   vm("CTRL + h"), "Ctrl left",  { repeating = true })
    Bind.key("CTRL + j",   vm("CTRL + j"), "Ctrl down",  { repeating = true })
    Bind.key("CTRL + k",   vm("CTRL + k"), "Ctrl up",    { repeating = true })
    Bind.key("CTRL + l",   vm("CTRL + l"), "Ctrl right", { repeating = true })
    Bind.key("b",          vm("b"),  "Prev word",        { repeating = true })
    Bind.key("e",          vm("e"),  "Next end of word", { repeating = true })
    Bind.key("w",          vm("w"),  "Next word",        { repeating = true })
    Bind.key("SHIFT + b",  vm("B"),  "Prev WORD",        { repeating = true })
    Bind.key("SHIFT + e",  vm("E"),  "Next end of WORD", { repeating = true })
    Bind.key("SHIFT + w",  vm("W"),  "Next WORD",        { repeating = true })
    Bind.key("CTRL + d",   vm("CTRL + d"), "Scroll down", { repeating = true })
    Bind.key("CTRL + f",   vm("CTRL + f"), "Scroll down", { repeating = true })
    Bind.key("CTRL + e",   vm("CTRL + e"), "Scroll down", { repeating = true })
    Bind.key("CTRL + u",   vm("CTRL + u"), "Scroll up",   { repeating = true })
    Bind.key("CTRL + b",   vm("CTRL + b"), "Scroll up",   { repeating = true })
    Bind.key("CTRL + y",   vm("CTRL + y"), "Scroll up",   { repeating = true })
    Bind.key("SHIFT + BRACKETLEFT",  vm("{"), "Paragraph start", { repeating = true })
    Bind.key("SHIFT + BRACKETRIGHT", vm("}"), "Paragraph end",   { repeating = true })
    Bind.key("u",          vm("u"),        "Undo", { repeating = true })
    Bind.key("CTRL + r",   vm("CTRL + r"), "Redo", { repeating = true })
    -- stylua: ignore end

    for i = 1, 9 do
      local s = tostring(i)
      Bind.key(s, function() vim.count.append(s) end)
    end

    -- stylua: ignore start
    return {
      { "SPACE", wk.toggle },

      -- Mode switches
      { "G",                  Submap.switch("GOTO"),      "+Goto"           },
      { "C",                  Submap.switch("CHANGE"),    "+Change"         },
      { "Y",                  Submap.switch("YANK"),      "+Yank"           },
      { "D",                  Submap.switch("DELETE"),    "+Delete"         },
      { "V",                  Submap.switch("VISUAL"),    "+Visual"         },
      { "SHIFT + V",          Submap.switch("V-LINE"),    "+V-Line"         },
      { "SHIFT + APOSTROPHE", Submap.switch("REGISTERS"), "+Registers"      },
      { "M",          set_mark,  "+Set-Mark"        },
      { "APOSTROPHE", jump_mark, "+Marks"           },
      { "GRAVE",      goto_mark, "+Marks then exit" },

      -- Find
      { "f",             find.char_forward,    "Find char forward"        },
      { "SHIFT + f",     find.char_backward,   "Find char backward"       },
      { "t",             find.till_forward,    "Find till forward"        },
      { "SHIFT + t",     find.till_backward,   "Find till backward"       },
      { "n",             find.next_search,     "Next match"               },
      { "SHIFT + n",     find.prev_search,     "Prev match"               },
      { "SLASH",         find.search_forward,  "Search forward"           },
      { "SHIFT + SLASH", find.search_backward, "Search backward"          },
      { "SHIFT + 8",     find.forward_word,    "Search word forward (*)"  },
      { "SHIFT + 3",     find.backward_word,   "Search word backward (#)" },
      { "SEMICOLON",     find.next_char,       "Repeat find (;)"          },
      { "COMMA",         find.prev_char,       "Reverse find (,)"         },

      -- Commands
      { "R",                 vim.replace.character,  "Replace Char"     },
      { "SHIFT + R",         vim.replace.string,     "Replace Forward"  },
      { "SHIFT + SEMICOLON", cc(vim.command.prompt), "Command mode (:)" },

      -- Vim editor
      { LEADER .. " + N", open_vim_editor(),               "Edit in Vim (Normal)" },
      { LEADER .. " + I", open_vim_editor({ insert = true }), "Edit in Vim (Insert)" },

      -- Count: 0 is special (start-of-line vs digit)
      { "0", vim.count.handle_zero, "Start of line" },

      -- Line
      { "SHIFT + MINUS", line_start, "Start of line" },
      { "SHIFT + 6",     line_start, "Start of line" },
      { "SHIFT + 4",     line_end,   "End of line"   },
      { "SHIFT + g",     last_line,  "Last line"     },
      { "SHIFT + GRAVE", last_line,  "Last line"     },

      -- BackSpace
      { "BackSpace", backspace_move, nil, { repeating = true } },

      -- Insert mode
      { "i",                insert_at_cursor, "Insert before cursor"            },
      { "a",                insert_after,     "Insert after cursor"             },
      { "SHIFT + a",        insert_eol,       "Insert at end of line"           },
      { "SHIFT + i",        insert_bol,       "Insert at start of line"         },
      { "o",                open_below,       "Insert line below"               },
      { "SHIFT + o",        open_above,       "Insert line above"               },
      { "CTRL + o",         open_below_se,    "Insert line below (Shift+Enter)" },
      { "CTRL + SHIFT + o", open_above_se,    "Insert line above (Shift+Enter)" },

      -- Change / delete
      { "SHIFT + c", change_eol,    "Change to end of line"                    },
      { "SHIFT + d", delete_eol,    "Delete to end of line"                    },
      { "SHIFT + x", delete_before, "Delete char before", { repeating = true } },
      { "x",         delete_under,  "Delete char under",  { repeating = true } },

      -- Paste
      { "p",         paste, "Paste after cursor"  },
      { "SHIFT + p", paste, "Paste before cursor" },

      -- Indent
      { "SHIFT + PERIOD", indent_line,   "Indent line",   { repeating = true } },
      { "SHIFT + COMMA",  unindent_line, "Unindent line", { repeating = true } },

      -- GUI passthrough / helpers
      { "tab",         Bind.pass       },
      { "SHIFT + tab", Bind.pass       },
      { "RETURN",      Bind.pass       },
      { "q",           escape_gui },
      { "CTRL + q",    Submap.switch("NORMAL") },
      { "CTRL + c",    escape_gui },
      { "ALT + h",     vm("ALT + h") },
      { "ALT + j",     vm("ALT + j") },
      { "ALT + k",     vm("ALT + k") },
      { "ALT + l",     vm("ALT + l") },

      -- Escape (non-consuming: sends Escape to the active window)
      { "ESCAPE", escape_normal, "Escape", { non_consuming = true } },

      -- Global exit from vim mode
      { LEADER .. " + " .. EXIT, exit_vim, nil, { release = true } },
    }
    -- stylua: ignore end
  end,
}).setup()
