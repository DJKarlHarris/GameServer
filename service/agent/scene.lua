local skynet = require "skynet"
local runconfig = require "runconfig"
local s = require "service"
local mynode = skynet.getenv("node")

--连接的战斗场景服务器信息
s.snode = nil -- scene_node
s.sname = nil -- scene_name


local random_scene = function()
    local nodelist = {} 
    for k, v in pairs(runconfig.scene) do
        table.insert(nodelist, k)
        if runconfig.scene[mynode] then
            table.insert(nodelist, mynode)
        end
    end

    local idx = math.random(1, #nodelist)
    local snode = nodelist[idx]
    local scenelist = runconfig.scene[snode]

    idx = math.random(1, #scenelist)
    local sid = scenelist[idx]

    return snode, sid
end

s.leave_scene = function()
    if not s.sname then
        return
    end

    s.call(s.snode, s.sname, "leave", s.id)
    s.snode = nil
    s.sname = nil
end

--------------------client--------------------------------
s.client.enter = function(source, msg)
    if s.sname then
        return {"enter", 1, "已经在场景"}
    end    

    -- ramdom enter scene 
    local snode, sid = random_scene()
    local sname = 'scene' .. sid

    --agentid == s.id == pid
    local is_ok = s.call(snode, sname, "enter", s.id, mynode, skynet.self())
    if not is_ok then
        return {"enter", 1, "进入失败"}
    end

    s.snode = snode
    s.sname = sname 
    return nil 
end

s.client.leave = function(source, msg)
    s.send(s.snode, s.sname, "leave", msg[2])
end

s.client.shift = function(source, msg)
    local x = msg[2] or 0
    local y = msg[3] or 0
    s.send(s.snode, s.sname, "shift", s.id, x, y)    
end

