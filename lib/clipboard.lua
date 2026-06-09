-- lib/clipboard.lua
-- Non-blocking clipboard I/O for Hyprland's synchronous Lua context.
-- io.popen("wl-paste"/"wl-copy") blocks the compositor thread; these helpers
-- offload both operations outside the Lua event loop via Hypr.exec.

local Hypr = require("hypr") ---@class HyprVimHyprland

local Clipboard = {} ---@class Clipboard

local function tmp_read() return require("config").state_dir .. "/clipboard_read_tmp" end
local function tmp_write() return require("config").state_dir .. "/clipboard_write_tmp" end
local function pre_vim_path() return require("config").state_dir .. "/clipboard_pre_vim" end

---Dispatch wl-paste to a tmpfile via Hypr.exec, then call cb(content) after delay_ms.
---@param delay_ms integer  Milliseconds to wait before reading the tmpfile
---@param cb fun(content: string)  Called with clipboard text (empty string if clipboard is empty)
function Clipboard.read_async(delay_ms, cb)
  local path = tmp_read()
  Hypr.exec("wl-paste --no-newline 2>/dev/null >'" .. path .. "' || true")
  hl.timer(function()
    local f = io.open(path, "r")
    local content = f and (f:read("*a") or "") or ""
    if f then f:close() end
    cb(content)
  end, { timeout = delay_ms, type = "oneshot" })
end

---Write text to the clipboard. Writes to a tmpfile via io.open (no Wayland call), then
---dispatches wl-copy via Hypr.exec so the compositor thread is never blocked.
---@param text string
function Clipboard.write(text)
  local path = tmp_write()
  local f = io.open(path, "w")
  if not f then return end
  f:write(text)
  f:close()
  local flag = (#text == 1) and "--type text/plain " or ""
  Hypr.exec("wl-copy " .. flag .. "<'" .. path .. "'")
end

---Save the current clipboard so it can be restored when vim mode exits.
---Called once when entering NORMAL from the reset (non-vim) state.
function Clipboard.save_pre_vim()
  local path = tmp_read()
  Hypr.exec("wl-paste --no-newline 2>/dev/null >'" .. path .. "' || true")
  hl.timer(function()
    local f = io.open(path, "r")
    local content = f and (f:read("*a") or "") or ""
    if f then f:close() end
    local out = io.open(pre_vim_path(), "w")
    if out then
      out:write(content)
      out:close()
    end
  end, { timeout = 100, type = "oneshot" })
end

---Restore the clipboard saved by save_pre_vim(). Called on vim exit.
function Clipboard.restore_pre_vim()
  local f = io.open(pre_vim_path(), "r")
  if not f then return end
  local content = f:read("*a") or ""
  f:close()
  os.remove(pre_vim_path())
  if content ~= "" then Clipboard.write(content) end
end

return Clipboard
