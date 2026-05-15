-- keys/submaps/vim-marks.lua
-- SET-MARK, JUMP-MARK, DELETE-MARK — 62 chars each

local vim = require("vim") ---@class vim
local marks = vim.marks
local wk = require("whichkey") ---@class WhichKey

local leader = (require("config").keys or {}).leader or "SUPER"
local act = (require("config").keys or {}).activate or "ESCAPE"

local function b(keys, fn)
  hl.bind(keys, fn)
end
local function bd(keys, desc, fn)
  hl.bind(keys, fn, { description = desc })
end
local function submap(n)
  hl.dispatch(hl.dsp.submap(n))
end

local lowercase = "abcdefghijklmnopqrstuvwxyz"
local uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local digits = "0123456789"

local function mark_submap(name, action, return_submap)
  hl.define_submap(name, return_submap or "reset", function()
    -- lowercase a-z
    for i = 1, #lowercase do
      local c = lowercase:sub(i, i)
      local key = c:upper()
      bd(key, c, function()
        action(c)
      end)
    end
    -- uppercase A-Z (SHIFT + letter)
    for i = 1, #uppercase do
      local c = uppercase:sub(i, i)
      bd("SHIFT + " .. c, c, function()
        action(c)
      end)
    end
    -- digits 0-9
    for i = 1, #digits do
      local c = digits:sub(i, i)
      bd(c, c, function()
        action(c)
      end)
    end
    -- DELETE / BackSpace → clear all (only for DELETE-MARK)
    if name == "DELETE-MARK" then
      bd("DELETE", "Clear all marks", function()
        marks.clear()
      end)
      b("SHIFT + DELETE", function()
        marks.clear()
      end)
      bd("BackSpace", "Clear all marks", function()
        marks.clear()
      end)
      b("SHIFT + BackSpace", function()
        marks.clear()
      end)
    end
    -- Footer
    b("ESCAPE", function()
      marks.exit()
    end)
    if name ~= "DELETE-MARK" then b("BackSpace", function()
      marks.exit()
    end) end
    b(leader .. " + " .. act, function()
      hl.dispatch(hl.dsp.submap("reset"))
    end)
    b("SPACE", function()
      wk.toggle()
    end)
    b("catchall", function()
      submap(name)
    end)
  end)
end

mark_submap("SET-MARK", function(c)
  marks.set(c)
end, "reset")
mark_submap("JUMP-MARK", function(c)
  marks.jump(c)
end, "reset")
mark_submap("DELETE-MARK", function(c)
  marks.delete(c)
end, "reset")
