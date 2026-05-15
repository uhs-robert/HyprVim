-- vim/commands/editor.lua
-- Open a floating nvim/vim to edit text anywhere; auto-paste on save.

local Hypr = require("hypr") ---@class HyprVimHyprland
local Config = require("config") ---@class HyprVimConfigModule

--- @class EditorModule
local Editor = {}

---@type string  directory for temporary editor scratch files
local CACHE_DIR = Config.cache_dir .. "/open-vim"

---Read the current Wayland clipboard contents.
---@return string  clipboard text, or `""` on failure
local function clipboard_read()
  local p = io.popen("wl-paste --no-newline 2>/dev/null")
  if not p then return "" end
  local s = p:read("*a") or ""
  p:close()
  return s
end

---Replace the Wayland clipboard with `text`.
---@param text string
local function clipboard_write(text)
  local p = io.popen("wl-copy", "w")
  if p then
    p:write(text)
    p:close()
  end
end

---Return true if `path` exists (used to detect when the editor wrote the file).
---@param path string
---@return boolean
local function file_exists(path)
  local f = io.open(path, "r")
  if not f then return false end
  f:close()
  return true
end

---@class EditorOpenOpts
---@field ext         string|nil  file extension for syntax highlighting (e.g. `"md"`, `"py"`)
---@field copy_sel    boolean|nil copy the active selection into the scratch file before opening
---@field insert_mode boolean|nil start the editor in INSERT mode

---Open a floating terminal editor on a scratch file.
---If `copy_sel` is set, the current selection is pre-loaded; on save the file
---contents are written back to the clipboard and pasted into the focused window.
---@param opts EditorOpenOpts|nil
function Editor.open(opts)
  opts = opts or {}

  -- Compute the scratch-file path with pure Lua (no blocking I/O on the hot path).
  local ts = os.time()
  local ext = opts.ext and ("." .. opts.ext) or ""
  local path = CACHE_DIR .. "/doc-" .. ts .. ext

  local editor = Config.applications.editor
  local term = Config.term_cmd("hyprvim-open-vim")
  local insert = opts.insert_mode and " +startinsert" or ""

  -- All blocking I/O runs inside the timer so it doesn't block the compositor.
  hl.timer(function()
    os.execute("mkdir -p " .. CACHE_DIR)
    -- Kill any existing instance to prevent duplicates.
    os.execute("pkill -f 'hyprvim-open-vim' 2>/dev/null || true")

    local backup = clipboard_read()

    local function launch_editor()
      local autocmd = string.format("+autocmd BufWritePost <buffer> quit %s", path)
      local cmd = string.format("%s %s %s%s %q &", term, editor, autocmd, insert, path)
      os.execute(cmd)

      -- Poll for the file to appear (editor wrote it on :w / BufWritePost).
      -- Since the filename is fresh each invocation, existence means the editor saved.
      local attempts = 0
      local function check()
        attempts = attempts + 1
        if file_exists(path) then
          local f = io.open(path, "r")
          if f then
            local content = f:read("*a")
            f:close()
            content = content:gsub("\n$", "")
            clipboard_write(content)
            hl.timer(function()
              Hypr.send("CTRL", "v")
              hl.timer(function() clipboard_write(backup) end, { timeout = 150, type = "oneshot" })
            end, { timeout = 100, type = "oneshot" })
          end
        elseif attempts < 10 then
          hl.timer(check, { timeout = 1000, type = "oneshot" })
        end
      end
      hl.timer(check, { timeout = 1000, type = "oneshot" })
    end

    -- Copy selected text into the file if requested.
    if opts.copy_sel then
      Hypr.send("CTRL", "c")
      hl.timer(function()
        local sel = clipboard_read()
        if sel ~= "" then
          local f = io.open(path, "w")
          if f then
            f:write(sel)
            f:close()
          end
        end
        clipboard_write(backup)
        launch_editor()
      end, { timeout = 200, type = "oneshot" })
    else
      launch_editor()
    end
  end, { timeout = 0, type = "oneshot" })
end

return Editor
