-- vim/lib/motion/shortcuts.lua
-- Vim key -> {mods, key} translation tables, one per mode, plus the SELECT
-- recipes shared by the operator (d/c/y) submaps.

---@type table<string, {[1]: string, [2]: string}>
local TERM_KEYSYMS = {
  ["0"] = { "", "HOME" },
  ["$"] = { "", "END" },
  ["{"] = { "CTRL", "UP" },
  ["}"] = { "CTRL", "DOWN" },
}

---@alias Shortcut {[1]: string, [2]: string}
---@alias ShortcutOrSeq Shortcut | Shortcut[]

-- Select to word end: the SHIFT+Left backstep undoes CTRL+RIGHT overshooting
-- to the next word start (same convention NORMAL.e compensates for).
local WORD_END = { { "CTRL SHIFT", "RIGHT" }, { "SHIFT", "Left" } }

---@type table<string, ShortcutOrSeq>
local NORMAL = {
  -- Basic movement
  h = { "", "LEFT" },
  j = { "", "DOWN" },
  k = { "", "UP" },
  l = { "", "RIGHT" },
  -- Word motions
  w = { "CTRL", "RIGHT" },
  W = { { "CTRL", "RIGHT" }, { "", "RIGHT" } },
  e = { { "", "RIGHT" }, { "CTRL", "RIGHT" }, { "", "LEFT" } },
  E = { { "", "RIGHT" }, { "CTRL", "RIGHT" }, { "", "LEFT" } },
  b = { "CTRL", "LEFT" },
  B = { "CTRL", "LEFT" },
  ge = { { "CTRL", "LEFT" }, { "CTRL", "LEFT" }, { "CTRL", "RIGHT" }, { "", "LEFT" } },
  -- Line boundaries
  ["0"] = { "", "HOME" },
  ["_"] = { "", "HOME" },
  ["^"] = { "", "HOME" },
  ["$"] = { "", "END" },
  -- Document boundaries
  gg = { "CTRL", "HOME" },
  G = { "CTRL", "END" },
  -- Paragraph
  ["{"] = { "CTRL", "UP" },
  ["}"] = { "CTRL", "DOWN" },
  -- Page
  ["CTRL + d"] = { "", "Next" },
  ["CTRL + f"] = { "", "Next" },
  ["CTRL + e"] = { "", "Next" },
  ["CTRL + u"] = { "", "Prior" },
  ["CTRL + b"] = { "", "Prior" },
  ["CTRL + y"] = { "", "Prior" },
  -- Undo
  u = { "CTRL", "z" },
  ["CTRL + r"] = { "CTRL", "Y" },
}

---@type table<string, ShortcutOrSeq>
local VISUAL = {
  -- Basic movement (extends selection)
  h = { "SHIFT", "LEFT" },
  j = { "SHIFT", "DOWN" },
  k = { "SHIFT", "UP" },
  l = { "SHIFT", "RIGHT" },
  -- Line boundaries (SHIFT+h/l in visual submap)
  H = { "SHIFT", "HOME" },
  J = { "CTRL SHIFT", "DOWN" },
  K = { "CTRL SHIFT", "UP" },
  L = { "SHIFT", "END" },
  -- Word motions (extends selection)
  w = { "CTRL SHIFT", "RIGHT" },
  W = { "CTRL SHIFT", "RIGHT" },
  -- e aliases w: otherwise makes no progress when re-extending from a word end
  e = { "CTRL SHIFT", "RIGHT" },
  E = { "CTRL SHIFT", "RIGHT" },
  b = { "CTRL SHIFT", "LEFT" },
  B = { "CTRL SHIFT", "LEFT" },
  ge = { { "CTRL SHIFT", "LEFT" }, { "SHIFT", "LEFT" } },
  -- Document boundaries
  gg = { "CTRL SHIFT", "HOME" },
  G = { "CTRL SHIFT", "END" },
  -- Page (CTRL+f/b stay app passthroughs in the visual submaps)
  ["CTRL + e"] = { "SHIFT", "PAGE_DOWN" },
  ["CTRL + y"] = { "SHIFT", "PAGE_UP" },
}

---Selection recipes for the operator/visual submaps (semantic names, not vim keys).
---inner_word's right-left bounce normalizes the caret to the current word's start
---so failure modes stay forward of the caret, vim's bias. inner_para's leading END
---does the same for paragraphs: CTRL+UP from a paragraph's first line would jump
---to the previous paragraph.
---@type table<string, ShortcutOrSeq>
-- stylua: ignore
local SELECT = {
  next_word     = VISUAL.w,
  prev_word     = VISUAL.b,
  next_para     = VISUAL.J,
  next_char     = { "SHIFT", "RIGHT" },
  prev_char     = { "SHIFT", "LEFT" },
  word_end      = WORD_END,
  to_eol        = { "SHIFT", "End" },
  to_bol        = { "SHIFT", "Home" },
  first_line    = VISUAL.gg,
  last_line     = VISUAL.G,
  line          = { { "", "HOME" }, { "SHIFT", "End" } },
  line_from_end = { { "", "END" }, { "SHIFT", "HOME" } },
  inner_word    = { { "CTRL", "RIGHT" }, { "CTRL", "LEFT" }, VISUAL.w },
  inner_para    = { { "", "END" }, { "CTRL", "UP" }, { "CTRL SHIFT", "DOWN" } },
  deselect      = { { "", "LEFT" }, { "", "RIGHT" } },
}

return { NORMAL = NORMAL, VISUAL = VISUAL, TERM_KEYSYMS = TERM_KEYSYMS, SELECT = SELECT }
