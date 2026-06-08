-- vim/lib/operator.lua
-- VimOperator + motion combinations: d{motion}, c{motion}, y{motion}.
-- Also handles text objects: iw/aw/ip/ap.

local VimCount = require("vim.lib.count") ---@class VimCount
local Hypr = require("hypr") ---@class HyprVimHyprland

--- @class VimOperator
local VimOperator = {}

---Key sequences that select each text object.
---`iw`/`aw` use word boundaries; `ip`/`ap` use paragraph boundaries.
---@type table<string, {[1]: string, [2]: string}[]>
local TEXT_OBJECTS = {
  iw = { { "CTRL SHIFT", "LEFT" }, { "CTRL SHIFT", "RIGHT" } },
  aw = { { "CTRL SHIFT", "LEFT" }, { "CTRL SHIFT", "RIGHT" } },
  ip = { { "CTRL SHIFT", "UP" }, { "CTRL SHIFT", "DOWN" } },
  ap = { { "CTRL SHIFT", "UP" }, { "CTRL SHIFT", "DOWN" } },
}

---Extend the selection by repeating `selection` `n` times, run `action_fn`, then switch mode.
---@param selection   {[1]: string, [2]: string}  shortcut to repeat
---@param action_fn   fun()                        yank / delete / change operation
---@param return_mode string|nil                   submap to switch to after (default `"NORMAL"`)
---@param n           integer|nil                  defaults to current count
function VimOperator.execute(selection, action_fn, return_mode, n)
  n = n or VimCount.get()
  return_mode = return_mode or "NORMAL"

  for _ = 1, n do
    Hypr.send(selection[1], selection[2])
  end

  action_fn()
  Hypr.switch_mode(return_mode)
end

---Select a text object then run `action_fn`. Clears the count accumulator first.
---@param obj         string    `"iw"`, `"aw"`, `"ip"`, or `"ap"`
---@param action_fn   fun()
---@param return_mode string|nil
function VimOperator.execute_text_object(obj, action_fn, return_mode)
  VimCount.get() -- clear count
  return_mode = return_mode or "NORMAL"

  local sequences = TEXT_OBJECTS[obj]
  if not sequences then return end

  Hypr.send_all(sequences)
  action_fn()
  Hypr.switch_mode(return_mode)
end

---`y` copy selection to clipboard via Ctrl+C.
function VimOperator.yank_action() Hypr.send("CTRL", "c") end

---`d` cut selection via Ctrl+X.
function VimOperator.delete_action() Hypr.send("CTRL", "x") end

---`c` cut selection then enter INSERT mode.
function VimOperator.change_action()
  Hypr.send("CTRL", "x")
  Hypr.switch_mode("INSERT")
end

return VimOperator
