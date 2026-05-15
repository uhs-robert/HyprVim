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
  local Config = require("config").setup(overrides)

  os.execute("mkdir -p " .. Config.state_dir .. "/registers")
  os.execute("mkdir -p " .. Config.state_dir .. "/marks")

  require("vim").setup(Config)

  if Config.which_key and Config.which_key.enabled then require("whichkey").start(Config) end

  require("keys")
end

return {
  setup = setup,
}
