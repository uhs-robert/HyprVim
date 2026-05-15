-- keys/submaps/modes/g-motion.lua

local vim = require("vim") ---@class Vim
local count = vim.count
local motion = vim.motion
local wk = require("whichkey") ---@class WhichKey

local leader = (require("config").keys or {}).leader or "SUPER"
local act = (require("config").keys or {}).activate or "ESCAPE"

local function b(keys, fn) hl.bind(keys, fn) end
local function bd(keys, desc, fn) hl.bind(keys, fn, { description = desc }) end
local function send(mods, key, window) hl.dispatch(hl.dsp.send_shortcut({ mods = mods, key = key, window = window })) end
local function submap(n) hl.dispatch(hl.dsp.submap(n)) end

hl.define_submap("G-MOTION", "reset", function()
  bd("e", "Prev end of word", function()
    motion.send_sequence({ { "CTRL", "LEFT" }, { "CTRL", "LEFT" }, { "CTRL", "RIGHT" }, { "", "LEFT" } })
    submap("NORMAL")
  end)
  bd("SHIFT + t", "Go to prev tab", function()
    send("CTRL", "PAGE_UP")
    submap("NORMAL")
  end)
  bd("t", "Go to next tab", function()
    send("CTRL", "PAGE_DOWN")
    submap("NORMAL")
  end)
  bd("g", "Go to doc start", function()
    submap("NORMAL")
    send("CTRL", "HOME")
  end)
  bd("SHIFT + g", "Go to last line", function()
    send("CTRL", "END")
    submap("NORMAL")
  end)
  bd("h", "Help", function()
    count.clear()
    hl.dispatch(hl.dsp.submap("reset"))
    local Config = require("config") ---@class HyprVimConfigModule
    hl.dispatch(hl.dsp.exec_cmd(Config.term_cmd("floating-help") .. " hyprvim-help"))
    submap("NORMAL")
  end)
  bd("m", "Marks list", function()
    count.clear()
    vim.marks.list()
    submap("NORMAL")
  end)

  b("ESCAPE", function() submap("NORMAL") end)
  b(leader .. " + " .. act, function() hl.dispatch(hl.dsp.submap("reset")) end)
  b("BackSpace", function()
    wk.close()
    submap("NORMAL")
  end)
  b("SPACE", function() wk.toggle() end)
  b("catchall", function() submap("G-MOTION") end)
  -- b("SHIFT + catchall",     function() submap("G-MOTION") end)
end)
