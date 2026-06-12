-- Resize submap: vim motions to resize the active window
--
-- Enter:  LEADER + R
-- Exit:   ESCAPE or BackSpace
-- Reset:  = (toggles float twice to recalculate layout)
--
-- CUSTOMIZE: change LEADER to your modifier key (e.g. "SUPER", "SUPER + ALT")

local LEADER = "SUPER"

local STEPS = { normal = 10, fast = 100, pixel = 1, ultra = 300 }

local function resize(x, y)
  return function() hl.dispatch(hl.dsp.window.resize({ x = x, y = y, relative = true })) end
end

local function reset_size()
  hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
  hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
end

local function enter_submap() hl.dispatch(hl.dsp.submap("Resize")) end
local function exit_submap() hl.dispatch(hl.dsp.submap("reset")) end

hl.bind(LEADER .. " + R", enter_submap, { desc = "+Resize" })

hl.define_submap("Resize", function()
  hl.bind("ESCAPE", exit_submap, { desc = "Exit" })
  hl.bind("BackSpace", exit_submap, { desc = "Exit" })
  hl.bind("EQUAL", reset_size, { desc = "Reset Size" })

  local dirs = {
    { key = "H", arrow = "LEFT", x = -1, y = 0 },
    { key = "J", arrow = "DOWN", x = 0, y = 1 },
    { key = "K", arrow = "UP", x = 0, y = -1 },
    { key = "L", arrow = "RIGHT", x = 1, y = 0 },
  }

  local tiers = {
    { mod = "", step = STEPS.normal, label = "" },
    { mod = "SHIFT + ", step = STEPS.fast, label = " (Fast)" },
    { mod = "CTRL + ", step = STEPS.pixel, label = " (Pixel)" },
    { mod = "CTRL + SHIFT + ", step = STEPS.ultra, label = " (Ultra)" },
  }

  for _, tier in ipairs(tiers) do
    for _, d in ipairs(dirs) do
      local action = resize(d.x * tier.step, d.y * tier.step)
      local opts = { desc = "Resize " .. d.key .. tier.label, repeating = true }
      hl.bind(tier.mod .. d.key, action, opts)
      hl.bind(tier.mod .. d.arrow, action, opts)
    end
  end

  hl.bind("catchall", hl.dsp.no_op(), { release = true, ignore_mods = true })
end)
