-- keys/submaps/vim-registers.lua
-- REGISTERS submap — activated by " in NORMAL mode

local Submap = require("lib.submap") ---@class HyprVimSubmap
local vim = require("vim") ---@class Vim
local reg = vim.registers
local wk = require("whichkey") ---@class WhichKey
local config = require("config") ---@class HyprVimConfigModule
local LEADER = config.keys.leader or "SUPER"
local ACT = config.keys.activate or "ESCAPE"
local EXIT = config.keys.exit or "ESCAPE"

local function set(name)
  reg.set_pending(name)
  Submap.enter("NORMAL")
end

Submap.define({
  name = "REGISTERS",
  on_enter = function() vim.count.clear() end,
  escape = "NORMAL",
  catchall = "stay",
  binds = function()
    local rows = {
      -- stylua: ignore start
      { "SHIFT + APOSTROPHE", function() set('"') end, "Unnamed register (default)" },
      { "0",                  function() set("0") end, "Yank register (last yank)"  },
      { "SHIFT + MINUS",      function() set("_") end, "Black hole register"        },
      { "SLASH",              function() set("/") end, "Search register"            },
      { "SHIFT + SLASH",      wk.toggle },
      { LEADER .. " + " .. ACT, Submap.reset },
      { LEADER .. " + " .. EXIT, Submap.reset },
      -- stylua: ignore end
    }

    local letters = "abcdefghijklmnopqrstuvwxyz"
    for i = 1, #letters do
      local c = letters:sub(i, i)
      table.insert(rows, { c:upper(), function() set(c) end, "Register " .. c })
    end
    for i = 1, 9 do
      local s = tostring(i)
      table.insert(rows, { s, function() set(s) end })
    end

    return rows
  end,
}).setup()
