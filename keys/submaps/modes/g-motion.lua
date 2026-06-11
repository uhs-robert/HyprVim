-- keys/submaps/modes/g-motion.lua

local Submap = require("lib.submap") ---@class HyprVimSubmap
local Bind = require("lib.bind") ---@class HyprVimBindLib
local vim = require("vim") ---@class Vim
local wk = require("whichkey") ---@class WhichKey
local Hypr = require("hypr") ---@class HyprVimHyprland
local config = require("config") ---@class HyprVimConfigModule
local LEADER = config.keys.leader or "SUPER"
local ACT = config.keys.activate or "ESCAPE"
local EXIT = config.keys.exit or "ESCAPE"

local function send(mods, key) hl.dispatch(hl.dsp.send_shortcut({ mods = mods, key = key })) end
local function normal() Submap.enter("NORMAL") end

Submap.define({
  name = "GOTO",
  escape = "NORMAL",
  back = function()
    wk.close()
    normal()
  end,
  catchall = "stay",
  binds = {
    -- stylua: ignore start
    { "e",          function() vim.motion.send_sequence({ { "CTRL", "LEFT" }, { "CTRL", "LEFT" }, { "CTRL", "RIGHT" }, { "", "LEFT" } }) normal() end, "Prev end of word" },
    { "SHIFT + t",  function() send("CTRL", "PAGE_UP")   normal() end, "Prev tab"   },
    { "t",          function() send("CTRL", "PAGE_DOWN") normal() end, "Next tab"   },
    { "g",          function() send("CTRL", "HOME")      normal() end, "Doc start"  },
    { "SHIFT + g",  function() send("CTRL", "END")       normal() end, "Last line"  },
    { "m",          function() vim.count.clear() vim.marks.list() normal() end, "Marks list" },
    { "SPACE",      wk.toggle },
    { LEADER .. " + " .. ACT, Hypr.exit_vim },
    { LEADER .. " + " .. EXIT, Hypr.exit_vim },
    -- stylua: ignore end
  },
}).setup()
