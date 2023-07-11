local skynet = require "skynet"
local cluster = require "skynet.cluster"
local runconfig = require "runconfig"
require "skynet.manager"

skynet.start(function()
    local my_node = skynet.getenv("node")
    local nodecfg = runconfig[my_node]
    require "load_protocol"

    skynet.newservice("nodemgr", "nodemgr", 0)

    cluster.reload(runconfig.cluster)
    cluster.open(my_node)

    for i, v in pairs(nodecfg.gateway or {}) do
        skynet.newservice("gateway","gateway", i)
    end

    for i, v in pairs(nodecfg.login or {}) do
        skynet.newservice("login", "login", i)
    end

    local agent_node = runconfig.agentmgr.node
    if agent_node == my_node then
        skynet.newservice("agentmgr", "agentmgr", 0)
    else 
        local proxy = cluster.proxy(agent_node, "agentmgr")
        skynet.name("agentmgr", proxy)
    end

    for _, sid in pairs(runconfig.scene[my_node]) do
        local srv = skynet.newservice("scene", "scene", sid)
    end

    --skynet.newservice("testproto", "testproto", 0)
    --skynet.newservice("testproto2", "testproto2")

    local debug_port = 9000 + tonumber(string.sub(my_node, -1))
    skynet.newservice("debug_console", debug_port)


end)



