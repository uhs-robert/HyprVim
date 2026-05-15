-- keys/submaps/modes/v-line.lua
-- V-LINE, G-VLINE submaps

local vim = require("vim") ---@class vim
local motion = vim.motion
local count = vim.count
local lm = vim.line_motion
local reg = vim.registers
local wk = require("whichkey") ---@class WhichKey
local oe = vim.editor

local leader = (require("config").keys or {}).leader or "SUPER"
local act = (require("config").keys or {}).activate or "ESCAPE"

local function b(keys, fn)
  hl.bind(keys, fn)
end
local function bd(keys, desc, fn)
  hl.bind(keys, fn, { description = desc })
end
local function be(keys, fn)
  hl.bind(keys, fn, { repeating = true })
end
local function bde(keys, desc, fn)
  hl.bind(keys, fn, { description = desc, repeating = true })
end
local function send(mods, key, window)
  hl.dispatch(hl.dsp.send_shortcut({ mods = mods, key = key, window = window }))
end
local function submap(n)
  hl.dispatch(hl.dsp.submap(n))
end

-- ---------------------------------------------------------------------------
-- V-LINE
-- ---------------------------------------------------------------------------
hl.define_submap("V-LINE", "reset", function()
  -- Count (plain append for all digits, no handle_zero)
  for i = 0, 9 do
    b(tostring(i), function()
      count.append(tostring(i))
    end)
  end

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

  -- Motions
  bde("j", "Down", function()
    lm.down(count.get())
  end)
  bde("k", "Up", function()
    lm.up(count.get())
  end)
  bd("SHIFT + BRACKETLEFT", "Prev paragraph", function()
    lm.paragraph_up(count.get())
  end)
  bd("SHIFT + BRACKETRIGHT", "Next paragraph", function()
    lm.paragraph_down(count.get())
  end)
  bde("CTRL + e", "Page down", function()
    send("SHIFT", "PAGE_DOWN")
  end)
  bde("CTRL + y", "Page up", function()
    send("SHIFT", "PAGE_UP")
  end)
  bde("SHIFT + g", "Last line", function()
    lm.goto_end()
    submap("V-LINE")
  end)

  -- Undo
  bde("u", "Undo", function()
    motion.send("u")
  end)
  bde("CTRL + r", "Redo", function()
    motion.send("CTRL + r")
  end)

  -- Change / delete / yank / paste
  b("c", function()
    lm.reset()
    reg.handle_delete("CTRL", "x", "INSERT")
  end)
  bde("SHIFT + x", "BackSpace", function()
    wk.close()
    lm.reset()
    reg.handle_delete("", "BackSpace", "NORMAL")
  end)
  be("x", function()
    lm.reset()
    reg.handle_delete("CTRL", "x", "NORMAL")
  end)
  bde("d", "Delete", function()
    lm.reset()
    reg.handle_delete("CTRL", "x", "NORMAL")
  end)
  bde("SHIFT + d", "Delete to line start", function()
    lm.reset()
    send("SHIFT", "HOME")
    send("", "Delete")
    submap("NORMAL")
  end)
  bde("y", "Yank", function()
    lm.reset()
    reg.handle_yank("CTRL", "c", "NORMAL")
  end)
  bde("p", "Paste", function()
    reg.handle_paste("CTRL", "v", "NORMAL")
  end)

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

  -- Formatting
  be("CTRL + b", function()
    send("CTRL", "b")
  end)
  be("CTRL + i", function()
    send("CTRL", "i")
  end)
  be("CTRL + u", function()
    send("CTRL", "u")
  end)
  be("CTRL + s", function()
    send("CTRL", "s")
  end)

  -- G-VLINE submap
  bd("g", "+Go Line", function()
    submap("G-VLINE")
  end)
  b("SHIFT + i", function()
    submap("G-VLINE")
  end)

  -- Exit / catchall
  b(leader .. " + " .. act, function()
    lm.reset()
    hl.dispatch(hl.dsp.submap("reset"))
  end)
  b("ESCAPE", function()
    lm.reset()
    send("", "Left")
    send("", "Right")
    submap("NORMAL")
  end)
  b("BackSpace", function()
    wk.close()
    submap("VISUAL")
  end)
  b("SPACE", function()
    wk.toggle()
  end)
  b("catchall", function()
    submap("V-LINE")
  end)
  -- b("SHIFT + catchall", function() submap("V-LINE") end)
end)

-- ---------------------------------------------------------------------------
-- G-VLINE
-- ---------------------------------------------------------------------------
hl.define_submap("G-VLINE", "V-LINE", function()
  bd("g", "First line", function()
    lm.goto_start()
    submap("V-LINE")
  end)
  bd("SHIFT + g", "Last line", function()
    lm.goto_end()
    submap("V-LINE")
  end)
  bd("n", "Edit in Vim (Normal)", function()
    count.clear()
    hl.dispatch(hl.dsp.submap("reset"))
    oe.open({ copy_selected = true })
  end)
  bd("i", "Edit in Vim (Insert)", function()
    count.clear()
    hl.dispatch(hl.dsp.submap("reset"))
    oe.open({ copy_selected = true, insert_mode = true })
  end)
  b("ESCAPE", function()
    submap("NORMAL")
  end)
  b(leader .. " + " .. act, function()
    hl.dispatch(hl.dsp.submap("reset"))
  end)
  b("BackSpace", function()
    wk.close()
    submap("VISUAL")
  end)
  b("SPACE", function()
    wk.toggle()
  end)
  b("catchall", function()
    submap("G-VLINE")
  end)
  -- b("SHIFT + catchall", function()
  --   submap("G-VLINE")
  -- end)
end)
