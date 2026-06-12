## 🛟 WhichKey

The WhichKey HUD shows the available bindings for the current submap, including their descriptions.

<https://github.com/user-attachments/assets/7fdb5c63-48a5-4f8f-9280-0da408503d6e>

<p align=center><i>It works for HyprVim submaps and your own submaps too.</i></p>

## ⚙️ Configuration

### Requirements

| Tool                                  | Description                         |
| ------------------------------------- | ----------------------------------- |
| [eww](https://github.com/elkowar/eww) | Renders the HUD overlay             |
| `socat`                               | Listens for Hyprland submap changes |

### Setup

Enable WhichKey from your Lua config:

```lua
require("lua/plugins/hyprvim").setup({
  which_key = {
    enabled = true,
    delay_ms = 0,
    vim_delay_ms = 300,
    position = "bottom-right",
    auto_show = {
      disabled = { "NORMAL", "VISUAL", "V-LINE", "INSERT" },
      enabled = nil,
    },
  },
})
```

The important knobs are:

- `enabled` turns the HUD on or off
- `delay_ms` controls the normal submap delay
- `vim_delay_ms` gives operator-pending submaps a different delay
- `position` anchors the HUD
- `auto_show.disabled` suppresses specific submaps
- `auto_show.enabled` whitelists only the listed submaps

### Usage

The HUD auto-shows when you enter a submap and hides when you leave it. Press `SPACE` to toggle it manually from any mode.

HyprVim also binds `leader + SHIFT + SLASH` to toggle WhichKey when the feature is enabled.

Only bindings with a description appear in the HUD. For your own binds in `keymaps`, set a `desc` in the bind options:

```lua
require("lua/plugins/hyprvim").setup({
  keymaps = {
    NORMAL = {
      { "H", function() my_left() end, { desc = "Move left" } },
      { "J", function() my_down() end, { desc = "Move down" } },
      { "SUPER + X", function() my_extra() end, { desc = "Extra action" } },
    },
  },
})
```

Descriptions that start with `+` render in a distinct accent color. HyprVim uses this for submap transition rows.

### Overflow Handling

If the HUD would exceed the available screen height, it automatically switches to a multi-column centered layout.

That layout still has a vertical limit, so keep custom descriptions concise when possible.

## 🎨 Styling

WhichKey styling still uses its own theme files. HyprVim reads them from `~/.config/hyprvim/`.

On first run, HyprVim creates:

- `~/.config/hyprvim/theme.conf`
- `~/.config/hyprvim/whichkey.scss`

Edit `theme.conf` for colors and base sizing:

```conf
# ~/.config/hyprvim/theme.conf

$bg_core: #070C13;
$bg_border: #5D8BBB;
$fg: #F7EDE1;
$primary: #7FA3C9;
$secondary: #D6CE7C;
$accent: #FFA0A0;
$info: #B0C8DE;

$base_font_size = 12px
```

Edit `whichkey.scss` for layout and spacing overrides:

```scss
// ~/.config/hyprvim/whichkey.scss

.wk {
  border-radius: 16px;
}

.wk {
  padding: 6px 10px;
}

.wk-key {
  color: $accent;
}
```

Changes are picked up on the next `hyprctl reload`.

## ☎️ Calling It Yourself

You can also trigger the HUD from your own Hyprland binds if you need custom integration. The internal entrypoints live under `scripts/` and `whichkey/render.lua`.

For normal use, the built-in `SPACE` toggle and automatic submap display are enough.

Otherwise you may call it manually like so:

```lua
hl.bind("SHIFT + SLASH", function() require("lua.plugins.hyprvim").whichkey.toggle() end, { desc = "Open WhichKey" } )
```

<!-- Page Nav -->
<div align=right><a href="06_Tips-and-Tricks.md"><i><b>>> Next: Go to Tips and Tricks</b></i></a></div>
<!-- Page Nav -->
