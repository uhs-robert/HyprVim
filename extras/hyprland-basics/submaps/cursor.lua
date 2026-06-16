-- This files includes two submaps for keyboard-driven mouse control.
--
-- EXTERNAL DEPENDENCIES:
--    wlrctl   - pointer movement and clicks  https://github.com/atx/wlrctl
--    wl-kbptr - label-jump targeting (optional)  https://git.sr.ht/~brocellous/wl-kbptr
--
-- CURSOR SUBMAP: comprehensive keyboard-driven mouse control
--    Enter:  LEADER + X
--    Exit:   ESCAPE or BackSpace
--
-- QUICKCLICK SUBMAP: quick label-jump clicks for oneshot clicking
--    Enter:  LEADER + SEMICOLON
--    Exit:   ESCAPE or BackSpace
--
-- CUSTOMIZE: change LEADER to your modifier key

local LEADER = "SUPER"

local function exec(cmd)
  return function() hl.dispatch(hl.dsp.exec_cmd(cmd)) end
end

local function send_key(key)
  return function() hl.dispatch(hl.dsp.send_shortcut({ mods = "", key = key })) end
end

local function enter_submap(name) hl.dispatch(hl.dsp.submap(name)) end
local function exit_submap() hl.dispatch(hl.dsp.submap("reset")) end
local function oneshot(fn_or_dsp)
  local fn = type(fn_or_dsp) == "function" and fn_or_dsp or function() hl.dispatch(fn_or_dsp) end
  return function()
    fn()
    exit_submap()
  end
end

local WL_KBPTR = {
  floating_click = "wl-kbptr -o modes=floating,click -o mode_floating.source=detect",
  floating_r_click = "wl-kbptr -o modes=floating -o mode_floating.source=detect ; wlrctl pointer click right",
  floating_move = "wl-kbptr -o modes=floating -o mode_floating.source=detect",
  tile_click = "wl-kbptr -o modes=tile,click",
  tile_r_click = "wl-kbptr -o modes=tile ; wlrctl pointer click right",
  tile_move = "wl-kbptr -o modes=tile",
}

--- Returns a `kbptr(mode, opts?)` function bound to `submap_name`.
--- Calling the returned function with no opts re-enters `submap_name`; `{ exit = true }` exits instead.
---@param submap_name string submap to re-enter by default
---@return fun(mode: string, opts?: {exit: boolean}): function
local function make_kbptr(submap_name)
  return function(mode, opts)
    local cmd = WL_KBPTR[mode]
    local target = (opts and opts.exit) and "reset" or submap_name
    return function()
      hl.dispatch(hl.dsp.submap("reset"))
      hl.dispatch(hl.dsp.exec_cmd(string.format("%s ; hyprctl dispatch 'hl.dsp.submap(\"%s\")'", cmd, target)))
    end
  end
end

-- -- Cursor --------------------------------------------------------------------

hl.bind(LEADER .. " + X", function() enter_submap("Cursor") end, { desc = "+Cursor" })

