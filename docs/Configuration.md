## Configuration

HyprVim can be customized via `~/.config/hypr/hyprvim/settings.conf`:

```bash
## Leader key (default: SUPER)
$HYPRVIM_LEADER = SUPER
$HYPRVIM_ACTIVATE = ESCAPE

## Prompt tool (auto-detects if empty)
$HYPRVIM_PROMPT = wofi  # or rofi, tofi, fuzzel, dmenu

## Editor for :e command
$HYPRVIM_EDITOR = nvim  # or vim

## Lock command
$HYPRVIM_LOCK = hyprlock  # or swaylock, gtklock

## Terminal
$HYPRVIM_TERMINAL = kitty --class floating-help -e

## Mark notifications (1 = enabled)
$HYPRVIM_MARK_NOTIFY = 1

## Debug mode (1 = enabled)
$HYPRVIM_DEBUG =
```

> [!TIP]
> Copy the [./settings.conf.example](https://github.com/uhs-robert/hyprvim/blob/legacy-conf/settings.conf.example) and rename it to `settings.conf` to get started quickly. All configuration operations are explained in that file.

## Advanced

### WhichKey

HyprVim does not enable WhichKey by default. You will need to enable it: [WhichKey Wiki](WhichKey.md)

### Mode Indicator

HyprVim does not ship a mode indicator. You may use the one provided by Waybar: [Waybar Hyprsubmap Indicator](https://github.com/uhs-robert/hyprvim/tree/legacy-conf/extras/waybar)

### Extras

HyprVim offers additional configurations and optional enhancements for a global Vim experience in the extras.

Some of the **must have** optionals include:

- [More Hyprland Submaps](https://github.com/uhs-robert/hyprvim/tree/legacy-conf/extras/hyprland-basics)
- [Keyboard-driven Mouse Control](https://github.com/uhs-robert/hyprvim/tree/legacy-conf/extras/wl-kbptr)
- [Web Browser Vim Navigation](https://github.com/uhs-robert/hyprvim/tree/legacy-conf/extras/vimium)

If those catch your interest, be sure to check out [all the extras](https://github.com/uhs-robert/hyprvim/tree/legacy-conf/extras) as well.

<div align=right><a href="Basics.md"><i>>> Next: Go to Basics</i></a></div>

