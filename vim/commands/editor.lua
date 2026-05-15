-- vim/commands/editor.lua
-- Delegate to scripts/vim-open-editor via a non-blocking exec dispatch.
-- All clipboard I/O and process management happens in the script subprocess,
-- not in the compositor Lua thread.

local Hypr = require("hypr") ---@class HyprVimHyprland
local Config = require("config") ---@class HyprVimConfigModule
local Window = require("hypr.window") ---@class HyprVimWindow

--- @class EditorModule
local Editor = {}

local _dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)") or "./"
local SCRIPT = _dir .. "../../scripts/vim-open-editor"

---@class EditorOpenOpts
---@field copy_sel    boolean|nil  copy the active selection into the scratch file before opening
---@field insert_mode boolean|nil  start the editor in INSERT mode
---@field ext         string|nil   file extension for syntax highlighting (e.g. "md", "py")

---Open a floating terminal editor on a scratch file.
---Delegates entirely to vim-open-editor; no blocking I/O in the compositor thread.
---@param opts EditorOpenOpts|nil
function Editor.open(opts)
  opts = opts or {}
  local copy_sel = opts.copy_sel ~= false
  local ext = opts.ext or "md"
  -- stylua: ignore
  local args = { SCRIPT,
    "--term",   Config.applications.terminal,
    "--editor", Config.applications.editor,
    "--menu",   Config.applications.menu,
    "--ext",    ext,
  }
  if Window.is_terminal() then args[#args + 1] = "--terminal" end
  if copy_sel then args[#args + 1] = "--copy-selected" end
  if opts.insert_mode then args[#args + 1] = "--insert-mode" end
  Hypr.exec(table.concat(args, " "))
end

return Editor
