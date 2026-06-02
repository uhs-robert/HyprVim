-- hypr/rules.lua
-- Window rules for HyprVim floating windows.

local function setup()
  -- prompt bar: full-width bottom bar for replace/command/find input
  for _, class in ipairs({ "hyprvim-command", "hyprvim-replace", "hyprvim-find", "hyprvim-prompt" }) do
    hl.window_rule({
      name = class,
      match = { class = "^" .. class .. "$" },
      float = true,
      size = "(monitor_w) 40",
      move = "0 (monitor_h - 40)",
      animation = "slide bottom",
    })
  end

  -- whichkey: submap display layer
  hl.layer_rule({
    name = "hyprvim-whichkey",
    match = { namespace = "hyprvim-whichkey" },
    no_anim = true,
  })

  -- hyprvim-help: help display for command mode
  hl.window_rule({
    name = "hyprvim-help",
    match = { class = "^hyprvim-help$" },
    size = "(monitor_w) (monitor_h * 0.6)",
    float = true,
    move = "0 (monitor_h * 0.4)",
    animation = "slide bottom",
  })

  -- hyprvim-shell: shell exec output viewer, slides up from bottom
  hl.window_rule({
    name = "hyprvim-shell",
    match = { class = "^hyprvim-shell$" },
    float = true,
    size = "(monitor_w) (monitor_h * 0.6)",
    move = "0 (monitor_h * 0.4)",
    animation = "slide bottom",
  })

  -- hyprvim-open-vim: open-editor scratch buffer
  hl.window_rule({
    name = "hyprvim-open-vim",
    match = { class = "^hyprvim-open-vim$" },
    float = true,
    center = true,
    size = "(monitor_w*0.7) (monitor_h*0.7)",
  })
end

return { setup = setup }
