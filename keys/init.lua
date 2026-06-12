-- keys/init.lua
-- Global activation bind and all submap definitions.
-- Called from hyprvim/init.lua after vim.setup() and whichkey.start().

local root = debug.getinfo(1, "S").source:sub(2):match("(.*/)") or "./"
package.path = root .. "?.lua;" .. root .. "?/init.lua;" .. package.path

local Config = require("config") ---@class HyprVimConfigModule
local leader = (Config.keys or {}).leader or "SUPER"
local act = (Config.keys or {}).activate or "ESCAPE"

-- Global Activation: Enters NORMAL mode.
hl.bind(leader .. " + " .. act, function()
  require("vim").count.clear()
  require("lib.submap").enter("NORMAL")
end)

-- Global WhichKey Toggles
if Config.which_key and Config.which_key.enabled then
  local wk = require("whichkey") ---@class WhichKey
  hl.bind(leader .. " + SHIFT + SLASH", function() wk.toggle() end)
  hl.bind("ESCAPE", function() wk.close() end, { non_consuming = true })
  hl.bind("BackSpace", function() wk.close() end, { non_consuming = true })
end

-- Load all submap definitions.
require("keys.submaps").setup()
