There are a lot of tips we can offer here. If you've already read everything else in the Wiki, then the next best place to go is to [check out the extras](https://github.com/uhs-robert/hyprvim/tree/legacy-conf/extras).

The extras also include Submaps for "Resize", "Move", and even [keyboard-driven mouse movement](https://github.com/uhs-robert/hyprvim/tree/legacy-conf/extras/wl-kbptr). There's a lot that can be learned from another configuration setup, even if you already have many of these things.

## Using HyprVim Keybinds Outside of Vim Modes

In [Hyprland Basics](https://github.com/uhs-robert/hyprvim/tree/legacy-conf/extras/hyprland-basics), you can learn about **how to use HyprVim keybinds outside of vim-mode**. This way, you can use the shell scripts without entering Vim-mode.

### Recommended Keybinds to Grab

- `Set Mark`
- `Jump Mark`
- `Open Vim Anywhere`
- `Open Command Mode`

## Combining Features

- **Counts + Motions:** `5j`, `3w`, `10k`
- **Counts + Operators:** `3dd` (delete 3 lines), `5yy` (yank 5 lines)
- **Operators + Motions:** `d3w` (delete 3 words), `c$` (change to end of line)
- **Operators + Text Objects:** `diw` (delete inner word), `ciw` (change inner word)
- **Registers + Operations:** `"ayy` (yank to register a), `"ap` (paste from register a)
- **Marks + Navigation:** `ma` (set mark), `` `a `` (jump to mark)

## Common Workflows

**Editing with registers:**

```
"ayy        - Yank line to register a
(move cursor)
"ap         - Paste from register a
```

**Cross-workspace navigation:**

Set your marks by window title at the beginning of the day, and jump back whenever you need to. No more "was YouTube on ws 1?" or jumping between monitors to get to a specific window. Just jump to mark `y`.

```
ma          - Mark current window/workspace as 'a'
:ws 3       - Switch to workspace 3
(do work)
`a          - Jump back to mark 'a' (jumps to window/workspace/monitor)
```

**Window management:**

Forgot the keybind for split, float, center? No problem. You can even set opacity from COMMAND mode.

```
:split      - Split window
:float      - Make it float
:center     - Center it
:opacity 0.9 - Add transparency
```

## Advanced Features

- **Marks work across workspaces and monitors** - Set a mark in one workspace, jump to it from another
- **Register 0 preserves yanks** - Yank text, delete something, paste the yank with `"0p`
- **Black hole register** - Delete without affecting clipboard using `"_d`

