-- Cursor submap: keyboard-driven mouse control
--
-- Enter:  LEADER + X
-- Exit:   ESCAPE or BackSpace
--
-- External dependencies:
--   wlrctl   - pointer movement and clicks  https://github.com/atx/wlrctl
--   wl-kbptr - label-jump targeting (optional)  https://git.sr.ht/~brocellous/wl-kbptr
--
-- CUSTOMIZE: change LEADER to your modifier key

local LEADER = "SUPER"

local function exec(cmd)
  return function() hl.dispatch(hl.dsp.exec_cmd(cmd)) end
end

local function send_key(key)
  return function() hl.dispatch(hl.dsp.send_shortcut({ mods = "", key = key })) end
end

local function enter_submap() hl.dispatch(hl.dsp.submap("Cursor")) end
local function exit_submap() hl.dispatch(hl.dsp.submap("reset")) end

hl.bind(LEADER .. " + X", enter_submap, { desc = "+Cursor" })

hl.define_submap("Cursor", function()
  hl.bind("ESCAPE", exit_submap, { desc = "Exit" })
  hl.bind("BackSpace", exit_submap, { desc = "Exit" })

  -- Cursor movement (h/j/k/l + arrows, four speed tiers)
  local move_dirs = {
    { key = "H", arrow = "LEFT", x = -1, y = 0 },
    { key = "J", arrow = "DOWN", x = 0, y = 1 },
    { key = "K", arrow = "UP", x = 0, y = -1 },
    { key = "L", arrow = "RIGHT", x = 1, y = 0 },
  }

  local move_tiers = {
    { mod = "", step = 10, label = "" },
    { mod = "SHIFT + ", step = 100, label = " (Fast)" },
    { mod = "CTRL + ", step = 1, label = " (Pixel)" },
    { mod = "CTRL + SHIFT + ", step = 300, label = " (Ultra)" },
  }

  for _, tier in ipairs(move_tiers) do
    for _, d in ipairs(move_dirs) do
      local cmd = string.format("wlrctl pointer move %d %d", d.x * tier.step, d.y * tier.step)
      local opts = { desc = "Cursor " .. d.key .. tier.label, repeating = true }
      hl.bind(tier.mod .. d.key, exec(cmd), opts)
      hl.bind(tier.mod .. d.arrow, exec(cmd), opts)
    end
  end

  -- Scroll (e=up, y=down, ,=left, .=right)
  local scroll_tiers = {
    { mod = "", step = 10, label = "" },
    { mod = "SHIFT + ", step = 100, label = " (Fast)" },
    { mod = "CTRL + ", step = 1, label = " (Pixel)" },
  }

  for _, tier in ipairs(scroll_tiers) do
    hl.bind(
      tier.mod .. "E",
      exec("wlrctl pointer scroll " .. tier.step .. " 0"),
      { desc = "Scroll Up" .. tier.label, repeating = true }
    )
    hl.bind(
      tier.mod .. "Y",
      exec("wlrctl pointer scroll -" .. tier.step .. " 0"),
      { desc = "Scroll Down" .. tier.label, repeating = true }
    )
    hl.bind(
      tier.mod .. "COMMA",
      exec("wlrctl pointer scroll 0 -" .. tier.step),
      { desc = "Scroll Left" .. tier.label, repeating = true }
    )
    hl.bind(
      tier.mod .. "PERIOD",
      exec("wlrctl pointer scroll 0 " .. tier.step),
      { desc = "Scroll Right" .. tier.label, repeating = true }
    )
  end

  -- Clicks
  hl.bind("SPACE", exec("wlrctl pointer click left"), { desc = "Left Click" })
  hl.bind("A", exec("wlrctl pointer click left"), { desc = "Left Click" })
  hl.bind("D", exec("wlrctl pointer click right"), { desc = "Right Click" })
  hl.bind("S", exec("wlrctl pointer click middle"), { desc = "Middle Click" })
  hl.bind("CTRL + SPACE", exec("wlrctl pointer click right"), { desc = "Right Click" })
  hl.bind("SHIFT + SPACE", exec("wlrctl pointer click middle"), { desc = "Middle Click" })

  -- Click then exit submap
  hl.bind("CTRL + A", function()
    hl.dispatch(hl.dsp.exec_cmd("wlrctl pointer click left"))
    exit_submap()
  end, { desc = "Left Click (Exit)" })
  hl.bind("CTRL + S", function()
    hl.dispatch(hl.dsp.exec_cmd("wlrctl pointer click middle"))
    exit_submap()
  end, { desc = "Middle Click (Exit)" })

  -- Page Up/Down
  hl.bind("CTRL + U", send_key("prior"), { desc = "Page Up" })
  hl.bind("CTRL + D", send_key("next"), { desc = "Page Down" })

  -- Send arrow keys to focused window (ALT + h/j/k/l)
  hl.bind("ALT + H", send_key("LEFT"), { desc = "Arrow Left", repeating = true })
  hl.bind("ALT + J", send_key("DOWN"), { desc = "Arrow Down", repeating = true })
  hl.bind("ALT + K", send_key("UP"), { desc = "Arrow Up", repeating = true })
  hl.bind("ALT + L", send_key("RIGHT"), { desc = "Arrow Right", repeating = true })

  -- wl-kbptr label-jump modes
  local KBPTR = {
    floating_click = "wl-kbptr -o modes=floating,click -o mode_floating.source=detect",
    floating_move = "wl-kbptr -o modes=floating -o mode_floating.source=detect",
    tile_click = "wl-kbptr -o modes=tile,click",
    tile_move = "wl-kbptr -o modes=tile",
  }

  -- Stay in Cursor after wl-kbptr completes
  local function kbptr(mode)
    local cmd = KBPTR[mode]
    return function()
      hl.dispatch(hl.dsp.submap("reset"))
      hl.dispatch(hl.dsp.exec_cmd(cmd .. " ; hyprctl dispatch 'hl.dsp.submap(\"Cursor\")'"))
    end
  end

  -- Exit after wl-kbptr completes
  local function kbptr_exit(mode)
    local cmd = KBPTR[mode]
    return function()
      exit_submap()
      hl.dispatch(hl.dsp.exec_cmd(cmd .. " ; hyprctl dispatch 'hl.dsp.submap(\"reset\")'"))
    end
  end

  hl.bind("F", kbptr("floating_click"), { desc = "Floating Click" })
  hl.bind("CTRL + F", kbptr_exit("floating_click"), { desc = "Floating Click (Exit)" })
  hl.bind("SHIFT + F", kbptr("floating_move"), { desc = "Floating Move" })
  hl.bind("T", kbptr("tile_click"), { desc = "Tile Click" })
  hl.bind("CTRL + T", kbptr_exit("tile_click"), { desc = "Tile Click (Exit)" })
  hl.bind("SHIFT + T", kbptr("tile_move"), { desc = "Tile Move" })

  hl.bind("catchall", hl.dsp.no_op(), { release = true, ignore_mods = true })
end)
