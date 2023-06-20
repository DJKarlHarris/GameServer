local skynet = require "skynet"
local s = require "service"
local utils = require "utils"

s.client = {}

s.client.login = function(source, fd, msg)
    --skynet.error('recv ' .. fd .. " [" .. msg[1] .. "] " .. "{"  .. table.concat(msg, ',') .. "}")
    utils.debug('recv ' , fd , " [" , msg[1] , "] " , "{"  , table.concat(msg, ',') , "}")
    return {'login', -1, "test"}
end


s.resp.client = function(source, fd, cmd, msg) 
    if s.client[cmd] then
        local ret_msg = s.client[cmd](source, fd, msg)
        skynet.send(source, 'lua', 'send_by_fd', fd, ret_msg)
    else
        skynet.error("s.resp.client fail", cmd)
    end
end

s.start(...)