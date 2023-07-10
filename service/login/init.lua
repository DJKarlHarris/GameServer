local skynet = require "skynet"
local s = require "service"
local utils = require "utils"

s.client = {}

s.client.login_request = function(source, fd, msg)
    --utils.debug('recv ' , fd , " [" , msg[1] , "] " , "{"  , table.concat(msg, ',') , "}")
    local pid = tonumber(msg.id)
    local pwd = tonumber(msg.pw)
    
    utils.debug(pid, " ", pwd)
    
    local gate = source
    local my_node = skynet.getenv('node')
    
    if pid == nil then
        return {'login', -1, 'username is nil'}
    end

    -- verify password
    if pwd ~= 123 then
        return {'login', -1, 'fail'}
    end

    -- req agentmgr to create a agent
    local is_ok, agent = skynet.call('agentmgr', 'lua', 'req_login', pid, my_node, gate)
    if not is_ok then
        return {'login', -1, 'fail to req agentmgr'}
    end

    -- notify gate to save agent imformation
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