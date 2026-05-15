-- keys/submaps/vim-registers.lua
-- GET-REGISTER submap — activated by " in NORMAL mode

local vim = require("vim") ---@class vim
local reg = vim.registers
local wk = require("whichkey") ---@class WhichKey

local leader = (require("config").keys or {}).leader or "SUPER"
local act = (require("config").keys or {}).activate or "ESCAPE"

---@param keys string
---@param fn fun()
local function b(keys, fn) hl.bind(keys, fn) end

---@param keys string
---@param desc string
---@param fn fun()
local function bd(keys, desc, fn) hl.bind(keys, fn, { description = desc }) end

---@param n string  submap name
local function submap(n) hl.dispatch(hl.dsp.submap(n)) end

---Store `name` as the pending register and return to NORMAL mode.
---@param name string  register name (e.g. `"a"`, `'"'`, `"_"`)
local function set(name)
  reg.set_pending(name)
  submap("NORMAL")
end

hl.define_submap("GET-REGISTER", "reset", function()
  -- Special registers
  bd("SHIFT + APOSTROPHE", "Unnamed register (default)", function()
    set('"')
  end)
  bd("0", "Yank register (last yank)", function()
    set("0")
  end)
  bd("SHIFT + MINUS", "Black hole register", function()
    set("_")
  end)
  bd("SLASH", "Search register", function()
    set("/")
  end)

  -- Named registers a-z
  local letters = "abcdefghijklmnopqrstuvwxyz"
  for i = 1, #letters do
    local c = letters:sub(i, i)
    bd(c:upper(), "Register " .. c, function()
      set(c)
    end)
  end

  -- Number registers 1-9 (0 already handled as yank register above)
  for i = 1, 9 do
    local s = tostring(i)
    b(s, function()
      set(s)
    end)
  end

  -- Footer
  b("ESCAPE", function()
    submap("NORMAL")
  end)
  b(leader .. " + " .. act, function()
    hl.dispatch(hl.dsp.submap("reset"))
  end)
  b("SHIFT + SLASH", function()
    wk.toggle()
  end)
  b("catchall", function()
    submap("GET-REGISTER")
  end)
end)
