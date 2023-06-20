local skynet = require "skynet"
local cluster = require "skynet.cluster"
local runconfig = require "runconfig"

skynet.start(function()
    local my_node = skynet.getenv("node")
    skynet.error("[" .. my_node .. " main start]")
    skynet.newservice("gateway","gateway", 1)
    skynet.newservice("login", "login", 1)
    skynet.newservice("login", "login", 2)
    skynet.exit()
end)