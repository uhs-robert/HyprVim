-- keys/submaps/modes/visual.lua
-- VISUAL, V-I, V-A submaps

local vim = require("vim") ---@class vim
local motion = vim.motion
local count = vim.count
local lm = vim.line_motion
local reg = vim.registers
local wk = require("whichkey") ---@class WhichKey
local oe = vim.editor

local leader = (require("config").keys or {}).leader or "SUPER"
local act = (require("config").keys or {}).activate or "ESCAPE"

local function b(keys, fn, opts) hl.bind(keys, fn, opts) end
local function bd(keys, desc, fn) hl.bind(keys, fn, { description = desc }) end
local function be(keys, fn) hl.bind(keys, fn, { repeating = true }) end
local function bde(keys, desc, fn) hl.bind(keys, fn, { description = desc, repeating = true }) end
local function send(mods, key, window) hl.dispatch(hl.dsp.send_shortcut({ mods = mods, key = key, window = window })) end
local function submap(n) hl.dispatch(hl.dsp.submap(n)) end

-- ---------------------------------------------------------------------------
-- VISUAL
-- ---------------------------------------------------------------------------
hl.define_submap("VISUAL", function()
  -- Count
  bd("0", "Start of line", function() count.handle_zero_visual() end)
  for i = 1, 9 do
    b(tostring(i), function() count.append(tostring(i)) end)
  end

  -- Mode switches
  b("g", function() submap("G-VISUAL") end)
  b("SHIFT + v", function() lm.enter() end)
  -- b("v", function() submap("VISUAL") end)

  -- Editor
  bd(leader .. " + n", "Edit in Vim (Normal)", function()
    count.clear()
    hl.dispatch(hl.dsp.submap("reset"))
    oe.open({ copy_selected = true })
  end)
  bd(leader .. " + i", "Edit in Vim (Insert)", function()
    count.clear()
    hl.dispatch(hl.dsp.submap("reset"))
    oe.open({ copy_selected = true, insert_mode = true })
  end)

  -- Char motions
  bde("h", "Left", function() motion.send_raw({ "SHIFT", "LEFT" }, count.get()) end)
  bde("j", "Down", function() motion.send_raw({ "SHIFT", "DOWN" }, count.get()) end)
  bde("k", "Up", function() motion.send_raw({ "SHIFT", "UP" }, count.get()) end)
  bde("l", "Right", function() motion.send_raw({ "SHIFT", "RIGHT" }, count.get()) end)
  bde("SHIFT + h", "H", function() motion.send_raw({ "SHIFT", "HOME" }, count.get()) end)
  bde("SHIFT + j", "J", function() motion.send_raw({ "CTRL SHIFT", "DOWN" }, count.get()) end)
  bde("SHIFT + k", "K", function() motion.send_raw({ "CTRL SHIFT", "UP" }, count.get()) end)
  bde("SHIFT + l", "L", function() motion.send_raw({ "SHIFT", "END" }, count.get()) end)

  -- Word
  bde("b", "Prev word", function() motion.send_raw({ "CTRL SHIFT", "LEFT" }, count.get()) end)
  bde("e", "Next end word", function() motion.send_raw({ "CTRL SHIFT", "RIGHT" }, count.get()) end)
  bde("w", "Next word", function() motion.send_raw({ "CTRL SHIFT", "RIGHT" }, count.get()) end)
  be("SHIFT + b", function() motion.send_raw({ "CTRL SHIFT", "LEFT" }, count.get()) end)
  be("SHIFT + e", function() motion.send_raw({ "CTRL SHIFT", "RIGHT" }, count.get()) end)
  be("SHIFT + w", function() motion.send_raw({ "CTRL SHIFT", "RIGHT" }, count.get()) end)

  -- Paragraph
  bde(
    "SHIFT + BRACKETLEFT",
    "Paragraph start",
    function() motion.send_sequence({ { "SHIFT", "HOME" }, { "CTRL SHIFT", "UP" } }) end
  )
  bde(
    "SHIFT + BRACKETRIGHT",
    "Paragraph end",
    function() motion.send_sequence({ { "SHIFT", "END" }, { "CTRL SHIFT", "DOWN" } }) end
  )

  -- Line / page
  bde("SHIFT + MINUS", "Start of line", function() send("SHIFT", "HOME") end)
  bde("SHIFT + 4", "End of line", function() send("SHIFT", "END") end)
  bde("CTRL + e", "Page down", function() send("SHIFT", "PAGE_DOWN") end)
  bde("CTRL + y", "Page up", function() send("SHIFT", "PAGE_UP") end)
  bde("SHIFT + g", "Last line", function() send("CTRL SHIFT", "END") end)

  -- Undo
  bde("u", "Undo", function() motion.send("u") end)
  be("SHIFT + u", function() motion.send("u") end)
  bde("CTRL + r", "Redo", function() motion.send("CTRL + r") end)

  -- Change / delete / yank / paste
  bd("c", "Change", function() reg.handle_delete("CTRL", "x", "INSERT") end)
  bde("SHIFT + x", "BackSpace", function()
    wk.close()
    reg.handle_delete("", "BackSpace", "NORMAL")
  end)
  be("x", function() reg.handle_delete("CTRL", "x", "NORMAL") end)
  bde("d", "Delete", function() reg.handle_delete("CTRL", "x", "NORMAL") end)
  bde("SHIFT + d", "Delete to line start", function()
    send("SHIFT", "HOME")
    send("", "Delete")
    submap("NORMAL")
  end)
  bd("y", "Yank", function() reg.handle_yank("CTRL", "c", "NORMAL") end)
  bd("SHIFT + y", "Yank to line start", function()
    motion.send_sequence({ { "", "END" }, { "SHIFT", "HOME" } })
    reg.handle_yank("CTRL", "c", "NORMAL")
  end)
  bde("p", "Paste", function() reg.handle_paste("CTRL", "v", "NORMAL") end)
  be("SHIFT + p", function() reg.handle_paste("CTRL", "v", "NORMAL") end)

  -- Normal shortcuts passthrough
  be("CTRL + x", function()
    send("CTRL", "x")
    submap("NORMAL")
  end)
  be("CTRL + p", function()
    send("CTRL", "v")
    submap("NORMAL")
  end)
  be("CTRL + v", function()
    send("CTRL", "v")
    submap("NORMAL")
  end)
  be("CTRL + b", function() send("CTRL", "b") end)
  be("CTRL + i", function() send("CTRL", "i") end)
  be("CTRL + u", function() send("CTRL", "u") end)
  be("CTRL + s", function() send("CTRL", "s") end)

  -- Sub-submaps
  bd("i", "+Inner", function() submap("V-I") end)
  b("SHIFT + i", function() submap("V-I") end)
  bd("a", "+Around", function() submap("V-A") end)
  b("SHIFT + a", function() submap("V-A") end)

  -- Exit / catchall
  b(leader .. " + " .. act, function() hl.dispatch(hl.dsp.submap("reset")) end)
  b("ESCAPE", function()
    send("", "Left")
    send("", "Right")
    submap("NORMAL")
  end)
  b("BackSpace", function()
    wk.close()
    submap("NORMAL")
  end)
  b("SPACE", function() wk.toggle() end)
  b("catchall", function() end, { release = true, ignore_mods = true })
end)

