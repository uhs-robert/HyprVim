-- keys/submaps/modes/g-visual.lua

local vim = require("vim") ---@class vim
local count = vim.count
local motion = vim.motion
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
local function send(mods, key, window)
  hl.dispatch(hl.dsp.send_shortcut({ mods = mods, key = key, window = window }))
end
local function submap(n)
  hl.dispatch(hl.dsp.submap(n))
end

hl.define_submap("G-VISUAL", "reset", function()
  bd("e", "Prev end of word", function()
    motion.send_sequence({ { "CTRL", "LEFT" }, { "", "LEFT" } })
    submap("VISUAL")
  end)
  bd("g", "First line", function()
    send("CTRL SHIFT", "HOME")
    submap("VISUAL")
  end)
  bd("SHIFT + g", "Last line", function()
    send("CTRL SHIFT", "END")
    submap("VISUAL")
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
    submap("VISUAL")
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
    submap("G-VISUAL")
  end)
  -- b("SHIFT + catchall",     function() submap("G-VISUAL") end)
end)
