-- home/hypr/.config/hypr/hyprvim/vim/features/registers.lua
-- Vim-like register system.
--
-- Named registers: a-z
-- Special registers:
--   "  unnamed (syncs with system clipboard)
--   0  yank register (last yank, not overwritten by deletes)
--   1-9 numbered delete history (newest->1, cycles on each delete)
--   _  black hole (delete without affecting clipboard)
--   /  search register (read-only, mirrors find-state.json)

local Hypr = require("hypr") ---@class HyprVimHyprland

--- @class Registers
local Registers = {}

local DEFAULT_REG = '"'

local function state_dir() return require("config").state_dir .. "/registers" end
local function reg_path(name) return state_dir() .. "/" .. name end
local function pending_path() return state_dir() .. "/pending-register" end

-- Clipboard helpers (safe to call from event loop: uses external processes, not hyprctl socket).

local function clipboard_read()
  local p = io.popen("wl-paste --no-newline 2>/dev/null")
  if not p then return "" end
  local s = p:read("*a") or ""
  p:close()
  return s
end

local function clipboard_write(text)
  -- Single chars need explicit MIME type to avoid mangling.
  local flag = (#text == 1) and "--type text/plain" or ""
  local p = io.popen("wl-copy " .. flag, "w")
  if not p then return end
  p:write(text)
  p:close()
end

-- Register file I/O.

local function reg_read(name)
  local f = io.open(reg_path(name), "r")
  if not f then return "" end
  local s = f:read("*a") or ""
  f:close()
  return s
end

local function reg_write(name, content)
  local f = io.open(reg_path(name), "w")
  if not f then return end
  f:write(content)
  f:close()
end

-- Pending register (set before an operation, cleared after).

function Registers.set_pending(name)
  local f = io.open(pending_path(), "w")
  if f then
    f:write(name)
    f:close()
  end
end

function Registers.get_pending()
  local f = io.open(pending_path(), "r")
  if not f then return DEFAULT_REG end
  local s = f:read("*a"):gsub("%s+$", "")
  f:close()
  return (s ~= "" and s) or DEFAULT_REG
end

function Registers.clear_pending() os.remove(pending_path()) end

-- Save clipboard content to a register.
function Registers.save(name, content)
  if name == "/" then return end -- read-only
  reg_write(name, content)
end

-- Load a register's content to the clipboard.
function Registers.load(name)
  if name == "/" then
    -- Read search term from find-state.json.
    local f = io.open(require("config").state_dir .. "/find-state.json", "r")
    local term = ""
    if f then
      local data = f:read("*a")
      f:close()
      term = data:match('"find_term"%s*:%s*"([^"]*)"') or ""
    end
    clipboard_write(term)
    return
  end
  clipboard_write(reg_read(name))
end

-- Cycle numbered registers 1->9 (oldest drops off, newest->1).
local function cycle_numbered()
  for i = 8, 1, -1 do
    local src = reg_path(tostring(i))
    local dst = reg_path(tostring(i + 1))
    local f = io.open(src, "r")
    if f then
      local content = f:read("*a")
      f:close()
      reg_write(tostring(i + 1), content)
      os.remove(src)
    else
      os.remove(dst)
    end
  end
end

-- Handle yank (Ctrl+C): send shortcut, then async-save to register after clipboard settles.
-- return_mode: submap to switch to after saving.
function Registers.handle_yank(mods, key, return_mode)
  return_mode = return_mode or "NORMAL"
  local reg = Registers.get_pending()
  Registers.clear_pending()

  Hypr.send(mods, key)

  hl.timer(function()
    local content = clipboard_read()
    reg_write(reg, content)
    if reg ~= "0" then reg_write("0", content) end
    -- If we saved to a named register, restore unnamed to clipboard.
    if reg ~= DEFAULT_REG then
      local unnamed = reg_read(DEFAULT_REG)
      if unnamed ~= "" then clipboard_write(unnamed) end
    end
    Hypr.switch_mode(return_mode)
  end, { timeout = 150, type = "oneshot" })
end

-- Handle delete (Ctrl+X): send shortcut, async-save to register + cycle numbered registers.
function Registers.handle_delete(mods, key, return_mode)
  return_mode = return_mode or "NORMAL"
  local reg = Registers.get_pending()
  Registers.clear_pending()

  if reg == "_" then
    -- Black hole: save clipboard, delete, restore clipboard.
    local backup = clipboard_read()
    Hypr.send(mods, key)
    hl.timer(function()
      clipboard_write(backup)
      Hypr.switch_mode(return_mode)
    end, { timeout = 50, type = "oneshot" })
    return
  end

  Hypr.send(mods, key)

  hl.timer(function()
    local content = clipboard_read()
    cycle_numbered()
    reg_write("1", content)
    reg_write(reg, content)
    Hypr.switch_mode(return_mode)
  end, { timeout = 200, type = "oneshot" })
end

-- Handle paste: load register to clipboard, send paste shortcut.
function Registers.handle_paste(mods, key, return_mode)
  return_mode = return_mode or "NORMAL"
  local reg = Registers.get_pending()
  Registers.clear_pending()

  Registers.load(reg)

  hl.timer(function()
    Hypr.send(mods, key)
    hl.timer(function() Hypr.switch_mode(return_mode) end, { timeout = 150, type = "oneshot" })
  end, { timeout = 150, type = "oneshot" })
end

return Registers
