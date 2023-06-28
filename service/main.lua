local skynet = require "skynet"
local cluster = require "skynet.cluster"
local runconfig = require "runconfig"

skynet.start(function()
    local my_node = skynet.getenv("node")
    skynet.error("[" .. my_node .. " main start]")
    skynet.newservice("gateway","gateway", 1)
    skynet.newservice("login", "login", 1)
    skynet.newservice("login", "login", 2)
    skynet.newservice("agentmgr", "agentmgr")
    skynet.newservice("nodemgr", "nodemgr")

    skynet.newservice("testproto", "testproto")
    --skynet.newservice("testproto2", "testproto2")

    skynet.newservice("debug_console", 8000)
    skynet.exit()
end)