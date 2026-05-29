-- lib/updater.lua

local dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)") or "./"
package.path = dir .. "../?.lua;" .. dir .. "../?/init.lua;" .. package.path

local Utils = require("lib.utils")
local sh = Utils.sh_escape

local root = dir .. "../"
local REPO = "uhs-robert/hyprvim"

local Updater = {}

--- Send an actionable notification. If the user clicks the action label, run `on_accept`.
--- Falls back to a passive hyprctl notify when notify-send is unavailable.
--- @param title string
--- @param body string
--- @param action_label string  label shown on the button
--- @param on_accept string     shell command to run when accepted
local function notify_action(title, body, action_label, on_accept)
  return "if command -v notify-send >/dev/null 2>&1; then"
    .. "  ACTION=$(notify-send -A 'ok="
    .. action_label
    .. "' -u normal -t 0"
    .. "    "
    .. sh(title)
    .. " "
    .. sh(body)
    .. ");"
    .. "  [ \"$ACTION\" = 'ok' ] && ("
    .. on_accept
    .. ");"
    .. "else"
    .. "  hyprctl notify 1 10000 'rgb(7FA3C9)' "
    .. sh(title .. " — " .. body)
    .. ";"
    .. "fi"
end

--- Check git HEAD against upstream branch. Notify if behind.
local function check_nightly(r)
  local pull = "git -C " .. r .. " pull && hyprctl reload"
  os.execute(
    "(git -C "
      .. r
      .. " fetch -q 2>/dev/null"
      .. " && LOCAL=$(git -C "
      .. r
      .. " rev-parse HEAD 2>/dev/null)"
      .. " && REMOTE=$(git -C "
      .. r
      .. " rev-parse '@{u}' 2>/dev/null)"
      .. ' && [ -n "$REMOTE" ] && [ "$LOCAL" != "$REMOTE" ]'
      .. " && "
      .. notify_action("HyprVim", "Nightly update available.", "Update now", pull)
      .. ") &"
  )
end

--- Check current tag against latest GitHub release. Notify if newer release exists.
local function check_stable(r)
  local api = sh("https://api.github.com/repos/" .. REPO .. "/releases/latest")
  os.execute(
    "(LATEST=$(curl -sf "
      .. api
      .. " | grep '\"tag_name\"' | cut -d'\"' -f4)"
      .. ' && [ -n "$LATEST" ]'
      .. " && ! git -C "
      .. r
      .. ' merge-base --is-ancestor "$LATEST" HEAD 2>/dev/null'
      .. " && if command -v notify-send >/dev/null 2>&1; then"
      .. "   ACTION=$(notify-send -A 'ok=Update now' -u normal -t 0 'HyprVim' \"Release $LATEST available.\");"
      .. "   [ \"$ACTION\" = 'ok' ] && git -C "
      .. r
      .. " fetch --tags -q && git -C "
      .. r
      .. ' checkout "$LATEST" && hyprctl reload;'
      .. " else"
      .. "   hyprctl notify 1 10000 'rgb(7FA3C9)' \"HyprVim: Release $LATEST available.\";"
      .. " fi) &"
  )
end

--- Verify HEAD is at the pinned ref. Notify if drifted.
local function check_pinned(r, ref)
  local restore = "git -C " .. r .. " checkout " .. sh(ref) .. " && hyprctl reload"
  os.execute(
    "(PINNED=$(git -C "
      .. r
      .. " rev-parse "
      .. sh(ref)
      .. " 2>/dev/null)"
      .. " && HEAD=$(git -C "
      .. r
      .. " rev-parse HEAD 2>/dev/null)"
      .. ' && [ -n "$PINNED" ] && [ "$HEAD" != "$PINNED" ]'
      .. " && "
      .. notify_action("HyprVim", "Not at pinned ref " .. ref .. ".", "Restore", restore)
      .. ") &"
  )
end

--- Fetch remote state and notify based on the configured update channel.
--- Runs entirely in background — does not block init.
function Updater.check_async()
  local Config = require("config")
  local channel = (Config.updates or {}).channel or "stable"
  local r = sh(root)

  if channel == "off" then return end
  if channel == "nightly" then
    check_nightly(r)
  elseif channel == "stable" then
    check_stable(r)
  else
    check_pinned(r, channel)
  end
end

--- Apply the update for the current channel. Called by :update command.
function Updater.update()
  local Config = require("config")
  local channel = (Config.updates or {}).channel or "stable"
  local r = sh(root)

  if channel == "off" then return end

  if channel == "nightly" then
    os.execute("(git -C " .. r .. " pull && hyprctl reload) &")
  elseif channel == "stable" then
    local api = "https://api.github.com/repos/" .. REPO .. "/releases/latest"
    os.execute(
      "(LATEST=$(curl -sf "
        .. sh(api)
        .. " | grep '\"tag_name\"' | cut -d'\"' -f4)"
        .. ' && [ -n "$LATEST" ]'
        .. " && git -C "
        .. r
        .. " fetch --tags -q"
        .. " && git -C "
        .. r
        .. ' checkout "$LATEST"'
        .. " && hyprctl reload) &"
    )
  else
    os.execute("(git -C " .. r .. " checkout " .. sh(channel) .. " && hyprctl reload) &")
  end
end

return Updater
