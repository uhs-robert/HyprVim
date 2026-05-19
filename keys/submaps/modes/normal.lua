-- keys/submaps/modes/normal.lua

local Submap = require("lib.submap") ---@class HyprVimSubmap
local Bind = require("lib.bind") ---@class HyprVimBindLib
local vim = require("vim") ---@class Vim
local wk = require("whichkey") ---@class WhichKey
local config = require("config") ---@class HyprVimConfigModule
local Hypr = require("hypr") ---@class HyprVimHyprland
local LEADER = config.keys.leader or "SUPER"
local EXIT = config.keys.exit or "ESCAPE"

local function send(mods, key, window) Hypr.send(mods, key, window) end
local function to(name)
  return function() hl.dispatch(hl.dsp.submap(name)) end
end
local function pass() hl.dispatch(hl.dsp.pass()) end
local function cc(fn)
  return function()
    vim.count.clear()
    fn()
  end
end

local function vm(key, opts)
  return function()
    if opts and opts.clear_count then vim.count.clear() end
    vim.motion.send(key)
  end
end

local function open_vim_editor(opts)
  return function()
    vim.count.clear()
    hl.dispatch(hl.dsp.submap("reset"))
    vim.editor.open({ copy_selected = true, insert_mode = (opts and opts.insert) or false })
  end
