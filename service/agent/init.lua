local skynet = require "skynet"
local s = require "service"
local utils = require "utils"
local runconfig = require "runconfig"

s.client = {}
s.scene_node = nil

require "scene"
require "work"

--------------------service cmd ----------------------------
s.resp.kick = function(source)
    --exit battle scene
    s.leave_scene()

    --todo
    --save data

    skynet.sleep(200)
end

s.resp.exit = function(source)
    skynet.exit()
end

s.resp.send = function(source, msg)
    skynet.send(s.gate, "lua", "send", s.id, msg)  
end

--客户消息分发
s.resp.client = function(source, cmd, msg)
    s.gate = source
    if s.client[cmd] then
        local ret_msg = s.client[cmd](source, msg)
        if ret_msg then
            skynet.send(source, 'lua', 'send', s.id, ret_msg)
        end
    else
        utils.debug("s.resp.client fail [", cmd, "]")
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
