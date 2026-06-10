-- keys/submaps/vim-registers.lua
-- REGISTERS submap activated by " in NORMAL mode

local Submap = require("lib.submap") ---@class HyprVimSubmap
local vim = require("vim") ---@class Vim
local reg = vim.registers
local wk = require("whichkey") ---@class WhichKey
local config = require("config") ---@class HyprVimConfigModule
local LEADER = config.keys.leader or "SUPER"
local ACT = config.keys.activate or "ESCAPE"
local EXIT = config.keys.exit or "ESCAPE"

local reg_dir = config.state_dir .. "/registers"
local find_state_path = config.state_dir .. "/find-state.json"

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
    local pre_vim_preview = reg_preview(config.state_dir .. "/clipboard_pre_vim")

    local term = nil
    local f = io.open(find_state_path, "r")
    if f then
      local data = f:read("*a")
      f:close()
      local t = data:match('"find_term"%s*:%s*"([^"]*)"')
      if t and t ~= "" then term = t end
    end

    -- stylua: ignore start
    result[#result + 1] = { "SHIFT + APOSTROPHE", function() set('"') end, unnamed_preview  or "Unnamed register (default)" }
    result[#result + 1] = { "0",                  function() set("0") end, yank_preview and ("yank: " .. yank_preview) or "Yank register (last yank)" }
    result[#result + 1] = { "SHIFT + MINUS",      function() set("_") end, "Black hole register"                        }
    result[#result + 1] = { "PLUS",               function() set("+") end, pre_vim_preview  or "System clipboard"       }
    result[#result + 1] = { "ASTERISK",           function() set("*") end, "Primary selection"                          }
    result[#result + 1] = { "SLASH",              function() set("/") end, term and ("search: " .. term) or "Search register" }
    result[#result + 1] = { "SHIFT + SLASH",      wk.toggle                                                             }
    result[#result + 1] = { LEADER .. " + " .. ACT,  Submap.reset                                                       }
    result[#result + 1] = { LEADER .. " + " .. EXIT, Submap.reset                                                       }
    -- stylua: ignore end

    return result
  end,
}).setup()

reg.enter_registers = function() Submap.enter("REGISTERS") end
