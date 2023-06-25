local skynet = require "skynet"
local cluster = require "skynet.cluster"
require "skynet.manager"

local M = {
    name = "",
    id = 0,
    --callback
    exit = nil,
    init = nil,
    resp = {},
}

M.resp = {}

local traceback = function(err)
    skynet.error(tostring(err))
    skynet.traceback(debug.traceback())
end

local dispatch = function(session, address, cmd, ...)
    local func = M.resp[cmd]
    if not func then
        skynet.ret()
        return
    end
    
    local ret = table.pack(xpcall(func, traceback, address, ...))
    local is_ok = ret[1]

    if not is_ok then
        skynet.ret()
        return
    end

    skynet.retpack(table.unpack(ret, 2))
end

local init = function()
    skynet.dispatch("lua", dispatch)
    if M.init then
        M.init()
    end
end

function M.start(name, id)
    M.name = name
    M.id = tonumber(id)
    skynet.start(init) 
    if id then
        skynet.register(M.name .. M.id)
    else
        skynet.register(M.name)
    end
end

function M.send(node, srv, ...) 
    local my_node = skynet.getenv("node")
    if my_node == node then
        skynet.send(srv, 'lua', ...)
    else
        cluster.send(node, srv, ...)
    end
end

function M.call(node, srv, ...)
    local my_node = skynet.getenv("node")
    if my_node == node then
        return skynet.call(srv, 'lua', ...)
    else 
        return cluster.call(node, srv, ...)
    end
end

return M
