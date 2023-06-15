local skynet = require "skynet"
local cluster = require "skynet.cluster"

local CMD = {}
local my_node = skynet.getenv("node")

function CMD.start(source, target_node, target) 
    cluster.send(target_node, target, 'ping', my_node, skynet.self(), 1)
end

function CMD.ping(source, source_node, source_srv, count)
    skynet.error("[ node: " .. my_node .. " service: ".. skynet.self() .. "]" .. 'recv ping count = ' .. count)
    skynet.sleep(100)
    cluster.send(source_node, source_srv, 'ping', my_node, skynet.self(), count + 1)
end

skynet.start(function()
    skynet.error('[ping ' .. skynet.self() ..  ' start]')
    skynet.dispatch('lua', function(session, source, cmd, ...)
        local f = assert(CMD[cmd])
        f(source, ...)
    end)
end)