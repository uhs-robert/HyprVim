# HyprVim Command Reference (`:`)

## File / Window

| Command        | Description                           |
| -------------- | ------------------------------------- |
| `:w`           | Save (Ctrl+S)                         |
| `:wq`          | Save and close                        |
| `:q`           | Close window                          |
| `:q!`          | Kill window (force)                   |
| `:qa` / `:qa!` | Close / kill all windows in workspace |
| `:only`        | Close all other windows in workspace  |

## Layout

| Command       | Description                                  |
| ------------- | -------------------------------------------- |
| `:split`      | Preselect split down _(alias: `sp`)_         |
| `:vsplit`     | Preselect split right _(alias: `vsp`, `vs`)_ |
| `:float`      | Toggle floating _(alias: `f`)_               |
| `:fullscreen` | Toggle fullscreen _(alias: `fs`)_            |
| `:pin`        | Toggle pin (sticky)                          |
| `:center`     | Center window _(alias: `c`)_                 |
| `:pseudo`     | Toggle pseudo tiling                         |

## Navigation

| Command   | Description                        |
| --------- | ---------------------------------- |
| `:tabn`   | Next workspace _(alias: `tn`)_     |
| `:tabp`   | Previous workspace _(alias: `tp`)_ |
| `:ws N`   | Focus workspace N                  |
| `:move N` | Move window to workspace N         |

## Window Properties

| Command      | Description           |
| ------------ | --------------------- |
| `:opacity V` | Set opacity (0.0–1.0) |

## System

| Command   | Description                           |
| --------- | ------------------------------------- |
| `:reload` | Reload Hyprland config _(alias: `r`)_ |
| `:lock`   | Lock screen                           |
| `:update` | Update HyprVim                        |
| `:exit`   | Dismiss command palette               |
| `:logout` | Exit session                          |

## Apps

| Command        | Description                  |
| -------------- | ---------------------------- |
| `:e` / `:edit` | Open editor                  |
| `:term`        | Open terminal _(alias: `t`)_ |

## Shell

| Command | Description                                |
| ------- | ------------------------------------------ |
| `:!cmd` | Run shell command with output (e.g. `!ls`) |
