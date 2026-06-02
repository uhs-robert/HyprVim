-- Windows submap: focus, workspaces, and window management
--
-- Enter:  LEADER + W
-- Exit:   ESCAPE or BackSpace
--
-- CUSTOMIZE:
--   LEADER        - your modifier key
--   MONITOR_COUNT - number of monitors you have (for number-key monitor focus)

local LEADER = "SUPER"
local MONITOR_COUNT = 1

local function dsp(d) return function() hl.dispatch(d) end end

local function enter_submap() hl.dispatch(hl.dsp.submap("Windows")) end
local function exit_submap()  hl.dispatch(hl.dsp.submap("reset")) end

hl.bind(LEADER .. " + W", enter_submap, { desc = "+Windows" })

hl.define_submap("Windows", function()
  hl.bind("ESCAPE",    exit_submap, { desc = "Exit" })
  hl.bind("BackSpace", exit_submap, { desc = "Exit" })

  -- Focus (h/j/k/l + arrows)
  hl.bind("H",     dsp(hl.dsp.focus({ direction = "l" })), { desc = "Focus Left" })
  hl.bind("LEFT",  dsp(hl.dsp.focus({ direction = "l" })), { desc = "Focus Left" })
  hl.bind("J",     dsp(hl.dsp.focus({ direction = "d" })), { desc = "Focus Down" })
  hl.bind("DOWN",  dsp(hl.dsp.focus({ direction = "d" })), { desc = "Focus Down" })
  hl.bind("K",     dsp(hl.dsp.focus({ direction = "u" })), { desc = "Focus Up" })
  hl.bind("UP",    dsp(hl.dsp.focus({ direction = "u" })), { desc = "Focus Up" })
  hl.bind("L",     dsp(hl.dsp.focus({ direction = "r" })), { desc = "Focus Right" })
  hl.bind("RIGHT", dsp(hl.dsp.focus({ direction = "r" })), { desc = "Focus Right" })

  -- Move window (SHIFT + h/j/k/l)
  hl.bind("SHIFT + H", dsp(hl.dsp.window.move({ direction = "l" })), { desc = "Move Left" })
  hl.bind("SHIFT + J", dsp(hl.dsp.window.move({ direction = "d" })), { desc = "Move Down" })
  hl.bind("SHIFT + K", dsp(hl.dsp.window.move({ direction = "u" })), { desc = "Move Up" })
  hl.bind("SHIFT + L", dsp(hl.dsp.window.move({ direction = "r" })), { desc = "Move Right" })

  -- Workspace cycling (CTRL + h/l) and move window (CTRL + j/k)
  hl.bind("CTRL + H",     dsp(hl.dsp.focus({ workspace = "e-1" })),       { desc = "Prev Workspace" })
  hl.bind("CTRL + LEFT",  dsp(hl.dsp.focus({ workspace = "e-1" })),       { desc = "Prev Workspace" })
  hl.bind("CTRL + L",     dsp(hl.dsp.focus({ workspace = "e+1" })),       { desc = "Next Workspace" })
  hl.bind("CTRL + RIGHT", dsp(hl.dsp.focus({ workspace = "e+1" })),       { desc = "Next Workspace" })
  hl.bind("CTRL + K",     dsp(hl.dsp.window.move({ workspace = "e+1" })), { desc = "Move to Next WS" })
  hl.bind("CTRL + UP",    dsp(hl.dsp.window.move({ workspace = "e+1" })), { desc = "Move to Next WS" })
  hl.bind("CTRL + J",     dsp(hl.dsp.window.move({ workspace = "e-1" })), { desc = "Move to Prev WS" })
  hl.bind("CTRL + DOWN",  dsp(hl.dsp.window.move({ workspace = "e-1" })), { desc = "Move to Prev WS" })

  -- Last workspace
  hl.bind("TAB", dsp(hl.dsp.focus({ workspace = "previous" })), { desc = "Last Workspace" })

  -- Move window to workspace 1-10 (SHIFT + number)
  for i = 1, 10 do
    hl.bind("SHIFT + " .. tostring(i % 10), dsp(hl.dsp.window.move({ workspace = i })), { desc = "Move to WS " .. i })
  end

  -- Monitor focus (number keys map to monitor 0-based ID)
  for i = 1, MONITOR_COUNT do
    local k = tostring(i % 10)
    hl.bind(k, dsp(hl.dsp.focus({ monitor = tostring(i - 1) })), { desc = "Monitor " .. i })
  end

  -- Window actions
  hl.bind("C",      dsp(hl.dsp.window.kill()),                       { desc = "Close Window" })
  hl.bind("F",      dsp(hl.dsp.window.float({ action = "toggle" })), { desc = "Toggle Floating" })
  hl.bind("P",      dsp(hl.dsp.window.pseudo()),                     { desc = "Toggle Pseudo" })
  hl.bind("S",      dsp(hl.dsp.layout("togglesplit")),               { desc = "Toggle Split" })
  hl.bind("MINUS",  dsp(hl.dsp.layout("togglesplit")),               { desc = "Toggle Split" })
  hl.bind("RETURN", dsp(hl.dsp.pass({ window = "active" })),         { desc = "Confirm" })

  hl.bind("catchall", hl.dsp.no_op(), { release = true, ignore_mods = true })
end)
