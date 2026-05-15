-- keys/submaps/modes/normal.lua

local vim = require("vim") ---@class vim
local wk = require("whichkey") ---@class WhichKey
local config = require("config") ---@class config

local leader, exit = config.keys.leader, config.keys.exit

-- TODO: Make sure basic normal commands work without crashing.

---@param keys string
---@param fn function
---@param opts table|nil
local function b(keys, fn, opts)
  hl.bind(keys, fn, opts)
  hl.bind(keys, fn, { release = true }) --BUG: Remove when this is resolved: https://github.com/hyprwm/Hyprland/discussions/14445
end
---@param keys string
---@param desc string
---@param fn function
local function bd(keys, desc, fn)
  hl.bind(keys, fn, { description = desc })
  hl.bind(keys, fn, { release = true }) --BUG: Remove when this is resolved: https://github.com/hyprwm/Hyprland/discussions/14445
end
---@param keys string
---@param fn function
local function be(keys, fn)
  hl.bind(keys, fn, { repeating = true })
  hl.bind(keys, fn, { release = true }) --BUG: Remove when this is resolved: https://github.com/hyprwm/Hyprland/discussions/14445
end
---@param keys string
---@param desc string
---@param fn function
local function bde(keys, desc, fn)
  hl.bind(keys, fn, { description = desc, repeating = true })
  hl.bind(keys, fn, { release = true }) --BUG: Remove when this is resolved: https://github.com/hyprwm/Hyprland/discussions/14445
end
local function send(mods, key, window) hl.dispatch(hl.dsp.send_shortcut({ mods = mods, key = key, window = window })) end
local function submap(n) hl.dispatch(hl.dsp.submap(n)) end
local function pass() hl.dispatch(hl.dsp.pass()) end

