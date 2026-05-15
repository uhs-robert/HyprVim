-- keys/submaps/init.lua
-- Load all submap definitions (order matters: modes before operators before marks).

--- @class SubmapModule
--- @field map SubmapEntry[]|table<string, SubmapEntry> Indexed array and name-keyed lookup of all registered submaps
--- @field setup fun() Loads all submap definition modules
local Submaps = {}

--- @class SubmapEntry
--- @field name string Hyprland submap name passed to hl.define_submap / hl.dsp.submap
--- @field label string Hyprland submap whichkey label
--- @field fn fun()|nil Optional override action; if nil, defaults to hl.dsp.submap(name)
--- @field defaults { hide: boolean, timeout: number }|nil Saved cursor config, set on entry

--- @type SubmapEntry[] | table<string, SubmapEntry>
Submaps.map = {
  -- stylua: ignore start
  { name = "NORMAL",    label = "+Normal" },
  { name = "INSERT",    label = "+Insert" },
  { name = "GOTO",      label = "+Goto" }, -- Was G-MOTION
  { name = "VISUAL",    label = "+Visual" },
  { name = "V-INSIDE",  label = "+V-Inside" },
  { name = "V-AROUND",  label = "+V-Around" },
  { name = "V-LINE",    label = "+V-Line" },
  { name = "G-VISUAL",  label = "+Goto" },
  { name = "G-VLINE",   label = "+Goto" },
  { name = "CHANGE",    label = "+Change"}, -- Was C-MOTION
  { name = "C-INSIDE",  label = "+C-Inside"},
  { name = "C-AROUND",  label = "+C-Around"},
  { name = "DELETE",    label = "+Delete"}, -- Was D-MOTION
  { name = "D-GOTO",    label = "+Goto"},
  { name = "D-INSIDE",  label = "+D-Inside"},
  { name = "D-AROUND",  label = "+D-Around"},
  { name = "YANK",      label = "+Yank"}, -- Was Y-MOTION
  { name = "Y-INSIDE",  label = "+Y-Inside"},
  { name = "Y-AROUND",  label = "+Y-Around"},
  { name = "MARKS",     label = "+Marks"}, -- Was JUMP-MARK
  { name = "SET-MARK",  label = "+Set-Mark"},
  { name = "REGISTERS", label = "+Registers"}, -- Was GET-REGISTER
}

--- Populates name-keyed aliases on `Submaps.map` and registers each entry's keybind.
--- Must run before any submap module is loaded so alias lookups (e.g. `Submaps.map.v_around`) resolve.
local function create_map_aliases()
  for _, sm in ipairs(Submaps.map) do
    local lower = sm.name:lower()
    Submaps.map[lower] = sm
    if lower:find("-", 1, true) then Submaps.map[lower:gsub("-", "_")] = sm end
  end
end

Submaps.setup = function()
  create_map_aliases()
  require("keys.submaps.modes")
  require("keys.submaps.vim-operators")
  require("keys.submaps.vim-marks")
  require("keys.submaps.vim-registers")
  require("keys.submaps.vim-replace-char")
end

return Submaps