hl.define_submap("Cursor", function()
  local kbptr = make_kbptr("Cursor")
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

  -- Space Clicks
  hl.bind("SPACE", exec("wlrctl pointer click left"), { desc = "Left Click" })
  hl.bind("SHIFT + SPACE", exec("wlrctl pointer click right"), { desc = "Right Click" })
  hl.bind("CTRL + SPACE", exec("wlrctl pointer click middle"), { desc = "Middle Click" })

  -- A,D,S Clicks
  hl.bind("A", exec("wlrctl pointer click left"), { desc = "Left Click" })
  hl.bind("D", exec("wlrctl pointer click right"), { desc = "Right Click" })
  hl.bind("S", exec("wlrctl pointer click middle"), { desc = "Middle Click" })
  hl.bind("CTRL + A", oneshot(hl.dsp.exec_cmd("wlrctl pointer click left")), { desc = "Left Click (Exit)" })
  hl.bind("CTRL + S", oneshot(hl.dsp.exec_cmd("wlrctl pointer click middle")), { desc = "Middle Click (Exit)" })

  -- Page Up/Down
  hl.bind("CTRL + U", send_key("prior"), { desc = "Page Up" })
  hl.bind("CTRL + D", send_key("next"), { desc = "Page Down" })

  -- Send arrow keys to focused window (ALT + h/j/k/l)
  hl.bind("ALT + H", send_key("LEFT"), { desc = "Arrow Left", repeating = true })
  hl.bind("ALT + J", send_key("DOWN"), { desc = "Arrow Down", repeating = true })
  hl.bind("ALT + K", send_key("UP"), { desc = "Arrow Up", repeating = true })
  hl.bind("ALT + L", send_key("RIGHT"), { desc = "Arrow Right", repeating = true })

  -- Quick Clicks (SUPER+SEMICOLON skips QuickClick submap, clicks directly)
  hl.bind(LEADER .. " + SEMICOLON", kbptr("floating_click", { exit = true }))
  hl.bind("SEMICOLON", kbptr("floating_click", { exit = true }), { desc = "Floating Click (Exit)" })
  hl.bind("SHIFT + SEMICOLON", kbptr("tile_click", { exit = true }), { desc = "Tiling Click (Exit)" })
  hl.bind("APOSTROPHE", kbptr("floating_r_click"), { desc = "Floating Right Click" })
  hl.bind("SHIFT + APOSTROPHE", kbptr("tile_r_click"), { desc = "Tiling Right Click" })

  -- Modes (bare=left, SHIFT=right, CTRL=move)
  hl.bind("F", kbptr("floating_click"), { desc = "Floating Click" })
  hl.bind("SHIFT + F", kbptr("floating_r_click"), { desc = "Floating Right Click" })
  hl.bind("CTRL + F", kbptr("floating_move"), { desc = "Floating Move" })
  hl.bind("T", kbptr("tile_click"), { desc = "Tile Click" })
  hl.bind("SHIFT + T", kbptr("tile_r_click"), { desc = "Tile Right Click" })
  hl.bind("CTRL + T", kbptr("tile_move"), { desc = "Tile Move" })

  hl.bind("catchall", hl.dsp.no_op(), { release = true, ignore_mods = true })
end)

-- -- QuickClick ----------------------------------------------------------------

hl.bind(LEADER .. " + SEMICOLON", function() enter_submap("QuickClick") end, { desc = "+Quick Click" })

hl.define_submap("QuickClick", function()
  local kbptr = make_kbptr("QuickClick")
  hl.bind("ESCAPE", exit_submap, { desc = "Exit" })
  hl.bind("BackSpace", exit_submap, { desc = "Exit" })

  -- quick_click
  hl.bind("SEMICOLON", kbptr("floating_click", { exit = true }), { desc = "Floating Click (Exit)" })
  hl.bind("APOSTROPHE", kbptr("floating_r_click"), { desc = "Floating Right Click" })
  hl.bind("SHIFT + SEMICOLON", kbptr("tile_click", { exit = true }), { desc = "Tile Click (Exit)" })

  -- quicker_click: re-trigger without navigating submap
  hl.bind(LEADER .. " + SEMICOLON", kbptr("floating_click", { exit = true }))
  hl.bind(LEADER .. " + APOSTROPHE", kbptr("floating_r_click"))

  -- wl-kbptr modes (bare=left, SHIFT=right, CTRL=move)
  hl.bind("F", kbptr("floating_click"), { desc = "Floating Click" })
  hl.bind("SHIFT + F", kbptr("floating_r_click"), { desc = "Floating Right Click" })
  hl.bind("CTRL + F", kbptr("floating_move"), { desc = "Floating Move" })
  hl.bind("T", kbptr("tile_click"), { desc = "Tile Click" })
  hl.bind("SHIFT + T", kbptr("tile_r_click"), { desc = "Tile Right Click" })
  hl.bind("CTRL + T", kbptr("tile_move"), { desc = "Tile Move" })

  hl.bind("catchall", hl.dsp.no_op(), { release = true, ignore_mods = true })
end)
