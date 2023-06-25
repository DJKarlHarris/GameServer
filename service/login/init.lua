local skynet = require "skynet"
local s = require "service"
local utils = require "utils"

s.client = {}

s.client.login = function(source, fd, msg)
    --utils.debug('recv ' , fd , " [" , msg[1] , "] " , "{"  , table.concat(msg, ',') , "}")
    local pid = tonumber(msg[2])
    local pwd = tonumber(msg[3])
    local gate = source
    local my_node = skynet.getenv('node')

    if pwd ~= 123 then
        return {'login', -1, 'fail'}
    end

    local is_ok, agent = skynet.call('agentmgr', 'lua', 'req_login', pid, my_node, gate)
    if not is_ok then
        return {'login', -1, 'fail to req agentmgr'}
    end

    local is_ok = skynet.call(source, 'lua', 'sure_agent', fd, pid, agent)
    if not is_ok then
        return {'login', -1, 'register gate fail'}
    end

    utils.debug('succ login ', pid)
    return {'login', -1, 'succ login '}
end



--gate ----> login 额外一层转发
s.resp.client = function(source, fd, cmd, msg) 
    if s.client[cmd] then
        local ret_msg = s.client[cmd](source, fd, msg)
        skynet.send(source, 'lua', 'send_by_fd', fd, ret_msg)
    else
        utils.debug("s.resp.client fail cmd", cmd)
    end
end

s.start(...)