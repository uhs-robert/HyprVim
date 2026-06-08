-- vim/lib/motion/shortcuts.lua
-- Vim key -> {mods, key} translation tables, one per mode.
-- Sequence-based motions (e.g. visual paragraph) are handled inline in their submap.

---@type table<string, {[1]: string, [2]: string}>
local TERM_KEYSYMS = {
  ["0"] = { "", "HOME" },
  ["$"] = { "", "END" },
  ["{"] = { "CTRL", "UP" },
  ["}"] = { "CTRL", "DOWN" },
}

---@alias Shortcut {[1]: string, [2]: string}
---@alias ShortcutOrSeq Shortcut | Shortcut[]

---@type table<string, ShortcutOrSeq>
local NORMAL = {
  -- Basic movement
  h = { "", "LEFT" },
  j = { "", "DOWN" },
  k = { "", "UP" },
  l = { "", "RIGHT" },
  -- Word motions
  w = { { "CTRL", "RIGHT" }, { "", "RIGHT" } },
  W = { { "CTRL", "RIGHT" }, { "", "RIGHT" } },
  e = { { "", "RIGHT" }, { "CTRL", "RIGHT" }, { "", "LEFT" } },
  E = { { "", "RIGHT" }, { "CTRL", "RIGHT" }, { "", "LEFT" } },
  b = { "CTRL", "LEFT" },
  B = { "CTRL", "LEFT" },
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
  e = { "CTRL SHIFT", "RIGHT" },
  E = { "CTRL SHIFT", "RIGHT" },
  b = { "CTRL SHIFT", "LEFT" },
  B = { "CTRL SHIFT", "LEFT" },
}

return { NORMAL = NORMAL, VISUAL = VISUAL, TERM_KEYSYMS = TERM_KEYSYMS }