end

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
    Bind.key("SHIFT + j",  function() vim.motion.send_sequence({ { "CTRL", "DOWN" }, { "", "HOME" } }) end, "Down to next line start", { repeating = true })
    Bind.key("SHIFT + k",  function() vim.motion.send_sequence({ { "CTRL", "UP" },   { "", "HOME" } }) end, "Up to prev line start",   { repeating = true })
    Bind.key("CTRL + h",   function() vim.motion.send("CTRL + h") end, "Ctrl left",  { repeating = true })
    Bind.key("CTRL + j",   function() vim.motion.send("CTRL + j") end, "Ctrl down",  { repeating = true })
    Bind.key("CTRL + k",   function() vim.motion.send("CTRL + k") end, "Ctrl up",    { repeating = true })
    Bind.key("CTRL + l",   function() vim.motion.send("CTRL + l") end, "Ctrl right", { repeating = true })
    Bind.key("b",          function() vim.motion.send("b") end, "Prev word",     { repeating = true })
    Bind.key("e",          function() vim.motion.send_sequence({ { "", "RIGHT" }, { "CTRL", "RIGHT" }, { "", "LEFT" } }) end, "Next end of word", { repeating = true })
    Bind.key("w",          function() vim.motion.send("w") end, "Next word",     { repeating = true })
    Bind.key("SHIFT + b",  function() vim.motion.send("b") end, "Prev WORD",     { repeating = true })
    Bind.key("SHIFT + e",  function() vim.motion.send_sequence({ { "CTRL", "RIGHT" }, { "", "LEFT" } }) end, "Next end of WORD", { repeating = true })
    Bind.key("SHIFT + w",  function() vim.motion.send("w") end, "Next WORD",     { repeating = true })
    Bind.key("CTRL + d",   function() vim.motion.send("CTRL + d") end, "Scroll down", { repeating = true })
    Bind.key("CTRL + f",   function() vim.motion.send("CTRL + f") end, "Scroll down", { repeating = true })
    Bind.key("CTRL + e",   function() vim.motion.send("CTRL + e") end, "Scroll down", { repeating = true })
    Bind.key("CTRL + u",   function() vim.motion.send("CTRL + u") end, "Scroll up",   { repeating = true })
    Bind.key("CTRL + b",   function() vim.motion.send("CTRL + b") end, "Scroll up",   { repeating = true })
    Bind.key("CTRL + y",   function() vim.motion.send("CTRL + y") end, "Scroll up",   { repeating = true })
    Bind.key("SHIFT + BRACKETLEFT",  function() vim.motion.send("{") end, "Paragraph start", { repeating = true })
    Bind.key("SHIFT + BRACKETRIGHT", function() vim.motion.send("}") end, "Paragraph end",   { repeating = true })
    Bind.key("u",        function() vim.motion.send("u") end,        "Undo", { repeating = true })
    Bind.key("CTRL + r", function() vim.motion.send("CTRL + r") end, "Redo", { repeating = true })
    -- stylua: ignore end

    for i = 1, 9 do
      local s = tostring(i)
      Bind.key(s, function() vim.count.append(s) end)
    end

    return {
      -- Which-key
      { "SPACE", wk.toggle },

      -- Mode switches
      -- stylua: ignore start
      { "G",                    to("GOTO"),      "+Goto"           },
      { "C",                    to("CHANGE"),    "+Change"         },
      { "Y",                    to("YANK"),      "+Yank"           },
      { "D",                    to("DELETE"),    "+Delete"         },
      { "V",                    to("VISUAL"),    "+Visual"         },
      { "SHIFT + V",            to("V-LINE"),    "+V-Line"         },
      { "SHIFT + APOSTROPHE",   to("REGISTERS"), "+Registers"      },
      { "M",          function() vim.marks.set_after("NORMAL") hl.dispatch(hl.dsp.submap("SET-MARK")) end, "+Set-Mark"        },
      { "APOSTROPHE", function() vim.marks.set_after("NORMAL") hl.dispatch(hl.dsp.submap("MARKS")) end,   "+Marks"           },
      { "GRAVE",      function() vim.marks.set_after("reset")  hl.dispatch(hl.dsp.submap("MARKS")) end,   "+Marks then exit" },

      -- Commands
      { "R",                 vim.replace.character, "Replace Char"    },
      { "SHIFT + R",         vim.replace.string,    "Replace Forward" },
      { "SHIFT + SEMICOLON", cc(vim.command.prompt), "Command mode (:)" },

      -- Vim editor
      { LEADER .. " + N", open_vim_editor(),               "Edit in Vim (Normal)" },
      { LEADER .. " + I", open_vim_editor({ insert = true }), "Edit in Vim (Insert)" },

      -- Count: 0 is special (start-of-line vs digit)
      { "0", vim.count.handle_zero, "Start of line" },

      -- Line
      { "SHIFT + MINUS", cc(function() send("", "HOME") end),     "Start of line" },
      { "SHIFT + 6",     cc(function() send("", "HOME") end),     "Start of line" },
      { "SHIFT + 4",     cc(function() send("", "END")  end),     "End of line"   },
      { "SHIFT + g",     cc(function() send("CTRL", "END") end),  "Last line"     },
      { "SHIFT + GRAVE", cc(function() send("CTRL", "END") end),  "Last line"     },

      -- BackSpace: move cursor left + close whichkey
      { "BackSpace", function() wk.close() vim.motion.send("h") end, nil, { repeating = true } },

      -- Enter insert mode
      { "i",              function() vim.count.clear() hl.dispatch(hl.dsp.submap("INSERT")) end,                                                                           "Insert before cursor"          },
      { "a",              function() vim.count.clear() hl.dispatch(hl.dsp.submap("INSERT")) send("", "RIGHT") end,                                                         "Insert after cursor"           },
      { "SHIFT + a",      function() vim.count.clear() hl.dispatch(hl.dsp.submap("INSERT")) send("", "END") end,                                                           "Insert at end of line"         },
      { "SHIFT + i",      function() vim.count.clear() hl.dispatch(hl.dsp.submap("INSERT")) send("", "HOME") end,                                                          "Insert at start of line"       },
      { "o",              function() vim.count.clear() send("", "END") send("", "Return") hl.dispatch(hl.dsp.submap("INSERT")) end,                                        "Insert line below"             },
      { "SHIFT + o",      function() vim.count.clear() send("", "HOME") send("", "Return") send("", "Up") hl.dispatch(hl.dsp.submap("INSERT")) end,                       "Insert line above"             },
      { "CTRL + o",       function() vim.count.clear() send("", "END") send("SHIFT", "Return") hl.dispatch(hl.dsp.submap("INSERT")) end,                                   "Insert line below (Shift+Enter)"  },
      { "CTRL + SHIFT + o", function() vim.count.clear() send("", "HOME") send("SHIFT", "Return") send("", "Up") hl.dispatch(hl.dsp.submap("INSERT")) end,                "Insert line above (Shift+Enter)"  },

      -- Change / delete
      { "SHIFT + c", function() vim.count.clear() vim.motion.send_raw({ "SHIFT", "End" }, 1) vim.registers.handle_delete("CTRL", "x", "INSERT") end, "Change to end of line"    },
      { "SHIFT + d", function() vim.motion.send_raw({ "SHIFT", "End" }, 1) vim.registers.handle_delete("CTRL", "x", "NORMAL") end,                   "Delete to end of line"    },
      { "SHIFT + x", function() vim.motion.send_raw({ "SHIFT", "LEFT" }, 1) vim.registers.handle_delete("CTRL", "x", "NORMAL") end, "Delete char before", { repeating = true } },
      { "x",         function() vim.motion.send_raw({ "SHIFT", "RIGHT" }, 1) vim.registers.handle_delete("CTRL", "x", "NORMAL") end, "Delete char under",  { repeating = true } },

      -- Paste
      { "p",         function() vim.registers.handle_paste("CTRL", "v", "NORMAL") end, "Paste after cursor"  },
      { "SHIFT + p", function() vim.registers.handle_paste("CTRL", "v", "NORMAL") end, "Paste before cursor" },

      -- Indent
      { "SHIFT + PERIOD", function() send("", "HOME") send("", "tab") end,      "Indent line",   { repeating = true } },
      { "SHIFT + COMMA",  function() send("", "HOME") send("SHIFT", "tab") end, "Unindent line", { repeating = true } },

      -- GUI passthrough / helpers
      { "tab",               function() pass() end },
      { "SHIFT + tab",       function() pass() end },
      { "RETURN",            function() pass() end },
      { "q",                 function() vim.count.clear() send("", "ESCAPE") end },
      { "CTRL + q",          to("NORMAL") },
      { "CTRL + c",          function() vim.count.clear() send("", "ESCAPE") end },
      { "ALT + h",           function() vim.motion.send("ALT + h") end },
      { "ALT + j",           function() vim.motion.send("ALT + j") end },
      { "ALT + k",           function() vim.motion.send("ALT + k") end },
      { "ALT + l",           function() vim.motion.send("ALT + l") end },
      -- stylua: ignore end

      -- ESCAPE: non-consuming; sends Escape to the active window
      {
        "ESCAPE",
        function()
          vim.count.clear()
          wk.close()
          vim.find.deactivate()
          Hypr.send("", "Escape", "active")
        end,
        "Escape",
        { non_consuming = true },
      },

      -- Global exit from vim mode (release flag matches original Bind.shortcut behaviour)
      {
        LEADER .. " + " .. EXIT,
        function()
          vim.count.clear()
          hl.dispatch(hl.dsp.submap("reset"))
        end,
        nil,
        { release = true },
      },
    }
  end,
}).setup()
