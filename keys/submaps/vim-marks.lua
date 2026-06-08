-- keys/submaps/vim-marks.lua
-- SET-MARK, MARKS (jump), DELETE-MARK 62 chars each

local Submap = require("lib.submap") ---@class HyprVimSubmap
local vim = require("vim") ---@class Vim
local marks = vim.marks
local wk = require("whichkey") ---@class WhichKey
local config = require("config") ---@class HyprVimConfigModule
local LEADER = (config.keys or {}).leader or "SUPER"
local ACT = (config.keys or {}).activate or "ESCAPE"

local lowercase = "abcdefghijklmnopqrstuvwxyz"
local uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local digits = "0123456789"

--- Build and register a mark submap.
--- @param name    string
--- @param action  fun(c: string)
--- @param escape  "reset"|string|fun()
local function mark_submap(name, action, escape)
  Submap.define({
    name = name,
    escape = escape == "marks.exit" and function() marks.exit() end or escape,
    back = false,
    catchall = "stay",
    binds = function()
      local rows = {}

      for i = 1, #lowercase do
        local c = lowercase:sub(i, i)
        table.insert(rows, { c:upper(), function() action(c) end, c })
      end
      for i = 1, #uppercase do
        local c = uppercase:sub(i, i)
        table.insert(rows, { "SHIFT + " .. c, function() action(c) end, c })
      end
      for i = 1, #digits do
        local c = digits:sub(i, i)
        table.insert(rows, { c, function() action(c) end, c })
      end

      if name == "DELETE-MARK" then
        table.insert(rows, { "DELETE", function() marks.clear() end, "Clear all marks" })
        table.insert(rows, { "SHIFT + DELETE", function() marks.clear() end })
      else
        table.insert(rows, { "BackSpace", function() marks.exit() end })
      end

      table.insert(rows, { "SPACE", wk.toggle })
      table.insert(rows, { LEADER .. " + " .. ACT, function() hl.dispatch(hl.dsp.submap("reset")) end })
      return rows
    end,
  }).setup()
end

mark_submap("SET-MARK", function(c) marks.set(c) end, "reset")
mark_submap("MARKS", function(c) marks.jump(c) end, "marks.exit")
mark_submap("DELETE-MARK", function(c) marks.delete(c) end, "marks.exit")
