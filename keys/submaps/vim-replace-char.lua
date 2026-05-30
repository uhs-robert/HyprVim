-- keys/submaps/vim-replace-char.lua
-- R-CHAR submap: delete char under cursor, pass the key, return to NORMAL

local Submap = require("lib.submap") ---@class HyprVimSubmap
local config = require("config") ---@class HyprVimConfigModule
local LEADER = config.keys.leader or "SUPER"
local ACT = config.keys.activate or "ESCAPE"
local EXIT = config.keys.exit or "ESCAPE"

local function replace()
  hl.dispatch(hl.dsp.send_shortcut({ mods = "", key = "DELETE" }))
  hl.dispatch(hl.dsp.pass())
  Submap.enter("NORMAL")
end

Submap.define({
  name = "R-CHAR",
  escape = "NORMAL",
  back = false,
  catchall = "stay",
  binds = function()
    local rows = {
      { LEADER .. " + " .. ACT, Submap.reset },
      { LEADER .. " + " .. EXIT, Submap.reset },
    }

    local letters = "abcdefghijklmnopqrstuvwxyz"
    for i = 1, #letters do
      local c = letters:sub(i, i):upper()
      table.insert(rows, { c, replace })
      table.insert(rows, { "SHIFT + " .. c, replace })
    end

    for i = 0, 9 do
      table.insert(rows, { tostring(i), replace })
      table.insert(rows, { "SHIFT + " .. tostring(i), replace })
    end

    for _, k in ipairs({
      "MINUS",
      "EQUAL",
      "BRACKETLEFT",
      "BRACKETRIGHT",
      "BACKSLASH",
      "SEMICOLON",
      "APOSTROPHE",
      "COMMA",
      "PERIOD",
      "SLASH",
      "GRAVE",
    }) do
      table.insert(rows, { k, replace })
      table.insert(rows, { "SHIFT + " .. k, replace })
    end

    table.insert(rows, { "SPACE", replace })
    table.insert(rows, { "TAB", replace })

    return rows
  end,
}).setup()
