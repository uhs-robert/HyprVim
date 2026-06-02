-- Workspace keybinds: navigate and move windows across workspaces
--
-- CUSTOMIZE:
--   LEADER - your modifier key

local LEADER = "SUPER"

-- stylua: ignore start
local function dsp(d) return function() hl.dispatch(d) end end

-- Go to workspace 1-10 (LEADER + 1-0)
for i = 1, 10 do
  local k = tostring(i % 10)
  hl.bind(LEADER .. " + " .. k,         dsp(hl.dsp.focus({ workspace = i })),       { desc = "Go to Workspace " .. i })
  hl.bind(LEADER .. " + SHIFT + " .. k, dsp(hl.dsp.window.move({ workspace = i })), { desc = "Move to Workspace " .. i })
end

-- Cycle workspaces (LEADER + CTRL + h/l + arrows)
hl.bind(LEADER .. " + CTRL + H",     dsp(hl.dsp.focus({ workspace = "e-1" })),       { desc = "Prev Workspace",         repeating = true })
hl.bind(LEADER .. " + CTRL + LEFT",  dsp(hl.dsp.focus({ workspace = "e-1" })),       { desc = "Prev Workspace",         repeating = true })
hl.bind(LEADER .. " + CTRL + L",     dsp(hl.dsp.focus({ workspace = "e+1" })),       { desc = "Next Workspace",         repeating = true })
hl.bind(LEADER .. " + CTRL + RIGHT", dsp(hl.dsp.focus({ workspace = "e+1" })),       { desc = "Next Workspace",         repeating = true })

-- Move window to prev/next workspace (LEADER + CTRL + j/k + arrows)
hl.bind(LEADER .. " + CTRL + J",     dsp(hl.dsp.window.move({ workspace = "e-1" })), { desc = "Move to Prev Workspace" })
hl.bind(LEADER .. " + CTRL + DOWN",  dsp(hl.dsp.window.move({ workspace = "e-1" })), { desc = "Move to Prev Workspace" })
hl.bind(LEADER .. " + CTRL + K",     dsp(hl.dsp.window.move({ workspace = "e+1" })), { desc = "Move to Next Workspace" })
hl.bind(LEADER .. " + CTRL + UP",    dsp(hl.dsp.window.move({ workspace = "e+1" })), { desc = "Move to Next Workspace" })

-- stylua: ignore end
