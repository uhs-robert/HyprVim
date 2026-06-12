-- keys/submaps/vim-registers.lua
-- REGISTERS submap activated by " in NORMAL mode

local Submap = require("lib.submap") ---@class HyprVimSubmap
local vim = require("vim") ---@class Vim
local reg = vim.registers
local wk = require("whichkey") ---@class WhichKey
local config = require("config") ---@class HyprVimConfigModule
local common = require("keys.submaps.common")
local Clipboard = require("lib.clipboard") ---@class Clipboard
local Find = require("vim.features.find") ---@class Find

local reg_dir = config.state_dir .. "/registers"

local function reg_preview(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local s = (f:read(50) or ""):gsub("[\n\t\r]", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
  f:close()
  if s == "" then return nil end
  return #s > 45 and (s:sub(1, 42) .. "...") or s
end

local function set(name)
  reg.set_pending(name)
  Submap.enter("NORMAL")
end

Submap.define({
  name = "REGISTERS",
  on_enter = function() vim.count.clear() end,
  escape = "NORMAL",
  catchall = "stay",
  binds = function()
    local result = {}

    local letters = "abcdefghijklmnopqrstuvwxyz"
    for i = 1, #letters do
      local c = letters:sub(i, i)
      local preview = reg_preview(reg_dir .. "/" .. c)
      result[#result + 1] = { c:upper(), function() set(c) end, preview }
    end

    for i = 1, 9 do
      local s = tostring(i)
      local preview = reg_preview(reg_dir .. "/" .. s)
      result[#result + 1] = { s, function() set(s) end, preview }
    end

    local unnamed_preview = reg_preview(reg_dir .. '/"')
    local yank_preview = reg_preview(reg_dir .. "/0")
    local pre_vim_preview = reg_preview(Clipboard.pre_vim_path())

    local term = Find.get_term()

    -- stylua: ignore start
    result[#result + 1] = { "SHIFT + APOSTROPHE", function() set('"') end, unnamed_preview  or "Unnamed register (default)" }
    result[#result + 1] = { "0",                  function() set("0") end, yank_preview and ("yank: " .. yank_preview) or "Yank register (last yank)" }
    result[#result + 1] = { "SHIFT + MINUS",      function() set("_") end, "Black hole register"                        }
    result[#result + 1] = { "SHIFT + EQUAL",      function() set("+") end, pre_vim_preview  or "System clipboard"       }
    result[#result + 1] = { "SHIFT + 8",          function() set("*") end, "Primary selection"                          }
    result[#result + 1] = { "SLASH",              function() set("/") end, term ~= "" and ("search: " .. term) or "Search register" }
    result[#result + 1] = { "SHIFT + SLASH",      wk.toggle                                                             }
    for _, row in ipairs(common.exit_rows()) do
      result[#result + 1] = row
    end
    -- stylua: ignore end

    return result
  end,
}).setup()

reg.enter_registers = function() Submap.enter("REGISTERS") end
