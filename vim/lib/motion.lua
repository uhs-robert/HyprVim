-- vim/lib/motion.lua
-- Execute vim motions with count support and terminal vs GUI routing.

local VimCount = require("vim.lib.count") ---@class VimCount
local Hypr = require("hypr") ---@class HyprVimHyprland
local Window = require("hypr.window") ---@class HyprVimWindow

--- @class VimMotion
local VimMotion = {}

-- Navigation keys that Hyprland's send_shortcut won't accept as raw keysym strings.
-- These send their GUI equivalent even when the focused window is a terminal.
---@type table<string, {[1]: string, [2]: string}>
local TERM_KEYSYMS = {
  ["0"] = { "",     "HOME"  },
  ["$"] = { "",     "END"   },
  ["{"] = { "CTRL", "UP"    },
  ["}"] = { "CTRL", "DOWN"  },
}

---Maps vim motion keys to `{mods, key}` pairs for GUI applications.
---@type table<string, {[1]: string, [2]: string}>
local GUI_MOTIONS = {
  -- Basic movement
  h = { "", "LEFT" },
  l = { "", "RIGHT" },
  j = { "", "DOWN" },
  k = { "", "UP" },
  -- Word motions
  w = { "CTRL", "RIGHT" },
  b = { "CTRL", "LEFT" },
  e = { "CTRL", "RIGHT" },
  -- Line boundaries
  ["0"] = { "", "HOME" },
  ["$"] = { "", "END" },
  -- Document boundaries
  gg = { "CTRL", "HOME" },
  G = { "CTRL", "END" },
  -- Paragraph
  ["{"] = { "CTRL", "UP" },
  ["}"] = { "CTRL", "DOWN" },
  -- Page
  ["ctrl-f"] = { "", "Next" },
  ["ctrl-b"] = { "", "Prior" },
  -- Visual mode variants (with SHIFT)
  H = { "SHIFT", "LEFT" },
  L = { "SHIFT", "RIGHT" },
  J = { "SHIFT", "DOWN" },
  K = { "SHIFT", "UP" },
  W = { "CTRL SHIFT", "RIGHT" },
  B = { "CTRL SHIFT", "LEFT" },
  E = { "CTRL SHIFT", "RIGHT" },
}

---Send a raw `{mods, key}` shortcut `n` times, consuming the count accumulator.
---@param shortcut {[1]: string, [2]: string}
---@param n        integer|nil  defaults to current count
function VimMotion.send_raw(shortcut, n)
  n = n or VimCount.get()
  for _ = 1, n do
    Hypr.send(shortcut[1], shortcut[2])
  end
end

---Execute a vim motion with count support.
---Terminals receive the raw key so the inner editor handles it natively.
---GUI apps receive the mapped shortcut from `GUI_MOTIONS`.
---@param key  string  vim motion key, e.g. `"j"`, `"w"`, `"gg"`, `"{"`
---@param opts { count?: integer, force_gui?: boolean, shortcut?: {[1]:string,[2]:string}, after?: fun() }|nil
function VimMotion.send(key, opts)
  opts = opts or {}
  local n = opts.count or VimCount.get()

  if Window.is_terminal() and not opts.force_gui then
    local ts = TERM_KEYSYMS[key]
    local tmods = ts and ts[1] or ""
    local tkey  = ts and ts[2] or key
    for _ = 1, n do
      hl.dispatch(hl.dsp.send_shortcut({ mods = tmods, key = tkey }))
    end
    return
  end

  local shortcut = opts.shortcut or GUI_MOTIONS[key]
  if not shortcut then return end

  for _ = 1, n do
    Hypr.send(shortcut[1], shortcut[2])
    if opts.after then opts.after() end
  end
end

---Send a GUI shortcut `n` times, bypassing terminal routing.
---Use when the shortcut must always go to the compositor (e.g. Shift+selections).
---@param mods string
---@param key  string
---@param n    integer|nil
function VimMotion.send_gui(mods, key, n)
  n = n or VimCount.get()
  for _ = 1, n do
    Hypr.send(mods, key)
  end
end

---Send multiple `{mods, key}` pairs in order, each exactly once.
---@param shortcuts {[1]: string, [2]: string}[]
function VimMotion.send_sequence(shortcuts) Hypr.send_all(shortcuts) end

return VimMotion
