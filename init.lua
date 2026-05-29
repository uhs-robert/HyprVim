-- init.lua
--
--    ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
--    ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║   ██║██║████╗ ████║
--    ███████║ ╚████╔╝ ██████╔╝██████╔╝██║   ██║██║██╔████╔██║
--    ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗╚██╗ ██╔╝██║██║╚██╔╝██║
--    ██║  ██║   ██║   ██║     ██║  ██║ ╚████╔╝ ██║██║ ╚═╝ ██║
--    ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
--

-- Set working directory and bust module cache for reload correctness
local root = debug.getinfo(1, "S").source:sub(2):match("(.*/)") or "./"
package.path = root .. "?.lua;" .. root .. "?/init.lua;" .. package.path

for k in pairs(package.loaded) do
  if
    k == "config"
    or k == "hypr"
    or k:match("^hypr%.")
    or k:match("^lib%.")
    or k:match("^whichkey")
    or k:match("^vim")
    or k:match("^keys")
  then
    package.loaded[k] = nil
  end
end

--- @param overrides HyprVimConfig?
local function setup(overrides)
  local cfg = require("config").setup(overrides)
  require("lib.updater").check_async()

  os.execute("mkdir -p " .. cfg.state_dir .. "/registers")
  os.execute("mkdir -p " .. cfg.state_dir .. "/marks")

  require("hypr.rules").setup()
  require("vim").setup(cfg)

  if cfg.which_key and cfg.which_key.enabled then require("whichkey").start(cfg) end

  require("keys")
end

return {
  setup = setup,
}
