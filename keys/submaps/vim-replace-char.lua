-- keys/submaps/vim-replace-char.lua
-- R-CHAR submap: delete char under cursor, pass the key, return to NORMAL

local leader = (require("config").keys or {}).leader or "SUPER"
local act    = (require("config").keys or {}).activate or "ESCAPE"

local function b(keys, fn) hl.bind(keys, fn) end
local function submap(n)   hl.dispatch(hl.dsp.submap(n)) end

local function replace()
  hl.dispatch(hl.dsp.send_shortcut({ mods = "", key = "DELETE" }))
  hl.dispatch(hl.dsp.pass())
  submap("NORMAL")
end

hl.define_submap("R-CHAR", "reset", function()
  -- Cancel
  b("ESCAPE",               function() submap("NORMAL") end)
  b(leader .. " + " .. act, function() hl.dispatch(hl.dsp.submap("reset")) end)

  -- Letters a-z (lower and upper)
  local letters = "abcdefghijklmnopqrstuvwxyz"
  for i = 1, #letters do
    local c = letters:sub(i, i):upper()
    b(c,           replace)
    b("SHIFT + " .. c, replace)
  end

  -- Digits 0-9 and shifted symbols
  for i = 0, 9 do
    b(tostring(i),         replace)
    b("SHIFT + " .. tostring(i), replace)
  end

  -- Punctuation
  local punct = {
    "MINUS", "EQUAL", "BRACKETLEFT", "BRACKETRIGHT",
    "BACKSLASH", "SEMICOLON", "APOSTROPHE", "COMMA",
    "PERIOD", "SLASH", "GRAVE",
  }
  for _, k in ipairs(punct) do
    b(k,           replace)
    b("SHIFT + " .. k, replace)
  end

  -- Whitespace
  b("SPACE", replace)
  b("TAB",   replace)

  -- Catchall: stay in R-CHAR
  b("catchall", function() submap("R-CHAR") end)
end)
