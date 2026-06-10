# HyprVim Command Reference (`:`)

## File / Window

| Command        | Description                                                                          |
| -------------- | ------------------------------------------------------------------------------------ |
| `:w`           | Save (Ctrl+S) _(alias: `write`, `save`)_                                             |
| `:wq`          | Save and close _(alias: `write_quit`, `save_quit`)_                                  |
| `:q`           | Close window _(alias: `quit`, `close`)_                                              |
| `:q!`          | Kill window (force) _(alias: `kill`)_                                                |
| `:qa` / `:qa!` | Close / kill all windows in workspace _(alias: `close_workspace`, `kill_workspace`)_ |
| `:only`        | Close all other windows in workspace                                                 |

## Layout

| Command                             | Description                                  |
| ----------------------------------- | -------------------------------------------- |
| `:split`                            | Preselect split down _(alias: `sp`)_         |
| `:vsplit`                           | Preselect split right _(alias: `vsp`, `vs`)_ |
| `:float`                            | Toggle floating _(alias: `f`)_               |
| `:float on\|off\|toggle`            | Set floating state explicitly                |
| `:fullscreen`                       | Toggle fullscreen _(alias: `fs`)_            |
| `:fullscreen maximized\|fullscreen` | Set fullscreen mode explicitly               |
| `:pin`                              | Toggle pin (sticky)                          |
| `:center`                           | Center window _(alias: `c`)_                 |
| `:pseudo`                           | Toggle pseudo tiling                         |
| `:zorder top\|bottom`               | Force window above / below others            |
| `:swap l\|r\|u\|d`                  | Swap window with neighbour in direction      |

## Navigation

| Command                  | Description                                                         |
| ------------------------ | ------------------------------------------------------------------- |
| `:tabn`                  | Next workspace _(alias: `tn`)_                                      |
| `:tabp`                  | Previous workspace _(alias: `tp`)_                                  |
| `:ws N`                  | Focus workspace by number or selector _(alias: `tab`, `workspace`)_ |
| `:ws name:Web`           | Focus workspace by name                                             |
| `:ws empty`              | Focus first empty workspace                                         |
| `:ws e+1`                | Focus next open workspace                                           |
| `:monitor dir\|id\|name` | Focus a monitor _(alias: `mon`)_                                    |
| `:focus class:firefox`   | Focus a window by class, title, pid, or address                     |

## Window Move

| Command                 | Description                                           |
| ----------------------- | ----------------------------------------------------- |
| `:move N`               | Move window to workspace N or selector                |
| `:move! N`              | Move without following _(alias: `move_to_workspace`)_ |
| `:move x y`             | Move window to pixel coordinate                       |
| `:send_monitor dir\|id` | Send window to a monitor                              |
| `:special name`         | Toggle special (scratchpad) workspace                 |
| `:send_special name`    | Send window to special workspace                      |

## Window Resize

| Command      | Description                                      |
| ------------ | ------------------------------------------------ |
| `:resize N`  | Resize width by N px _(alias: `resize_width`)_   |
| `:vresize N` | Resize height by N px _(alias: `resize_height`)_ |
| `:size W H`  | Resize to exact W×H _(alias: `resize_exact`)_    |

## Window Properties

| Command            | Description                                    |
| ------------------ | ---------------------------------------------- |
| `:opacity V`       | Set opacity (0.0–1.0)                          |
| `:prop name value` | Set any window property (no_anim, rounding, …) |

## Workspace

| Command        | Description              |
| -------------- | ------------------------ |
| `:rename name` | Rename current workspace |
| `:gaps N`      | Set gaps_in and gaps_out |

## System

| Command     | Description                           |
| ----------- | ------------------------------------- |
| `:reload`   | Reload Hyprland config _(alias: `r`)_ |
| `:lock`     | Lock screen                           |
| `:update`   | Update HyprVim                        |
| `:exit`     | Dismiss command palette               |
| `:logout`   | Exit session                          |
| `:shutdown` | Power off _(alias: `poweroff`)_       |
| `:picker`   | Colour picker to clipboard            |

## Apps

| Command        | Description                  |
| -------------- | ---------------------------- |
| `:e` / `:edit` | Open editor                  |
| `:term`        | Open terminal _(alias: `t`)_ |
| `:help`        | Show this reference          |

## Shell

| Command | Description                                |
| ------- | ------------------------------------------ |
| `:!cmd` | Run shell command with output (e.g. `!ls`) |

## Search / Replace

| Command | Description                            |
| ------- | -------------------------------------- |
| `:%s/`  | Trigger editor find & replace (Ctrl+H) |
