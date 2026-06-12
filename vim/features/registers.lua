-- vim/features/registers.lua
-- Vim-like register system.
--
-- Named registers: a-z
-- Special registers:
--   "  unnamed (syncs with system clipboard)
--   +  system clipboard (explicit opt-in; yank/delete write snapshot file, paste reads it. Pre-vim clipboard or latest + yank)
--   0  yank register (last yank, not overwritten by deletes)
--   1-9 numbered history (newest->1, cycles on each yank or delete)
--   _  black hole (delete without affecting clipboard)
--   /  search register (read-only, mirrors find-state.json)

local Hypr = require("hypr") ---@class HyprVimHyprland
local Clipboard = require("lib.clipboard") ---@class Clipboard
local Find = require("vim.features.find") ---@class Find
local Utils = require("lib.utils") ---@class HyprVimUtils

--- @class Registers
--- @field enter_registers fun()  refresh REGISTERS submap binds then enter it
local Registers = {}

local DEFAULT_REG = '"'

local function state_dir() return require("config").state_dir .. "/registers" end
local function reg_path(name) return state_dir() .. "/" .. name end
local function pending_path() return state_dir() .. "/pending-register" end

-- Register file I/O.
local function reg_read(name) return Utils.read_head(reg_path(name)) end

local function reg_write(name, content)
  local f = io.open(reg_path(name), "w")
  if not f then return end
  f:write(content)
  f:close()
end

---Set the pending register for the next operation (cleared after use).
---@param name string register name
function Registers.set_pending(name)
  local f = io.open(pending_path(), "w")
  if f then
    f:write(name)
    f:close()
  end
end

---Return the pending register name, or `"` (unnamed) if none is set.
---@return string
function Registers.get_pending()
  local f = io.open(pending_path(), "r")
  if not f then return DEFAULT_REG end
  local s = f:read("*a"):gsub("%s+$", "")
  f:close()
  return (s ~= "" and s) or DEFAULT_REG
end

---Clear the pending register without reading it.
function Registers.clear_pending() os.remove(pending_path()) end

---Save content to a register. No-op for the read-only `/` register.
---@param name string register name
---@param content string
function Registers.save(name, content)
  if name == "/" then return end -- read-only
  reg_write(name, content)
end

---Load a register's content to the clipboard.
---@param name string register name (e.g. `"a"`, `"*"`)
---@param on_loaded? fun() called once the clipboard write has been dispatched.
--- For `"*"` this fires only after the async primary-selection read completes,
--- so callers can safely chain a paste without racing the clipboard write.
function Registers.load(name, on_loaded)
  local function done()
    if on_loaded then on_loaded() end
  end
  if name == "/" then
    Clipboard.write(Find.get_term())
    done()
    return
  end
  if name == "+" then
    local content = Utils.read_head(Clipboard.pre_vim_path())
    if content ~= "" then Clipboard.write(content) end
    done()
    return
  end
  if name == "*" then
    Clipboard.read_primary_async(150, function(content)
      if content ~= "" then Clipboard.write(content) end
      done()
    end)
    return
  end
  Clipboard.write(reg_read(name))
  done()
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

-- Push content onto the numbered 1-9 ring; skips empty and consecutive-duplicate content.
local function push_numbered(content)
  if content == "" or content == reg_read("1") then return end
  cycle_numbered()
  reg_write("1", content)
end

---Handle yank: send the copy shortcut, then async-save the clipboard to the pending
---register and cycle the numbered history (1-9).
---@param mods string modifiers for the copy shortcut (e.g. `"CTRL"`)
---@param key string key for the copy shortcut (e.g. `"c"`)
---@param return_mode? string submap to switch to after saving (default `"NORMAL"`)
function Registers.handle_yank(mods, key, return_mode)
  return_mode = return_mode or "NORMAL"
  local reg = Registers.get_pending()
  Registers.clear_pending()
  require("whichkey").cancel_pending()

  Hypr.send(mods, key)

  Clipboard.read_async(150, function(content)
    if reg == "*" then
      Clipboard.write_primary(content)
    else
      push_numbered(content)
      reg_write(reg, content)
      if reg ~= "0" then reg_write("0", content) end
      if reg ~= DEFAULT_REG then reg_write(DEFAULT_REG, content) end
      if reg == "+" then
        -- Persist to pre-vim file so content survives vim exit via restore_pre_vim.
        local f2 = io.open(Clipboard.pre_vim_path(), "w")
        if f2 then
          f2:write(content)
          f2:close()
        end
      end
    end
    Hypr.switch_mode(return_mode)
  end)
end

---Handle delete: send Ctrl+X, async-save the clipboard to the pending register
---and cycle the numbered delete history (1-9).
---@param return_mode? string submap to switch to after saving (default `"NORMAL"`)
function Registers.handle_delete(return_mode)
  return_mode = return_mode or "NORMAL"
  local reg = Registers.get_pending()
  Registers.clear_pending()
  require("whichkey").cancel_pending()

  if reg == "_" then
    -- Black hole: capture clipboard before delete, delete, restore clipboard.
    Clipboard.read_async(50, function(backup)
      Hypr.send("CTRL", "x")
      -- 200ms (matching the read delay below) so the cut lands before the restore.
      hl.timer(function()
        Clipboard.write(backup)
        Hypr.switch_mode(return_mode)
      end, { timeout = 200, type = "oneshot" })
    end)
    return
  end

  Hypr.send("CTRL", "x")

  Clipboard.read_async(200, function(content)
    if reg == "*" then
      Clipboard.write_primary(content)
    else
      push_numbered(content)
      reg_write(reg, content)
      if reg ~= DEFAULT_REG then reg_write(DEFAULT_REG, content) end
      if reg == "+" then
        local f2 = io.open(Clipboard.pre_vim_path(), "w")
        if f2 then
          f2:write(content)
          f2:close()
        end
      end
    end
    Hypr.switch_mode(return_mode)
  end)
end

---Handle paste: load the pending register to the clipboard, then send the paste shortcut.
---@param mods string modifiers for the paste shortcut (e.g. `"CTRL"`)
---@param key string key for the paste shortcut (e.g. `"v"`)
---@param return_mode? string submap to switch to after pasting (default `"NORMAL"`)
---@param count? integer how many times to send the paste shortcut (default 1)
function Registers.handle_paste(mods, key, return_mode, count)
  return_mode = return_mode or "NORMAL"
  count = (count and count > 0) and count or 1
  local reg = Registers.get_pending()
  Registers.clear_pending()

  local shortcuts = {}
  for _ = 1, count do
    shortcuts[#shortcuts + 1] = { mods, key }
  end

  Registers.load(reg, function()
    -- 150ms lets wl-copy settle before the paste lands.
    hl.timer(function()
      Hypr.send_batch(shortcuts, 20, function() Hypr.switch_mode(return_mode) end)
    end, { timeout = 150, type = "oneshot" })
  end)
end

return Registers
