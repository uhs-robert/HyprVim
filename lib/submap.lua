--- Submap lifecycle manager for HyprVim.
--- Mirrors lib/key/submap.lua; state is tracked via hl.on so that raw
--- hl.dispatch calls (e.g. from normal-mode binds) also update current/previous.
local Bind = require("lib.bind") ---@class HyprVimBindLib

--- @class HyprVimSubmap
local Submap = {
  --- @type table<string, SubmapSpec>
  registry = {},
  --- @type string
  current = "reset",
  --- @type string|nil
  previous = nil,
}

--- @class SubmapContext
--- @field current  string
--- @field previous string|nil
--- @field submaps  table
--- @field [string] any

--- @class SubmapSpec
--- @field name      string
--- @field desc?     string
--- @field enter?    string|string[]
--- @field escape?   "reset"|"previous"|string|false|fun(ctx: SubmapContext)  Exit on ESCAPE; defaults to "reset"
--- @field back?     "escape"|string|false|fun(ctx: SubmapContext)  BackSpace target; default mirrors escape; false = no bind
--- @field catchall? "stay"|"reset"|false|fun(ctx: SubmapContext)   Unbound-key policy; defaults to false
--- @field on_enter? fun(ctx: SubmapContext)
--- @field on_exit?  fun(ctx: SubmapContext)
--- @field binds?    table[]|fun(): table[]

--- @class SubmapHandle
--- @field enter fun()
--- @field exit  fun()
--- @field back  fun()
--- @field setup fun()

--- Build a context table, optionally merged with extra fields.
--- @param extra table|nil
--- @return SubmapContext
local function context(extra)
  local ctx = { current = Submap.current, previous = Submap.previous, submaps = Submap }
  for k, v in pairs(extra or {}) do ctx[k] = v end
  return ctx
end

--- Track every submap transition through the compositor event so that state stays
--- correct even when code calls hl.dispatch(hl.dsp.submap(...)) directly.
hl.on("keybinds.submap", function(name)
  local prev_spec = Submap.registry[Submap.current]
  if prev_spec and prev_spec.on_exit then
    prev_spec.on_exit(context({ to = name }))
  end

  Submap.previous = Submap.current
  Submap.current = name

  local next_spec = Submap.registry[name]
  if next_spec and next_spec.on_enter then
    next_spec.on_enter(context({ from = Submap.previous }))
  end
end)

--- Activate a named submap (or "reset").
--- @param name string
function Submap.enter(name)
  hl.dispatch(hl.dsp.submap(name))
end

--- Return to the global (reset) submap.
function Submap.reset()
  hl.dispatch(hl.dsp.submap("reset"))
end

--- Return a function that switches to a named submap.
--- @param name string
--- @return fun()
function Submap.switch(name)
  return function() Submap.enter(name) end
end

--- Go back to the previous submap, or reset if there is none.
function Submap.back()
  local prev = Submap.previous
  if prev and prev ~= "reset" then
    Submap.enter(prev)
    Submap.previous = nil
    return
  end
  Submap.reset()
end

--- Resolve escape policy, defaulting to "reset".
--- @param spec SubmapSpec
local function normalize_escape(spec)
  if spec.escape == nil then return "reset" end
  return spec.escape
end

--- Resolve catchall policy, defaulting to false.
--- @param spec SubmapSpec
local function normalize_catchall(spec)
  if spec.catchall == nil then return false end
  return spec.catchall
end

--- Evaluate binds, calling the function if it is one.
--- @param binds table[]|fun(): table[]|nil
--- @return table[]|nil
local function resolve_binds(binds)
  if type(binds) == "function" then return binds() end
  return binds
end

--- Invoke an action: calls if function, dispatches if HL dispatcher.
--- @param action HL.Dispatcher|function
local function run(action)
  if type(action) == "function" then return action() end
  return hl.dispatch(action)
end

--- Wrap rows so every action calls exit_fn after firing (oneshot mode).
--- @param rows    table[]
--- @param exit_fn fun()
--- @return table[]
local function wrap_oneshot(rows, exit_fn)
  local wrapped = {}
  for _, row in ipairs(rows) do
    table.insert(wrapped, {
      row[1],
      function()
        run(row[2])
        exit_fn()
      end,
      row[3],
      row[4],
    })
  end
  return wrapped
end

--- Register the catchall bind for a submap.
--- @param catchall "stay"|"reset"|false|fun(ctx: SubmapContext)
--- @param exit_fn  fun()
--- @param spec     SubmapSpec
local function bind_catchall(catchall, exit_fn, spec)
  local opts = { release = true, ignore_mods = true }
  if catchall == "stay" then
    hl.bind("catchall", hl.dsp.no_op(), opts)
  elseif catchall == "reset" then
    hl.bind("catchall", exit_fn, opts)
  elseif type(catchall) == "function" then
    hl.bind("catchall", function() catchall(context({ spec = spec })) end, opts)
  end
end

--- Declare a submap and return a handle with enter/exit/back/setup methods.
--- Call handle.setup() once during startup to register all binds.
--- @param spec SubmapSpec
--- @return SubmapHandle
function Submap.define(spec)
  Submap.registry[spec.name] = spec

  local M = {}

  function M.enter() Submap.enter(spec.name) end

  function M.exit()
    local escape = normalize_escape(spec)
    if escape == false then return end
    if escape == "reset" then return Submap.reset() end
    if escape == "previous" then return Submap.back() end
    if type(escape) == "string" then return Submap.enter(escape) end
    if type(escape) == "function" then return escape(context({ spec = spec })) end
    Submap.reset()
  end

  function M.back()
    local back = spec.back
    if back == nil then return M.exit() end
    if back == false then return end
    if back == "escape" then return M.exit() end
    if type(back) == "string" then return Submap.enter(back) end
    if type(back) == "function" then return back(context({ spec = spec })) end
    M.exit()
  end

  function M.setup()
    if spec.enter then Bind.key(spec.enter, M.enter, spec.desc or ("+" .. spec.name)) end

    hl.define_submap(spec.name, function()
      local catchall = normalize_catchall(spec)
      local raw_binds = resolve_binds(spec.binds)
      local binds = catchall == "reset" and wrap_oneshot(raw_binds or {}, M.exit) or raw_binds

      Bind.keys(binds or {})

      if normalize_escape(spec) ~= false then
        Bind.key("ESCAPE", M.exit, "Exit " .. spec.name)
        if spec.back ~= false then
          local back_opts = catchall == "reset" and { release = true } or nil
          local back_label = type(spec.back) == "string" and ("Back to " .. spec.back) or ("Exit " .. spec.name)
          Bind.key("BackSpace", M.back, back_label, back_opts)
        end
      end

      bind_catchall(catchall, M.exit, spec)
    end)
  end

  return M
end

return Submap
