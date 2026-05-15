-- vim/features/replace.lua
-- r (replace count chars) and R (replace with string) commands.

local Count = require("vim.lib.count") ---@class Count
local Hypr = require("hypr") ---@class HyprVimHyprland
local Config = require("config") ---@class HyprVimConfigModule

--- @class ReplaceModule
local Replace = {}

---Replace the Wayland clipboard with `text`.
---@param text string
local function clipboard_write(text)
  local p = io.popen("wl-copy", "w")
  if p then
    p:write(text)
    p:close()
  end
end

---Show a prompt labelled `label` and return the entered string, or nil if cancelled.
---@param label string
---@return string|nil
local function prompt(label)
  local tool = Config.applications.menu
  local cmd
  if tool == "rofi" then
    cmd = string.format('rofi -dmenu -p %q -theme-str "window{width:600px;}" -class hyprvim-replace 2>/dev/null', label)
  else
    cmd = string.format("%s -p %q 2>/dev/null", tool, label)
  end

  local p = io.popen(cmd)
  if not p then return nil end
  local s = p:read("*a"):gsub("%s+$", "")
  p:close()
  return s ~= "" and s or nil
end

---`r`: prompt for a single character and overwrite the next [count] characters with it.
function Replace.character()
  local n = Count.get()

  Hypr.exit_vim()
  hl.timer(function()
    local char = prompt("Replace char: ")
    Hypr.normal()
    if not char or char == "" then return end
    char = char:sub(1, 1)
    clipboard_write(char)
    hl.timer(function()
      -- Select n characters forward.
      for _ = 1, n do
        Hypr.send("SHIFT", "RIGHT")
      end
      hl.timer(function()
        Hypr.send("CTRL", "v")
        hl.timer(function() Hypr.normal() end, { timeout = 50, type = "oneshot" })
      end, { timeout = 50, type = "oneshot" })
    end, { timeout = 100, type = "oneshot" })
  end, { timeout = 100, type = "oneshot" })
end

---`R`: prompt for a replacement string and overwrite the next `#string` characters with it.
function Replace.string()
  Count.get() -- clear

  Hypr.exit_vim()
  hl.timer(function()
    local str = prompt("Replace with: ")
    Hypr.normal()
    if not str or str == "" then return end
    local n = #str
    clipboard_write(str)
    hl.timer(function()
      for _ = 1, n do
        Hypr.send("SHIFT", "RIGHT")
      end
      hl.timer(function()
        Hypr.send("CTRL", "v")
        hl.timer(function() Hypr.normal() end, { timeout = 50, type = "oneshot" })
      end, { timeout = 50, type = "oneshot" })
    end, { timeout = 100, type = "oneshot" })
  end, { timeout = 100, type = "oneshot" })
end

return Replace
