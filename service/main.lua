local skynet = require "skynet"
local cluster = require "skynet.cluster"
local runconfig = require "runconfig"

skynet.start(function()
    local my_node = skynet.getenv("node")
    skynet.error("[" .. my_node .. " main start]")
    skynet.error(runconfig.agentmgr.node)
    skynet.newservice("gateway","gateway", 1)
    skynet.exit()
end)