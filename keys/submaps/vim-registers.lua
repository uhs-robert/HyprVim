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
    -- stylua: ignore start
    return {
      { "SHIFT + APOSTROPHE", function() set('"') end, "Unnamed register (default)" },
      { "0",                  function() set("0") end, "Yank register (last yank)"  },
      { "SHIFT + MINUS",      function() set("_") end, "Black hole register"        },
      { "PLUS",               function() set("+") end, "System clipboard"           },
      { "ASTERISK",           function() set("*") end, "Primary selection"          },
      { "SLASH",              function() set("/") end, "Search register"            },
      { "SHIFT + SLASH",      wk.toggle },
      { LEADER .. " + " .. ACT,  Submap.reset },
      { LEADER .. " + " .. EXIT, Submap.reset },
    }
    -- stylua: ignore end
  end,
}).setup()

--- Refresh: rebinds a-z and 1-9 with content preview desc (or no-op+nil when empty).
--- Called before each REGISTERS entry so HUD shows only filled slots.
local function refresh_registers()
  hl.define_submap("REGISTERS", function()
    local letters = "abcdefghijklmnopqrstuvwxyz"
    for i = 1, #letters do
      local c = letters:sub(i, i)
      local preview = reg_preview(reg_dir .. "/" .. c)
      if preview then
        hl.bind(c:upper(), function() set(c) end, { desc = preview })
      else
        hl.bind(c:upper(), function() end, { desc = nil })
      end
    end
    for i = 1, 9 do
      local s = tostring(i)
      local preview = reg_preview(reg_dir .. "/" .. s)
      if preview then
        hl.bind(s, function() set(s) end, { desc = preview })
      else
        hl.bind(s, function() end, { desc = nil })
      end
    end
    -- "  unnamed
    local unnamed_preview = reg_preview(reg_dir .. '/"')
    hl.bind("SHIFT + APOSTROPHE", function() set('"') end, { desc = unnamed_preview or "Unnamed register" })
    -- 0  yank
    local yank_preview = reg_preview(reg_dir .. "/0")
    hl.bind("0", function() set("0") end, { desc = yank_preview and ("yank: " .. yank_preview) or "Yank register" })
    -- /  search
    local term = nil
    local f = io.open(find_state_path, "r")
    if f then
      local data = f:read("*a")
      f:close()
      local t = data:match('"find_term"%s*:%s*"([^"]*)"')
      if t and t ~= "" then term = t end
    end
    hl.bind("SLASH", function() set("/") end, { desc = term and ("search: " .. term) or "Search register" })
    local pre_vim_preview = reg_preview(config.state_dir .. "/clipboard_pre_vim")
    hl.bind("SHIFT + EQUAL", function() set("+") end, { desc = pre_vim_preview or "System clipboard" })
    hl.bind("SHIFT + 8", function() set("*") end, { desc = "Primary selection" })
  end)
end

reg.enter_registers = function()
  refresh_registers()
  Submap.enter("REGISTERS")
end
