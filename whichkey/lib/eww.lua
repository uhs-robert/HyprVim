-- whichkey/lib/eww.lua
-- Thin wrappers around the eww IPC command for the WhichKey HUD.

local dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)") or "./"
local root = dir .. "../../"
package.path = root .. "?.lua;" .. root .. "?/init.lua;" .. package.path

local Utils = require("lib.utils") ---@class HyprVimUtils
local sh_escape = Utils.sh_escape

local home = os.getenv("HOME") or ""

--- @class Eww
local Eww = {}

Eww.dir = os.getenv("EWW_DIR") or (home .. "/.config/hypr/hyprvim/eww/whichkey")

Eww.POSITIONS = { "bottom-right", "bottom-center", "top-center", "bottom-left", "top-right", "top-left", "center" }

--- Run an eww subcommand against the whichkey config dir.
--- @param args string
function Eww.run(args) os.execute("eww -c " .. sh_escape(Eww.dir) .. " " .. args .. " >/dev/null 2>&1 || true") end

--- Open a whichkey eww window, preferring a specific screen.
--- @param window string
--- @param screen string
--- @return boolean
function Eww.open_window(window, screen)
  if screen and screen ~= "" then
    -- stylua: ignore
    local ok = os.execute(
      "eww -c " .. sh_escape(Eww.dir)
        .. " open --screen " .. sh_escape(screen)
        .. " " .. sh_escape(window)
        .. " >/dev/null 2>&1"
    )
    if ok then return true end
  end
  return os.execute("eww -c " .. sh_escape(Eww.dir) .. " open " .. sh_escape(window) .. " >/dev/null 2>&1") ~= nil
end

--- Push item data into eww variables for the appropriate layout (center vs sidebar).
--- @param pos string  position key, e.g. "bottom-right" or "center"
--- @param title string
--- @param items string  JSON array
--- @param lw integer  logical monitor width in pixels
--- @param jq_items fun(expr: string): string
function Eww.update_layout(pos, title, items, lw, jq_items)
  if pos:find("center") then
    Eww.run(
      string.format(
        "update title=%s col1=%s col2=%s col3=%s col4=%s panel-width=%s",
        sh_escape(title),
        sh_escape(jq_items("[to_entries | .[] | select(.key % 4 == 0) | .value]")),
        sh_escape(jq_items("[to_entries | .[] | select(.key % 4 == 1) | .value]")),
        sh_escape(jq_items("[to_entries | .[] | select(.key % 4 == 2) | .value]")),
        sh_escape(jq_items("[to_entries | .[] | select(.key % 4 == 3) | .value]")),
        sh_escape(lw .. "px")
      )
    )
  else
    Eww.run("update title=" .. sh_escape(title) .. " items=" .. sh_escape(items))
  end
end

return Eww
