--- Key binding helpers built on top of hl.bind.

local config = require("config")

--- @class HyprVimBindLib
local Bind = {
  leader = (config.keys or {}).leader or "SUPER",
}

--- @param value string|string[]
--- @return string[]
local function as_list(value)
  if type(value) == "table" then return value end
  return { value }
end

--- @param prefix string
--- @param key    string
--- @return string
local function with_prefix(prefix, key)
  if not prefix or prefix == "" then return key end
  return prefix .. " + " .. key
end

--- @param keys   string|string[]
--- @param action HL.Dispatcher|function
--- @param desc   string|HL.BindOptions|nil
--- @param opts   HL.BindOptions|nil
function Bind.key(keys, action, desc, opts)
  if type(desc) == "table" and opts == nil then
    opts = desc
    desc = nil
  end

  opts = opts or {}

  if desc then opts.desc = desc end

  for _, key in ipairs(as_list(keys)) do
    hl.bind(key, action, opts)
  end
end

--- @param keys   string|string[]
--- @param action HL.Dispatcher|function
--- @param desc   string|HL.BindOptions|nil
--- @param opts   HL.BindOptions|nil
function Bind.leader_key(keys, action, desc, opts)
  local prefixed = {}
  for _, k in ipairs(as_list(keys)) do
    table.insert(prefixed, with_prefix(Bind.leader, k))
  end
  Bind.key(prefixed, action, desc, opts)
end

--- @param keys string|string[]
--- @param cmd  string
--- @param desc string|HL.BindOptions|nil
--- @param opts HL.BindOptions|nil
function Bind.cmd(keys, cmd, desc, opts) Bind.key(keys, hl.dsp.exec_cmd(cmd), desc, opts) end

--- @param keys string|string[]
--- @param cmd  string
--- @param desc string|HL.BindOptions|nil
--- @param opts HL.BindOptions|nil
function Bind.leader_cmd(keys, cmd, desc, opts) Bind.leader_key(keys, hl.dsp.exec_cmd(cmd), desc, opts) end

--- @param keys   string|string[]
--- @param f      function
--- @param desc   string|HL.BindOptions|nil
--- @param opts   HL.BindOptions|nil
function Bind.fn(keys, f, desc, opts, ...)
  local args = { ... }
  Bind.key(keys, function() f(table.unpack(args)) end, desc, opts)
end

--- @param keys   string|string[]
--- @param f      function
--- @param desc   string|HL.BindOptions|nil
--- @param opts   HL.BindOptions|nil
function Bind.leader_fn(keys, f, desc, opts, ...)
  local args = { ... }
  Bind.leader_key(keys, function() f(table.unpack(args)) end, desc, opts)
end

--- @param rows     { [1]: string|string[], [2]: any, [3]: string, [4]: HL.BindOptions|nil }[]
--- @param defaults HL.BindOptions|nil
function Bind.keys(rows, defaults)
  for _, row in ipairs(rows or {}) do
    local opts = {}
    for k, v in pairs(defaults or {}) do
      opts[k] = v
    end
    for k, v in pairs(row[4] or {}) do
      opts[k] = v
    end
    Bind.key(row[1], row[2], row[3], opts)
  end
end

---Pass the key through to the active window unchanged.
---@return fun()
function Bind.pass()
  return function() hl.dispatch(hl.dsp.pass()) end
end

return Bind
