# Tridactyl

[Tridactyl](https://github.com/tridactyl/tridactyl) is a browser extension that provides Vim-like keybindings for Firefox.

You can find the extension on [Firefox Add-Ons](https://addons.mozilla.org/en-US/firefox/addon/tridactyl-vim/) or use the native beta from GitHub (recommended).

> [!NOTE]
> If you want an advanced vim-like browser experience using Firefox, this is probably the best one.

## What does this config do

This folder provides one Tridactyl configuration file, like a `vimrc`, but for your browser.

- `tridactylrc`: custom key mappings aligned with HyprVim-style navigation, search engines, zoom, hints, containers, and more.

## Installation

1. Install the [Tridactyl extension](https://addons.mozilla.org/en-US/firefox/addon/tridactyl-vim/) in Firefox.
2. Copy `tridactylrc` to your Tridactyl config location:

```bash
cp extras/tridactyl/tridactylrc ~/.config/tridactyl/tridactylrc
```

1. In Firefox, open the Tridactyl command line (`:`) and source the config:

```text
:source ~/.config/tridactyl/tridactylrc
```

> [!TIP]
> You can also use `:source --url` to load from a raw URL, or place the file at `~/.tridactylrc`, Tridactyl checks both locations on startup.

## Usage

### Navigation

- `h`/`j`/`k`/`l` - scroll left/down/up/right
- `H`/`L` - back/forward in history
- `J`/`K` - next/previous tab
- `gg`/`G` - scroll to top/bottom
- `<C-u>`/`<C-d>` - scroll half page up/down
- `<C-f>`/`<C-b>` - scroll full page up/down

### Tabs & Windows

- `t` - open new tab (with URL)
- `T` - switch to existing tab
- `dd` - close current tab
- `D` - close tab and go to previous
- `u` - undo closed tab
- `<<`/`>>` - move tab left/right
- `w` - open in new window

### Hints (link following)

- `f` - hint links (current tab)
- `F` - hint links (background tab)
- `;y` - hint and yank URL
- `;i` - hint inputs/text fields
- `;m`/`;M` - reverse image search (Google Lens)

### Search

- `,<space>` (`,` then `,`) - open search
- `o` / `O` - open URL or search (current / new tab)
- Prefixed search engines: `google`, `github`, `youtube`, `reddit`, `mdn`, `npm`, `duck`, `brave`, `arch`, and many more (see `tridactylrc`)

### Bookmarks

- `a` - bookmark current URL
- `b` / `B` - open bookmarks (current / new tab)

### Yank

- `yy` - yank URL
- `yt` - yank page title
- `ym` - yank as Markdown link
- `ys` - yank shortened URL

### Zoom

- `zi`/`zo` - zoom in/out (incremental)
- `zz` - reset zoom

### Leader (`,`)

- `,r` - re-source config
- `,,` - open search
- `,<` - tabopen search