-- ---------------------------------------------------------------------------
-- V-I (inner text objects in visual)
-- ---------------------------------------------------------------------------
hl.define_submap("V-I", "VISUAL", function()
  bd("w", "Word", function()
    motion.send_sequence({ { "CTRL", "RIGHT" }, { "CTRL SHIFT", "LEFT" } })
    submap("VISUAL")
  end)
  b("SHIFT + w", function()
    motion.send_sequence({ { "CTRL", "RIGHT" }, { "CTRL SHIFT", "LEFT" } })
    submap("VISUAL")
  end)
  bd("p", "Paragraph", function()
    motion.send_sequence({ { "", "END" }, { "CTRL", "UP" }, { "CTRL SHIFT", "DOWN" } })
    submap("VISUAL")
  end)
  b("SHIFT + p", function()
    motion.send_sequence({ { "", "END" }, { "CTRL", "UP" }, { "CTRL SHIFT", "DOWN" } })
    submap("VISUAL")
  end)
  b(leader .. " + " .. act, function() hl.dispatch(hl.dsp.submap("reset")) end)
  b("ESCAPE", function() submap("NORMAL") end)
  b("BackSpace", function()
    wk.close()
    submap("VISUAL")
  end)
  b("SPACE", function() wk.toggle() end)
  b("catchall", function() submap("VISUAL") end)
end)

-- ---------------------------------------------------------------------------
-- V-A (around text objects in visual)
-- ---------------------------------------------------------------------------
hl.define_submap("V-A", "VISUAL", function()
  bd("w", "Word", function()
    motion.send_sequence({ { "CTRL", "LEFT" }, { "CTRL SHIFT", "RIGHT" } })
    submap("VISUAL")
  end)
  b("SHIFT + w", function()
    motion.send_sequence({ { "CTRL", "LEFT" }, { "CTRL SHIFT", "RIGHT" } })
    submap("VISUAL")
  end)
  bd("p", "Paragraph", function()
    motion.send_sequence({ { "", "END" }, { "CTRL", "UP" }, { "CTRL SHIFT", "DOWN" } })
    submap("VISUAL")
  end)
  b("SHIFT + p", function()
    motion.send_sequence({ { "", "END" }, { "CTRL", "UP" }, { "CTRL SHIFT", "DOWN" } })
    submap("VISUAL")
  end)
  b(leader .. " + " .. act, function() hl.dispatch(hl.dsp.submap("reset")) end)
  b("ESCAPE", function() submap("NORMAL") end)
  b("BackSpace", function()
    wk.close()
    submap("VISUAL")
  end)
  b("SPACE", function() wk.toggle() end)
  b("catchall", function() submap("VISUAL") end)
end)
