<p align="center">
  <img
    src="./assets/logo.png"
    width="auto" height="128" alt="logo" />
</p>
<hr/>
<p align="center">
  <a href="https://github.com/uhs-robert/hyprvim/stargazers"><img src="https://img.shields.io/github/stars/uhs-robert/hyprvim?colorA=192330&colorB=khaki&style=for-the-badge&cacheSeconds=4300" alt="Stargazers"></a>
  <a href="https://github.com/uhs-robert/hyprvim/issues"><img src="https://img.shields.io/github/issues/uhs-robert/hyprvim?colorA=192330&colorB=skyblue&style=for-the-badge&cacheSeconds=4300" alt="Issues"></a>
  <a href="https://github.com/uhs-robert/hyprvim/contributors"><img src="https://img.shields.io/github/contributors/uhs-robert/hyprvim?colorA=192330&colorB=8FD1C7&style=for-the-badge&cacheSeconds=4300" alt="Contributors"></a>
  <a href="https://github.com/uhs-robert/hyprvim/network/members"><img src="https://img.shields.io/github/forks/uhs-robert/hyprvim?colorA=192330&colorB=C799FF&style=for-the-badge&cacheSeconds=4300" alt="Forks"></a>
  <a href="https://github.com/uhs-robert/hyprvim/releases"><img src="https://img.shields.io/github/v/release/uhs-robert/hyprvim?colorA=192330&colorB=6DDFA0&style=for-the-badge&cacheSeconds=4300" alt="Latest Release"></a>
</p>

## 🌅 Overview

**HyprVim** brings the power of Vim keybindings and motions to your Hyprland desktop environment.

<https://github.com/user-attachments/assets/1a9c9459-2bfa-4d1d-bf05-24d5174431a9>

<p align=center><i>Think of it as a lightweight, system-wide Vim mode for all of your applications.</i></p>

