local skynet = require "skynet"
local cluster = require "skynet.cluster"

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

    skynet.ret(table.unpack(ret, 2))
end

local init = function()
    skynet.dispatch("lua", dispatch)
    if M.init() then
        M.init()
    end
end

function M.start(name, id)
    M.name = name
    M.id = tonumber(id)
   skynet.start(init) 
end

return M