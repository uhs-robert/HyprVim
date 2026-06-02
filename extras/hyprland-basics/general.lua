-- General keybinds: window focus, move, close, fullscreen, scratchpad, monitors
--
-- CUSTOMIZE:
--   LEADER        - your modifier key
--   MONITOR_COUNT - number of monitors you have

local LEADER = "SUPER"
local MONITOR_COUNT = 1

-- stylua: ignore start
local function dsp(d) return function() hl.dispatch(d) end end

-- Window actions
hl.bind(LEADER .. " + C",   dsp(hl.dsp.window.close()),                          { desc = "Close Window" })
hl.bind(LEADER .. " + F",   dsp(hl.dsp.window.fullscreen({ action = "toggle" })), { desc = "Toggle Fullscreen" })
hl.bind(LEADER .. " + TAB", dsp(hl.dsp.focus({ workspace = "previous" })),        { desc = "Last Workspace" })

-- Focus (LEADER + h/j/k/l + arrows)
hl.bind(LEADER .. " + H",     dsp(hl.dsp.focus({ direction = "l" })), { desc = "Focus Left" })
hl.bind(LEADER .. " + LEFT",  dsp(hl.dsp.focus({ direction = "l" })), { desc = "Focus Left" })
hl.bind(LEADER .. " + J",     dsp(hl.dsp.focus({ direction = "d" })), { desc = "Focus Down" })
hl.bind(LEADER .. " + DOWN",  dsp(hl.dsp.focus({ direction = "d" })), { desc = "Focus Down" })
hl.bind(LEADER .. " + K",     dsp(hl.dsp.focus({ direction = "u" })), { desc = "Focus Up" })
hl.bind(LEADER .. " + UP",    dsp(hl.dsp.focus({ direction = "u" })), { desc = "Focus Up" })
hl.bind(LEADER .. " + L",     dsp(hl.dsp.focus({ direction = "r" })), { desc = "Focus Right" })
hl.bind(LEADER .. " + RIGHT", dsp(hl.dsp.focus({ direction = "r" })), { desc = "Focus Right" })

-- Move window (LEADER + SHIFT + h/j/k/l + arrows)
hl.bind(LEADER .. " + SHIFT + H",     dsp(hl.dsp.window.move({ direction = "l" })), { desc = "Move Window Left" })
hl.bind(LEADER .. " + SHIFT + LEFT",  dsp(hl.dsp.window.move({ direction = "l" })), { desc = "Move Window Left" })
hl.bind(LEADER .. " + SHIFT + J",     dsp(hl.dsp.window.move({ direction = "d" })), { desc = "Move Window Down" })
hl.bind(LEADER .. " + SHIFT + DOWN",  dsp(hl.dsp.window.move({ direction = "d" })), { desc = "Move Window Down" })
hl.bind(LEADER .. " + SHIFT + K",     dsp(hl.dsp.window.move({ direction = "u" })), { desc = "Move Window Up" })
hl.bind(LEADER .. " + SHIFT + UP",    dsp(hl.dsp.window.move({ direction = "u" })), { desc = "Move Window Up" })
hl.bind(LEADER .. " + SHIFT + L",     dsp(hl.dsp.window.move({ direction = "r" })), { desc = "Move Window Right" })
hl.bind(LEADER .. " + SHIFT + RIGHT", dsp(hl.dsp.window.move({ direction = "r" })), { desc = "Move Window Right" })

-- Scratchpad
hl.bind(LEADER .. " + S",         dsp(hl.dsp.workspace.toggle_special("scratchpad")),       { desc = "Toggle Scratchpad" })
hl.bind(LEADER .. " + SHIFT + S", dsp(hl.dsp.window.move({ workspace = "special:scratchpad" })), { desc = "Move to Scratchpad" })
-- stylua: ignore end

-- Monitor focus / move window to monitor (CTRL + number / CTRL+SHIFT + number)
for i = 1, MONITOR_COUNT do
  local k = tostring(i % 10)
  hl.bind(
    LEADER .. " + CTRL + " .. k,
    dsp(hl.dsp.focus({ monitor = tostring(i - 1) })),
    { desc = "Focus Monitor " .. i }
  )
  hl.bind(
    LEADER .. " + CTRL + SHIFT + " .. k,
    dsp(hl.dsp.window.move({ monitor = tostring(i - 1), follow = true })),
    { desc = "Move to Monitor " .. i }
  )
end
