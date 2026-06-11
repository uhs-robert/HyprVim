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
---@field copy_selected boolean|nil  copy the active selection into the scratch file before opening
---@field insert_mode boolean|nil  start the editor in INSERT mode
---@field ext         string|nil   file extension for syntax highlighting (e.g. "md", "py")
---@field after_submap string|nil  if set, dispatch to this submap once the editor exits

---Open a floating terminal editor on a scratch file.
---Delegates entirely to vim-open-editor; no blocking I/O in the compositor thread.
---@param opts EditorOpenOpts|nil
function Editor.open(opts)
  opts = opts or {}
  local copy_selected = opts.copy_selected ~= false
  local ext = opts.ext or "md"
  -- stylua: ignore
  local args = { SCRIPT,
    "--term",   Config.applications.terminal,
    "--editor", Config.applications.editor,
    "--ext",    ext,
  }
  if Window.is_terminal() then args[#args + 1] = "--terminal" end
  if copy_selected then args[#args + 1] = "--copy-selected" end
  if opts.insert_mode then args[#args + 1] = "--insert-mode" end
  local cmd = table.concat(args, " ")
  if opts.after_submap then
    Hypr.cmd_then_dispatch(cmd, string.format('hl.dsp.submap("%s")', opts.after_submap))()
  else
    Hypr.exec(cmd)
  end
end

return Editor
