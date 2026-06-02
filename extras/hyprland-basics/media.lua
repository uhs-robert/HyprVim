-- Media keybinds: volume, brightness, playback
--
-- Dependencies:
--   wpctl        - volume control (pipewire)  https://pipewire.org
--   playerctl    - media playback control     https://github.com/altdesktop/playerctl
--   brightnessctl - brightness control        https://github.com/Hummer12007/brightnessctl
--
-- Vim-style binds use LEADER + ALT + h/j/k/l.
-- Hardware media keys are also bound where available.
--
-- CUSTOMIZE: change LEADER to your modifier key

local LEADER = "SUPER"

-- stylua: ignore start
local function exec(cmd) return function() hl.dispatch(hl.dsp.exec_cmd(cmd)) end end

local media = {
  volume_up   = exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
  volume_down = exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  mute        = exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  mute_mic    = exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  play_pause  = exec("playerctl play-pause"),
  next        = exec("playerctl next"),
  prev        = exec("playerctl previous"),
  bright_up   = exec("brightnessctl s 10%+"),
  bright_down = exec("brightnessctl s 10%-"),
}

-- Vim-style (LEADER + ALT + h/j/k/l)
hl.bind(LEADER .. " + ALT + H",     media.prev,        { desc = "Previous Track" })
hl.bind(LEADER .. " + ALT + J",     media.volume_down, { desc = "Volume Down",    repeating = true })
hl.bind(LEADER .. " + ALT + K",     media.volume_up,   { desc = "Volume Up",      repeating = true })
hl.bind(LEADER .. " + ALT + L",     media.next,        { desc = "Next Track" })
hl.bind(LEADER .. " + ALT + SPACE", media.play_pause,  { desc = "Play/Pause" })

-- Hardware media keys
hl.bind("XF86AudioRaiseVolume",  media.volume_up,   { desc = "Volume Up",        repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume",  media.volume_down, { desc = "Volume Down",      repeating = true, locked = true })
hl.bind("XF86AudioMute",         media.mute,        { desc = "Mute",             locked = true })
hl.bind("XF86AudioMicMute",      media.mute_mic,    { desc = "Mute Mic",         locked = true })
hl.bind("XF86AudioNext",         media.next,        { desc = "Next Track",       locked = true })
hl.bind("XF86AudioPause",        media.play_pause,  { desc = "Pause",            locked = true })
hl.bind("XF86AudioPlay",         media.play_pause,  { desc = "Play",             locked = true })
hl.bind("XF86AudioPrev",         media.prev,        { desc = "Previous Track",   locked = true })
hl.bind("XF86MonBrightnessUp",   media.bright_up,   { desc = "Brightness Up",    locked = true })
hl.bind("XF86MonBrightnessDown", media.bright_down, { desc = "Brightness Down",  locked = true })

-- stylua: ignore end