hl.define_submap("NORMAL", function()
  -- Which-key
  b("SPACE", function() wk.toggle() end)

  -- Mode switches
  bd("v", "+Visual", function()
    vim.count.clear()
    submap("VISUAL")
  end)
  bd("SHIFT + v", "+V-Line", function()
    vim.count.clear()
    vim.line_motion.enter()
  end)
  bd("g", "+Go", function() submap("G-MOTION") end)
  bd("c", "+Change", function() submap("C-MOTION") end)
  bd("y", "+Yank", function() submap("Y-MOTION") end)
  bd("d", "+Delete", function() submap("D-MOTION") end)
  bd("r", "Replace char", function() vim.replace.character() end)
  bd("SHIFT + r", "Replace forward", function() vim.replace.string() end)
  bd("m", "+Mark", function()
    vim.marks.set_after("NORMAL")
    submap("SET-MARK")
  end)
  bd("APOSTROPHE", "+Jump to Mark", function()
    vim.count.clear()
    vim.marks.set_after("NORMAL")
    submap("JUMP-MARK")
  end)
  bd("GRAVE", "+Jump to Mark Exit", function()
    vim.count.clear()
    vim.marks.set_after("reset")
    submap("JUMP-MARK")
  end)
  bd("SHIFT + APOSTROPHE", "+Register", function() submap("GET-REGISTER") end)
  bd("SHIFT + SEMICOLON", "Command mode (:)", function()
    vim.count.clear()
    vim.command.prompt()
  end)

  -- Editor
  bd(leader .. " + n", "Edit in Vim (Normal)", function()
    vim.count.clear()
    hl.dispatch(hl.dsp.submap("reset"))
    vim.editor.open({ copy_selected = true })
  end)
  bd(leader .. " + i", "Edit in Vim (Insert)", function()
    vim.count.clear()
    hl.dispatch(hl.dsp.submap("reset"))
    vim.editor.open({ copy_selected = true, insert_mode = true })
  end)

  -- Count
  hl.bind("0", function() vim.count.handle_zero() end, { description = "Start of line" })
  for i = 1, 9 do
    hl.bind(tostring(i), function() vim.count.append(tostring(i)) end)
  end

  -- Char motions
  bde("h", "Left", function() vim.motion.send("h") end)
  bde("j", "Down", function() vim.motion.send("j") end)
  bde("k", "Up", function() vim.motion.send("k") end)
  bde("l", "Right", function() vim.motion.send("l") end)
  bd("SHIFT + h", "Start of line", function()
    vim.count.clear()
    vim.motion.send("HOME")
    send("", "HOME")
  end)
  bd("SHIFT + l", "End of line", function()
    vim.count.clear()
    send("", "END")
  end)
  bde(
    "SHIFT + j",
    "Down to next line start",
    function() vim.motion.send_sequence({ { "CTRL", "DOWN" }, { "", "HOME" } }) end
  )
  bde(
    "SHIFT + k",
    "Up to prev line start",
    function() vim.motion.send_sequence({ { "CTRL", "UP" }, { "", "HOME" } }) end
  )
  bde("CTRL + h", "Ctrl left", function() vim.motion.send("CTRL + h") end)
  bde("CTRL + j", "Ctrl down", function() vim.motion.send("CTRL + j") end)
  bde("CTRL + k", "Ctrl up", function() vim.motion.send("CTRL + k") end)
  bde("CTRL + l", "Ctrl right", function() vim.motion.send("CTRL + l") end)
  be("BackSpace", function()
    wk.close()
    vim.motion.send("h")
  end)

  -- Word motions
  bde("b", "Prev word", function() vim.motion.send("b") end)
  bde(
    "e",
    "Next end of word",
    function() vim.motion.send_sequence({ { "", "RIGHT" }, { "CTRL", "RIGHT" }, { "", "LEFT" } }) end
  )
  bde("w", "Next word", function() vim.motion.send("w") end)
  bde("SHIFT + b", "Prev WORD", function() vim.motion.send("b") end)
  bde("SHIFT + e", "Next end of WORD", function() vim.motion.send_sequence({ { "CTRL", "RIGHT" }, { "", "LEFT" } }) end)
  bde("SHIFT + w", "Next WORD", function() vim.motion.send("w") end)

  -- Line
  bd("SHIFT + MINUS", "Start of line", function()
    vim.count.clear()
    send("", "HOME")
  end)
  bd("SHIFT + 6", "Start of line", function()
    vim.count.clear()
    send("", "HOME")
  end)
  bd("SHIFT + 4", "End of line", function()
    vim.count.clear()
    send("", "END")
  end)

  -- Page
  bd("SHIFT + g", "Last line", function()
    vim.count.clear()
    send("CTRL", "END")
  end)
  bd("SHIFT + GRAVE", "Last line", function()
    vim.count.clear()
    send("CTRL", "END")
  end)
  bde("CTRL + d", "Scroll down", function() vim.motion.send("CTRL + d") end)
  bde("CTRL + f", "Scroll down", function() vim.motion.send("CTRL + f") end)
  bde("CTRL + e", "Scroll down", function() vim.motion.send("CTRL + e") end)
  bde("CTRL + u", "Scroll up", function() vim.motion.send("CTRL + u") end)
  bde("CTRL + b", "Scroll up", function() vim.motion.send("CTRL + b") end)
  bde("CTRL + y", "Scroll up", function() vim.motion.send("CTRL + y") end)

  -- Paragraph
  bde("SHIFT + BRACKETLEFT", "Paragraph start", function() vim.motion.send("{") end)
  bde("SHIFT + BRACKETRIGHT", "Paragraph end", function() vim.motion.send("}") end)

  -- Undo
  bde("u", "Undo", function() vim.motion.send("u") end)
  bde("CTRL + r", "Redo", function() vim.motion.send("CTRL + r") end)

  -- Find
  bd("SLASH", "Search forward", function()
    vim.count.clear()
    -- vim.find.search_forward() -- FIX: Find needs to be vetted and tested
  end)
  bd("SHIFT + SLASH", "Search backward", function()
    vim.count.clear()
    -- vim.find.search_backward()
  end)
  bd("SHIFT + 8", "Search word forward", function()
    vim.count.clear()
    -- vim.find.forward_word()
  end)
  bd("f", "Find forward", function()
    vim.count.clear()
    -- vim.find.char_forward()
  end)
  bd("t", "Find till forward", function()
    vim.count.clear()
    -- vim.find.char_till_forward()
  end)
  bd("n", "Find next match", function()
    vim.count.clear()
    -- vim.find.next_search()
  end)
  bd("SHIFT + n", "Find prev match", function()
    vim.count.clear()
    -- vim.find.prev_search()
  end)
  bd("SEMICOLON", "Repeat find", function()
    vim.count.clear()
    -- vim.find.next_char()
  end)
  b("SHIFT + 3", function()
    vim.count.clear()
    -- vim.find.backward_word()
  end)
  b("SHIFT + f", function()
    vim.count.clear()
    -- vim.find.char_backward()
  end)
  b("SHIFT + t", function()
    vim.count.clear()
    -- vim.find.char_till_backward()
  end)
  b("COMMA", function()
    vim.count.clear()
    -- vim.find.prev_char()
  end)

  -- Enter insert
  bd("i", "Insert before cursor", function()
    vim.count.clear()
    submap("INSERT")
  end)
  bd("a", "Insert after cursor", function()
    vim.count.clear()
    submap("INSERT")
    send("", "RIGHT")
  end)
  bd("SHIFT + a", "Insert at end of line", function()
    vim.count.clear()
    submap("INSERT")
    send("", "END")
  end)
  bd("SHIFT + i", "Insert at start of line", function()
    vim.count.clear()
    submap("INSERT")
    send("", "HOME")
  end)

  -- Open new line
  bd("o", "Insert line below", function()
    vim.count.clear()
    send("", "END")
    send("", "Return")
    submap("INSERT")
  end)
  bd("SHIFT + o", "Insert line above", function()
    vim.count.clear()
    send("", "HOME")
    send("", "Return")
    send("", "Up")
    submap("INSERT")
  end)
  bd("CTRL + o", "Insert line below (Shift+Enter)", function()
    vim.count.clear()
    send("", "END")
    send("SHIFT", "Return")
    submap("INSERT")
  end)
  bd("CTRL + SHIFT + o", "Insert line above (Shift+Enter)", function()
    vim.count.clear()
    send("", "HOME")
    send("SHIFT", "Return")
    send("", "Up")
    submap("INSERT")
  end)

  -- Change / delete
  bd("SHIFT + c", "Change to end of line", function()
    vim.count.clear()
    vim.motion.send_raw({ "SHIFT", "End" }, 1)
    vim.registers.handle_delete("CTRL", "x", "INSERT")
  end)
  bd("SHIFT + d", "Delete to end of line", function()
    vim.motion.send_raw({ "SHIFT", "End" }, 1)
    vim.registers.handle_delete("CTRL", "x", "NORMAL")
  end)
  bde("SHIFT + x", "Delete char before", function()
    vim.motion.send_raw({ "SHIFT", "LEFT" }, 1)
    vim.registers.handle_delete("CTRL", "x", "NORMAL")
  end)
  bde("x", "Delete char under", function()
    vim.motion.send_raw({ "SHIFT", "RIGHT" }, 1)
    vim.registers.handle_delete("CTRL", "x", "NORMAL")
  end)

  -- Paste
  bd("p", "Paste after cursor", function() vim.registers.handle_paste("CTRL", "v", "NORMAL") end)
  bd("SHIFT + p", "Paste before cursor", function() vim.registers.handle_paste("CTRL", "v", "NORMAL") end)

  -- Indent
  bde("SHIFT + PERIOD", "Indent line", function()
    send("", "HOME")
    send("", "tab")
  end)
  bde("SHIFT + COMMA", "Unindent line", function()
    send("", "HOME")
    send("SHIFT", "tab")
  end)

  -- GUI passthrough / helpers
  b("tab", function() pass() end)
  b("SHIFT + tab", function() pass() end)
  b("RETURN", function() pass() end)
  b("q", function()
    vim.count.clear()
    send("", "ESCAPE")
  end)
  b("CTRL + q", function() submap("NORMAL") end)
  b("CTRL + c", function()
    vim.count.clear()
    send("", "ESCAPE")
  end)
  b("ALT + h", function() vim.motion.send("ALT + h") end)
  b("ALT + j", function() vim.motion.send("ALT + j") end)
  b("ALT + k", function() vim.motion.send("ALT + k") end)
  b("ALT + l", function() vim.motion.send("ALT + l") end)

  -- Escape
  b("ESCAPE", function()
    vim.count.clear()
    wk.close()
    vim.find.deactivate()
    hl.dispatch(hl.dsp.send_shortcut({ mods = "", key = "Escape", window = "active" }))
  end, { non_consuming = true })

  -- Exit / catchall
  b(leader .. " + " .. exit, function()
    vim.count.clear()
    hl.dispatch(hl.dsp.submap("reset"))
  end, { release = true })

  b("catchall", function() end, { release = true, ignore_mods = true })
end)
