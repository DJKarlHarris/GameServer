local skynet = require "skynet"

local CMD = {}

function CMD.start(source, target) 
    skynet.send(target, 'lua', 'ping', 1)
end  

function CMD.ping(source, count) 
    local id = skynet.self()
    skynet.error("[" .. id .. "]" .. 'recv count' .. count)
    skynet.sleep(100)
    skynet.send(source, 'lua', 'ping', count + 1)
end

skynet.start(function()
    --消息初始化
    local id = skynet.self()
    skynet.error("[ping" .. id .. "] start")
    --注册消息回调函数
    skynet.dispatch("lua", function(session, source, cmd, ...)
        --session 消息唯一id ,source 消息源
        local func = assert(CMD[cmd])
        func(source, ...)
    end)
end)