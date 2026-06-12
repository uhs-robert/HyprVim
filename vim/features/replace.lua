-- vim/features/replace.lua
-- r (replace count chars, via R-CHAR submap) and R (replace with string) commands.

local VimCount = require("vim.lib.count") ---@class VimCount
local Hypr = require("hypr") ---@class HyprVimHyprland
local Config = require("config") ---@class HyprVimConfigModule
local Prompt = require("lib.prompt") ---@class Prompt
local exit_vim = require("vim.exit")

--- @class ReplaceModule
local Replace = {}

local sq = require("lib.utils").sh_escape

---Shell snippet that selects `n` characters to the right via wtype.
---@param n integer
---@return string
local function select_n(n)
  if n < 1 then return "" end
  return "wtype -M shift " .. string.rep("-P right -p right ", n) .. "-m shift; "
end

---Build the shell script that selects `n` chars then inserts `text`.
---Uses wtype by default; falls back to clipboard paste only when input_method="paste" and n>1.
---@param text string  replacement text
---@param n    integer number of chars to select
---@return string
local function replace_script(text, n)
  local select = select_n(n)
  if (Config.applications or {}).input_method == "paste" and n > 1 then
    local tmp = os.tmpname()
    local f = io.open(tmp, "w")
    if not f then
      Hypr.notify("replace: failed to open tmp file " .. tmp, "error", 3000)
      return ""
    end
    f:write(text)
    f:close()
    return string.format(
      "sleep 0.1; %swl-copy -n < %s; sleep 0.2; wtype -M ctrl -k v -m ctrl; sleep 0.3; rm %s",
      select,
      tmp,
      tmp
    )
  end
  return "sleep 0.1; " .. select .. "wtype -- " .. sq(text)
end

---`r` (called from the R-CHAR submap): overwrite the next [count] characters with `char`.
---Suspends vim binds so the injected keys are not intercepted, then returns to NORMAL.
---@param char string  literal replacement character
function Replace.character(char)
  local n = VimCount.get()
  Hypr.suspend_vim()
  Hypr.cmd_then_dispatch(replace_script(string.rep(char, n), n), 'hl.dsp.submap("NORMAL")')()
end

---`R`: prompt for a replacement string and overwrite the next `#string` characters with it.
function Replace.string()
  VimCount.get() -- clear
  exit_vim()
  hl.timer(function()
    Prompt.async("Replace with: ", { wm_class = "hyprvim-replace" }, function(str)
      if not str then
        Hypr.normal()
        return
      end
      Hypr.cmd_then_dispatch(replace_script(str, #str), 'hl.dsp.submap("NORMAL")')()
    end)
  end, { timeout = 100, type = "oneshot" })
end

return Replace
