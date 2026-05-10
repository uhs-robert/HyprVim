## 🛟 WhichKey

The which-key HUD displays available keybindings for the current submap, including their descriptions.

<https://github.com/user-attachments/assets/7fdb5c63-48a5-4f8f-9280-0da408503d6e>

<p align=center><i>It works for HyprVim submaps and yours too.</i></p>

## ⚙️ Configuration

### Requirements

| Tool                                  | Description                                                       |
| ------------------------------------- | ----------------------------------------------------------------- |
| [eww](https://github.com/elkowar/eww) | Widget system used to render the which-key HUD overlay            |
| `socat`                               | Connects to Hyprland's socket2 to listen for submap change events |

### Setup

Enable and configure it in `settings.conf`:

```bash
$HYPRVIM_WHICH_KEY_ENABLED  = 1             # enable the HUD (disable by leaving blank)
$HYPRVIM_WHICH_KEY_POSITION = bottom-right  # bottom-right | bottom-center | top-center | bottom-left | top-right | top-left | center
```

The HUD auto-shows when entering any transient submap and can be toggled manually with `SPACE` from any mode. To control which submaps auto-show:

```bash
$HYPRVIM_WHICHKEY_AUTO_SHOW_DENY  = NORMAL,VISUAL,V-LINE  # never auto-show for these
$HYPRVIM_WHICHKEY_AUTO_SHOW_ALLOW =                       # force auto-show even for sticky submaps
```

> [!TIP]
> If you don't want whichkey to autoshow for some of your submaps, add them to the DENY list in your settings.

## ⚡️ Usage

The HUD auto-shows when you enter a submap, then hides when you leave. Press `SPACE` from any mode to toggle it manually at any time.

**Only bindings with a description appear.** For a bind to appear in WhichKey, you need to use `bindd` to add a description:

```bash
# bind   = MOD, key, dispatcher, params               ← hidden from which-key
# bindd  = MOD, key, description, dispatcher, params  ← visible in which-key

bindd = , H, Move left, exec, $HYPRVIM_MOTION "shift, Left"
bindd = , J, Move down, exec, $HYPRVIM_MOTION "shift, Down"
```

> [!TIP]
> Use `bindd` to binds for them to appear in WhichKey. Don't to exclude them.

Descriptions starting with `+` are rendered in a distinct color to indicate submap transitions:

```bash
bindd = , D, +Delete, exec, hyprctl dispatch submap D-MOTION
```

### Overflow handling

If the HUD would overflow the screen height, it automatically switches to a multi-column centered layout with items truncated.

However there is still a vertical limit to every monitor and each monitor is different.

For your own bindings, consider whether WhichKey should be shown by default.

Also consider whether every binding _needs_ a description to trim content. Sometimes less is more.

## 🎨 Customizing Theme

The HUD colors and font size are controlled by `theme.conf`. Copy the example to get started:

```bash
cp ~/.config/hypr/hyprvim/theme.conf.example ~/.config/hypr/hyprvim/theme.conf
```

Then edit the values to match your system theme:

```bash
# theme.conf
$bg_core:   #1a283f;   # Panel background
$bg_border: #3b6a87;   # Border and separator color
$fg:        #d9e6fa;   # Default text
$primary:   #58b8fd;   # Title and footer key color
$secondary: #f9a05e;   # Key label color
$accent:    #FFA0A0;   # Submap entry color (descriptions starting with +)
$info:      #94d0fe;   # Description text color

$base_font_size = 12px  # Root font size — all other sizes scale from this
```

Changes are picked up automatically on the next `hyprctl reload`. Any `$variable` you define here is automatically available in the SCSS.

### Style overrides

For deeper changes using your own custom CSS for layout, spacing, borders, fonts: copy `whichkey.scss.example` to `whichkey.scss`:

```bash
cp ~/.config/hypr/hyprvim/whichkey.scss.example ~/.config/hypr/hyprvim/whichkey.scss
```

Then add your overrides:

```scss
// whichkey.scss

// Rounder corners
.wk {
  border-radius: 16px;
}

// Tighter padding
.wk {
  padding: 6px 10px;
}

// Custom key label color
.wk-key {
  color: $accent;
}
```

All variables from `theme.conf` are available in `whichkey.scss`. The file is gitignored so your changes won't conflict with upstream updates.

## ☎️ Calling the Script Outside HyprVim

You can call `whichkey-render.sh` from your own Hyprland submaps, just do so after loading HyprVim.

It reads live bindings from `hyprctl binds`, so it works for any submap defined anywhere in your config.

```bash
# Toggle for whatever submap is currently active (what SPACE uses internally)
bind = $HYPRVIM_LEADER SHIFT, SLASH, exec, $HYPRVIM_WHICH_KEY info

# Show for a specific submap by name
bind = $HYPRVIM_LEADER SHIFT, SLASH, exec, $HYPRVIM_WHICH_KEY MySubmap

# Dismiss the HUD
bind = ESCAPE, submap, reset
bind = BackSpace, exec, $HYPRVIM_WHICH_KEY --close

# Skip auto-show for the next submap entry
bind = $HYPRVIM_LEADER, X, exec, $HYPRVIM_WHICH_KEY --skip; hyprctl dispatch submap MySubmap

# Override the show delay (ms) for the next submap entry
bind = $HYPRVIM_LEADER, X, exec, $HYPRVIM_WHICH_KEY --delay=500; hyprctl dispatch submap MySubmap
```

<!-- Page Nav -->
<div align=right><a href="Tips-and-Tricks.md"><i><b>>> Next: Go to Tips and Tricks</b></i></a></div>
<!-- Page Nav -->