> [!WARNING]
> Requires both [14600](https://github.com/hyprwm/Hyprland/pull/14600) and [14578](https://github.com/hyprwm/Hyprland/pull/14578) to be merged.
>
> These are blocking issues to HyprVim's core functionality.

---

> [!IMPORTANT]
> With release 0.55 of Hyprland, Lua became the new standard for configuration and is now compatible with HyprVim!
>
> To use the deprecated non-lua version of HyrpVim, please pin to release [v1.2.3 of HyprVim](https://github.com/uhs-robert/hyprvim/releases/tag/v1.2.3).

## ✨ Features

> **📚 Full Reference:** For a complete, searchable reference of all features, visit the [Wiki](https://github.com/uhs-robert/hyprvim/wiki).
>
> **📰 Latest News:** For the latest release information, visit the [News](./NEWS.md).

Built on Hyprland’s native submap system, uses standard GUI application keyboard shortcut macros to emulate Vim-style navigation and text editing.

- **🚦 Vim Modes** - `NORMAL`, `INSERT`, `VISUAL`, `V-LINE`, and `COMMAND` modes
- **🧭 Navigation** - Character (`hjkl`), word (`w/b/e`), line (`0/$`), paragraph (`{}`), page (`Ctrl+d/u`), document (`gg/G`)
- **✂️ Operators** - Delete (`d`), change (`c`), yank (`y`) with motion and text object support
- **📝 Text Objects** - Inner/around word (`iw/aw`), inner/around paragraph (`ip/ap`)
- **🔢 Count Support** - Repeat any motion or operator (e.g., `5j`, `3dw`, `2yy`)
- **📌 Marks** - Save and jump to positions across workspaces/monitors (`m{mark}`, `` `{mark} ``)
- **📋 Registers** - Multi-clipboard with named (`"a-z`) and special registers (`"0`, `"_`, `"/`)
- **🔍 Find/Search** - Interactive search (`/`, `?`, `f`, `t`, `*`, `#`) with next/previous (`n/N`)
- **🔄 Replace** - Character (`r`) and string replacement (`R`)
- **🔁 Surround** - Wrap text with pairs (`gs` for word, `S` in visual) - supports `()`, `{}`, `[]`, `<div>`, or custom with spaces
- **↩️ Undo/Redo** - Standard undo/redo (`u`, `Ctrl+r`)
- **⌨️ Command Mode** - Execute commands (`:w`, `:q`, `:split`, `:float`, `:workspace`, `:reload`, etc.)
- **🗺️ Which-Key HUD** - Shows all keybinds for submaps on entry. Press `SPACE` to toggle (requires `eww`)
- **Open Vim/Nvim Anywhere** - Press `SUPER + N` to open selected text in Vim/Nvim for complex editing. Save/close to paste.

> [!WARNING]
> Just like real Vim, you also need to know how to exit HyprVim: press `SUPER + ESC` or `ALT + ESC`

<details>
<summary><h3>🍭 Extras</h3></summary>
<br>

[All extra configs](extras/) for a better global Vim experience.

To use the extras, refer to their respective documentation.

<!-- extras:start -->

| Tool            | Description                                                               | Extra                                                                |
| --------------- | ------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| Hyprland Basics | Hyprland keymap kickstart config for HyprVim (Resize, Move, Windows, etc) | [extras/hyprland-basics](extras/hyprland-basics)                     |
| Keyd            | System-wide key remaps and tap/hold layers                                | [extras/keyd](extras/keyd)                                           |
| Thunderbird     | Keybinds for Vim driven navigation                                        | [extras/thunderbird](extras/thunderbird)                             |
| Tridactyl       | Vim-style navigation for Firefox (advanced)                               | [extras/tridactyl](extras/tridactyl)                                 |
| Vimium          | Vim-style navigation for web browsers (basic)                             | [extras/vimium](extras/vimium)                                       |
| Waybar Submap   | Waybar submap visual Indicator                                            | [extras/waybar](extras/waybar)                                       |
| WhichKey        | WhichKey like display built using `eww` to see keybinds for submaps       | [wiki/whichkey](https://github.com/uhs-robert/hyprvim/wiki/WhichKey) |
| Wl-kbptr        | Keyboard-driven mouse cursor control on Wayland                           | [extras/wl-kbptr](extras/wl-kbptr)                                   |

If you'd like an extra config added, raise a feature request or put one together and send a pull request.

<!-- extras:end -->
</details>

## 📦 Installation

### Prerequisites

| Name                                           | Description                                                               |
| ---------------------------------------------- | ------------------------------------------------------------------------- |
| [Hyprland](https://github.com/hyprwm/Hyprland) | Wayland compositor                                                        |
| Bash                                           | For shell scripts                                                         |
| `wl-clipboard`                                 | Wayland clipboard utilities (`wl-copy`, `wl-paste`)                       |
| `wtype`                                        | Wayland keyboard input emulation (used by open-editor copy/paste)         |
| `jq`                                           | JSON processor for parsing hyprctl output                                 |
| A terminal emulator                            | For the `gh` help viewer                                                  |
| A prompt tool                                  | One of: `rofi`, `wofi`, `tofi`, `fuzzel`, `dmenu`, `zenity`, or `kdialog` |
| `eww` _(optional)_                             | Widget system for the which-key HUD                                       |
| `socat` _(optional)_                           | Required by the which-key daemon to listen on Hyprland's event socket     |

### Quick Install

#### 1. Install HyprVim to `~/.local/share` and create a shim in your Hyprland plugins directory

```bash
git clone https://github.com/uhs-robert/hyprvim \
  ~/.local/share/hyprland/lua/plugins/hyprvim

mkdir -p ~/.config/hypr/lua/plugins

cat > ~/.config/hypr/lua/plugins/hyprvim/init.lua <<'EOF'
-- Hyprvim bootstrap
local path = os.getenv('HOME')
  .. '/.local/share/hyprland/lua/plugins/hyprvim/init.lua'

local chunk, err = loadfile(path)

if not chunk then
  error(err)
end

return chunk()
EOF
```

#### 2. Load HyprVim in your `~/.config/hypr/hyprland.lua`

```bash
require("lua/plugins/hyprvim").setup()
```

> [!TIP]
> You may also pass a table of [configuration settings](#️-configuration) to customize your experience.

#### 3. Save and reload your Hyprland config

```bash
hyprctl reload
```

> [!TIP]
> **Verify installation**: Press `SUPER + ESC` and you should enter **NORMAL** mode. Press `gh` to view help.

## 🔄 Staying Updated

HyprVim checks for updates on every Hyprland reload and notifies you via your desktop notification daemon. Clicking the notification applies the update and reloads automatically.

You can also run `:update` at any time from NORMAL mode to apply manually.

The default channel is `"stable"` (latest GitHub release). Configure it in your `setup()` call:

```lua
updates = {
  channel = "stable",   -- latest release (default)
  -- channel = "nightly",  -- git HEAD
  -- channel = "v1.2.3",   -- pinned release tag
  -- channel = "abc1234",  -- pinned commit SHA
  -- channel = "off",      -- disable update checks
},
```

> [!NOTE]
> Update notifications require `notify-send` (libnotify) and a compatible notification daemon (dunst, mako, or swaync).
>
> Without one of those, a passive Hyprland notification is shown instead and you must use `:update` to apply.

## 🚀 Usage

> **📚 Full Reference:** For a complete usage guide, visit the [Wiki](https://github.com/uhs-robert/hyprvim/wiki).

### Quick Start

Press `SUPER + ESCAPE` (or your configured leader key + activation key) to enter **NORMAL** mode.

#### Basic Workflow

1. **Enter NORMAL mode**: `SUPER + ESC`
2. **See all keybindings**: Press `gh` to show help
3. **Navigate**: Use `hjkl`, `w`, `b`, `e` to move around
4. **Select text/items**: Press `v` for visual mode, then navigate to select
5. **Edit**: Use operators like `d`, `c`, `y` with motions or in visual mode
6. **Return to insert**: Press `i`, `a`, or other insert commands
7. **Exit Vim mode**: Press `SUPER + ESC` again

### Marks

Save and jump to window positions across workspaces and monitors using `m{mark}` to set, `` `{mark} `` to jump.

> **📖 Learn more:** [Marks wiki](https://github.com/uhs-robert/hyprvim/wiki/Advanced#-marks)

### Registers

Multi-clipboard management with named registers (`"a` - `"z`) and special registers (`""` unnamed, `"0` yank, `"_` black hole). Use `"{register}{operation}` (e.g., `"ayy` to yank to register a, `"ap` to paste from register a).

> **📖 Learn more:** [Registers wiki](https://github.com/uhs-robert/hyprvim/wiki/Advanced#-registers)

### Commands

Press `:` in **NORMAL** mode to execute Vim-style commands. Common commands: `:w` (save), `:q` (quit), `:wq` (save & quit), `:split` (split window), `:float` (toggle floating), `:ws <num>` (switch workspace), `:reload` (reload Hyprland config), `:update` (apply HyprVim update).

> **📖 Learn more:** [Command Mode wiki](https://github.com/uhs-robert/hyprvim/wiki/Modes#-command-mode)

### Access to Common Keyboard Shortcuts Too

HyprVim includes pragmatic pass-through bindings in **NORMAL** mode for better GUI interaction: `TAB`, `RETURN`, `CTRL+V/X/A/S/W/Z`.

This enables dialog navigation and clipboard operations without constantly switching to INSERT mode.

> [!WARNING]
> These may trigger unwanted actions in text editors. Use `i` to enter INSERT mode when editing text, or create override bindings by sourcing a custom config after HyprVim.

## ⚙️ Configuration

HyprVim offers _many_ different options to choose from. Have fun customizing with `setup()`!

<details>
  <summary>🍦 Default Options</summary>
  <br>
<!-- config:start -->

```lua
require("hyprvim").setup({
  keys = {
    leader = "SUPER",
    activate = "ESCAPE",
  },
  applications = {
    menu = "rofi",
    terminal = "kitty --class floating-help -e",
    lock = "hyprlock",
    vim_editor = "nvim",                          -- `vim` or `nvim`
  },
  notifications = {
    all = false,                -- Enable to bypass settings below and just enable all
    marks = true,
  },
  updates = {
    channel = "stable",         -- "stable" (latest release), "nightly" (git HEAD), "off", or a tag/commit SHA to pin
  },
  enable_debug = false,
  which_key = {
    enabled = true,             -- This requires eww
    delay_ms = 0,               -- 0 = instant, else delayed a bit (200 gives you some breathing room)
    position = "bottom-right",
    auto_show = {
      disabled = {
        "NORMAL",
        "VISUAL",
        "V-LINE",
      },
      enabled = nil, -- nil enables all except those in disabled. You could make disabled = nil and then it would work the opposite.
    },
  },
})
```

<!-- config:end -->
</details>

> **📖 Learn more:** [Configuration wiki](https://github.com/uhs-robert/hyprvim/wiki/Configuration)

## 🗑️ Uninstalling

Removing HyprVim from your system is a three step process:

```bash
rm -rf ~/.config/hypr/plugins/lua/hyprvim
rm -rf ~/.local/share/hyprland/lua/plugins/hyprvim
hyprctl reload
```

> [!NOTE]
> Any temporary files created by HyprVim for state management are automatically cleaned up on reboot.

## 🤔 Where is the Visual Mode Indicator and WhichKey?

### Mode Indicator (Waybar)

To see which Vim mode you're currently in, add the [Hyprland submap module](/extras/waybar) to your Waybar configuration.

This displays the active submap in your status bar.

### WhichKey

WhichKey requires `eww` to display. It is an optional feature that is **disabled by default**.

We **highly recommend using WhichKey** to learn the keybindings. It also displays active marks and works with your other submaps too.

You can find the demo and setup instructions [in the Wiki for WhichKey](https://github.com/uhs-robert/hyprvim/wiki/WhichKey).

### More Extras

On that note, check out [all the extras too](/extras)! This is just the tip of the iceberg, you never know what you might find.

## ⚠️ Known Limitations

- No macros
- No visual block mode (`Ctrl+v` or `Ctrl+q`)
- Limited text object support (word and paragraph only)
- Registers/marks are stored in tmpfs (not persistent across reboots)
- Find operations use interactive prompts and application find dialogs
- Effectiveness depends on application supporting standard keyboard shortcuts

> [!WARNING]
> HyprVim is designed for **GUI applications first**. Terminals behave differently.
>
> Terminals often use [a different set of keyboard shortcuts](https://gist.github.com/tuxfight3r/60051ac67c5f0445efee) so motions may not work as expected.
>
> However shells (bash, zsh, etc) usually ship a `vi mode`. Try using that instead.
>
> If you must use it in the shell, some actions _may_ work but your mileage will vary.

## 📏 Extending HyprVim

You can extend HyprVim by adding new submaps or referencing the submaps in your own keybinds after sourcing HyprVim as well as using HyprVim scripts in your own keybinds. Some examples of this are included in the [Hyprland basics](./extras/hyprland-basics).

If you make an enhancement that you think would benefit the community then please submit a pull request and I'll be happy to review it.
