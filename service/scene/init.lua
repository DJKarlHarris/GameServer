local s = require "service"
local skynet = require "skynet"

local balls = {} -- [pid] = ball
local foods = {} -- [foodid] = food
local food_maxId = 0
local food_count = 0

local broadcast = function(msg)

end

function ball()
    local m = {
        pid = nil,
        node = nil,
        agent = nil,
        x = math.random(0, 100),
        y = math.random(0, 100),
        size = 2,
        speedx = 0,
        speedy = 0,
    }
    return m
end

function food()
    local m = {
        id = nil,
        x = math.random(0, 100),
        y = math.random(0, 100),
    }
    return m
end

local function balllist_msg()
    local msg = {"balllist"}
    for k, v in pairs(balls) do
        table.insert(msg, v.pid)
        table.insert(msg, v.x)
        table.insert(msg, v.y)
        table.insert(msg, v.size)
    end
    return msg
end

local function foodlist_msg()
    local msg = {"foodlist"}
    for k, v in pairs(foods) do
        table.insert(msg, v.fid)
        table.insert(msg, v.x)
        table.insert(msg, v.y)
    end
    return msg
end

s.resp.enter = function(source, pid, node, agent)
    if balls[pid] then
        local b = balls[pid]
        --s.send(b.node, b.agent, "send", {"enter", 0, "进入失败，玩家无法重复进入战斗"})
        return false
    end       

    local b = ball()
    b.pid = pid
    b.node = node
    b.agent = agent

    local entermsg = {"enter", pid, b.x, b.y, b.size}
    broadcast(entermsg)
    
    balls[pid] = b 

    -- response cmd 
    s.send(b.node, b.agent, "send", {"enter", 1, '进入战斗!'})
    -- battle info
    s.send(b.node, b.agent, "send", balllist_msg())
    s.send(b.node, b.agent, "send", foodlist_msg())
    return true
end


s.start(...)