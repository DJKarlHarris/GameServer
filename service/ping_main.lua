local skynet = require "skynet"
local cluster = require "skynet.cluster"
require "skynet.manager"

skynet.start(function()
    skynet.error("[Pmain] start")
    skynet.newservice('debug_console', 8000)
    
    cluster.reload({
        node1 = "127.0.0.1:7001",
        node2 = "127.0.0.1:7002"
    }) 
    local my_node = skynet.getenv("node")

    if(my_node == "node1") then
        cluster.open("node1")
        local ping1 = skynet.newservice('ping_service')
        local ping2 = skynet.newservice('ping_service')   
        skynet.send(ping1, 'lua', 'start', 'node2', 'pong')
        skynet.send(ping2, 'lua', 'start', 'node2', 'pong')
    elseif(my_node == "node2") then
        cluster.open("node2")
        local ping3 = skynet.newservice('ping_service')
        skynet.name('pong', ping3)
    end

    skynet.exit()
end)