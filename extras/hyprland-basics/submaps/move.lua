-- Move submap: vim motions to move floating windows
--
-- Enter:  LEADER + M
-- Exit:   ESCAPE or BackSpace
-- Float:  F (toggle floating on the active window)
--
-- CUSTOMIZE: change LEADER to your modifier key

local LEADER = "SUPER"

local STEPS = { normal = 10, fast = 100, pixel = 1, ultra = 300 }

local function move(x, y)
  return function()
    hl.dispatch(hl.dsp.window.move({ x = x, y = y, relative = true }))
  end
end

local function enter_submap() hl.dispatch(hl.dsp.submap("Move")) end
local function exit_submap()  hl.dispatch(hl.dsp.submap("reset")) end

hl.bind(LEADER .. " + M", enter_submap, { desc = "+Move" })

hl.define_submap("Move", function()
  hl.bind("ESCAPE",    exit_submap, { desc = "Exit" })
  hl.bind("BackSpace", exit_submap, { desc = "Exit" })
  hl.bind("F", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
  end, { desc = "Toggle Floating" })

  local dirs = {
    { key = "H", arrow = "LEFT",  x = -1, y =  0 },
    { key = "J", arrow = "DOWN",  x =  0, y =  1 },
    { key = "K", arrow = "UP",    x =  0, y = -1 },
    { key = "L", arrow = "RIGHT", x =  1, y =  0 },
  }

  local tiers = {
    { mod = "",                 step = STEPS.normal, label = "" },
    { mod = "SHIFT + ",         step = STEPS.fast,   label = " (Fast)" },
    { mod = "CTRL + ",          step = STEPS.pixel,  label = " (Pixel)" },
    { mod = "CTRL + SHIFT + ",  step = STEPS.ultra,  label = " (Ultra)" },
  }

  for _, tier in ipairs(tiers) do
    for _, d in ipairs(dirs) do
      local action = move(d.x * tier.step, d.y * tier.step)
      local opts = { desc = "Move " .. d.key .. tier.label, repeating = true }
      hl.bind(tier.mod .. d.key,   action, opts)
      hl.bind(tier.mod .. d.arrow, action, opts)
    end
  end

  hl.bind("catchall", hl.dsp.no_op(), { release = true, ignore_mods = true })
end)
