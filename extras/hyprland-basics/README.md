# Hyprland Basics

Standalone Lua keybind files for vim-style Hyprland control.

For a more complete setup, see [uhs-robert/dotfiles](https://github.com/uhs-robert/dotfiles) under `home/hypr/.config/hypr/`.

## Installation

Copy the files you want into your Hyprland config directory and require them from `hyprland.lua`:

```lua
-- Global keybinds
require("keymaps.general")
require("keymaps.workspace")
require("keymaps.media")     -- requires wpctl, playerctl, brightnessctl

-- Submaps
require("keymaps.submaps.resize")
require("keymaps.submaps.move")
require("keymaps.submaps.windows")
require("keymaps.submaps.cursor")  -- requires wlrctl and optionally wl-kbptr
```

Open each file and set `LEADER` to your modifier key (default: `"SUPER"`).

> [!TIP]
> For total control, just copy the patterns you like and use as you wish.

## Global keybinds

### `general.lua`: window focus, move, close, fullscreen, scratchpad, monitors

All binds use `LEADER` as the modifier. Set `MONITOR_COUNT` to match your setup.

| Keys                         | Action                    |
| ---------------------------- | ------------------------- |
| `LEADER+h`/`j`/`k`/`l`       | Focus window              |
| `LEADER+SHIFT+h`/`j`/`k`/`l` | Move window               |
| `LEADER+C`                   | Close window              |
| `LEADER+F`                   | Toggle fullscreen         |
| `LEADER+TAB`                 | Last workspace            |
| `LEADER+S`                   | Toggle scratchpad         |
| `LEADER+SHIFT+S`             | Move window to scratchpad |
| `LEADER+CTRL+1`–`9`          | Focus monitor             |
| `LEADER+CTRL+SHIFT+1`–`9`    | Move window to monitor    |

### `workspace.lua`: workspace navigation

| Keys                 | Action                             |
| -------------------- | ---------------------------------- |
| `LEADER+1`–`0`       | Go to workspace 1–10               |
| `LEADER+SHIFT+1`–`0` | Move window to workspace 1–10      |
| `LEADER+CTRL+h`/`l`  | Cycle prev/next workspace          |
| `LEADER+CTRL+j`/`k`  | Move window to prev/next workspace |

### `media.lua`: volume, brightness, playback

Requires `wpctl` (pipewire), `playerctl`, and `brightnessctl`.

| Keys                             | Action                |
| -------------------------------- | --------------------- |
| `LEADER+ALT+h`/`l`               | Previous / next track |
| `LEADER+ALT+j`/`k`               | Volume down / up      |
| `LEADER+ALT+SPACE`               | Play/pause            |
| `XF86Audio*` / `XF86Brightness*` | Hardware media keys   |

## Submaps

### `submaps/resize.lua`: resize windows with vim motions

Enter with `LEADER + R`. `h`/`j`/`k`/`l` (or arrows) to resize the active window.

| Modifier     | Step  |               |
| ------------ | ----- | ------------- |
| _(none)_     | 10px  | Normal        |
| `SHIFT`      | 100px | Fast          |
| `CTRL`       | 1px   | Pixel-precise |
| `CTRL+SHIFT` | 300px | Ultra fast    |

`=` resets size by toggling float twice. `ESC` exits.

### `move.lua`: move floating windows with vim motions

Enter with `LEADER + M`. Same vim-key + four-tier speed pattern as resize, but moves the floating window position. `F` toggles floating mode.

### `windows.lua`: focus, workspaces, window actions

Enter with `LEADER + W`.

| Keys                  | Action                                          |
| --------------------- | ----------------------------------------------- |
| `h`/`j`/`k`/`l`       | Focus movement                                  |
| `SHIFT+h`/`j`/`k`/`l` | Move window                                     |
| `CTRL+h`/`l`          | Cycle workspaces                                |
| `CTRL+j`/`k`          | Move window to prev/next workspace              |
| `TAB`                 | Last workspace                                  |
| `SHIFT+1`–`0`         | Move window to workspace 1–10                   |
| `1`–`9`               | Focus monitor (set `MONITOR_COUNT` in the file) |
| `F`                   | Toggle floating                                 |
| `P`                   | Toggle pseudo                                   |
| `S` / `-`             | Toggle split layout                             |
| `C`                   | Close window                                    |
| `RETURN`              | Confirm/pass to active window                   |

### `cursor.lua`: keyboard-driven mouse control

Enter with `LEADER + X`.

> [!IMPORTANT]
> Requires [`wlrctl`](https://github.com/atx/wlrctl) for mouse cursor emulation (movement/clicks).
>
> The wl-kbptr label-jump binds (`F`, `T`) require [`wl-kbptr`](https://git.sr.ht/~brocellous/wl-kbptr): remove those binds if you don't use it.

| Keys                  | Action                            |
| --------------------- | --------------------------------- |
| `h`/`j`/`k`/`l`       | Move cursor (four speed tiers)    |
| `SPACE` / `A`         | Left click                        |
| `D`                   | Right click                       |
| `S`                   | Middle click                      |
| `CTRL+A` / `CTRL+S`   | Click then exit submap            |
| `E` / `Y`             | Scroll up / down                  |
| `,` / `.`             | Scroll left / right               |
| `SHIFT` variants      | Fast scroll (100px)               |
| `CTRL` variants       | Pixel scroll (1px)                |
| `CTRL+U` / `CTRL+D`   | Page up / down                    |
| `ALT+h`/`j`/`k`/`l`   | Send arrow keys to focused window |
| `F` / `T`             | wl-kbptr floating / tile click    |
| `SHIFT+F` / `SHIFT+T` | wl-kbptr floating / tile move     |
| `CTRL+F` / `CTRL+T`   | Click then exit submap            |
