local skynet = require "skynet"
local s = require "service"
local utils = require "utils"

s.client = {}
s.gate = nil

s.client.work = function(source, msg)
    s.data.coin = s.data.coin + 1 
    return {'work', s.data.coin}
end

s.resp.kick = function(source)
    --todo
    --save data
    skynet.sleep(200)
end

s.resp.exit = function(source)
    skynet.exit()
end

s.resp.client = function(source, cmd, msg)
    s.gate = source
    if s.client[cmd] then
        local ret_msg = s.client[cmd](source, msg)
        if ret_msg then
            skynet.send(source, 'lua', 'send', s.id, ret_msg)
        end
    else
        utils.debug("s.resp.client fail ", cmd)
    end
end

--load data
s.init = function()
    skynet.sleep(200)
    s.data = {
        coin = 100,
        hp = 200,
    }
end

--save data
s.exit = function()

end

s.start(...)

