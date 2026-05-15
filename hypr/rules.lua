-- hypr/rules.lua
-- Window rules for HyprVim floating windows.

local Config = require("config") ---@class HyprVimConfigModule

local function setup()
  -- floating-help: help viewer opened by `gh`
  hl.window_rule({
    name = "hyprvim-floating-help",
    match = { class = "^floating-help$" },
    float = true,
    center = true,
    size = "(monitor_w*0.8) (monitor_h*0.8)",
  })

  -- hyprvim-find: find/search prompt (narrow bar at top)
  hl.window_rule({
    name = "hyprvim-find",
    match = { class = "^hyprvim-find$" },
    float = true,
    size = "600 80",
    move = "onscreen 50% 5%",
  })

  -- hyprvim-open-vim: open-editor scratch buffer
  hl.window_rule({
    name = "hyprvim-open-vim",
    match = { class = "^hyprvim-open-vim$" },
    float = true,
    center = true,
    size = "(monitor_w*0.6) (monitor_h*0.6)",
  })
end

return { setup = setup }
