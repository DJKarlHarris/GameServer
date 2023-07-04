local s = require "service"
local skynet = require "skynet"
local utils = require "utils"

local balls = {} -- [pid] = ball
local foods = {} -- [foodid] = food
local food_maxId = 0
local food_count = 0

local broadcast = function(msg)
    for k, v in pairs(balls) do
        s.send(v.node, v.agent, "send", msg)
    end
end

function ball()
    local m = {
        pid = nil,
        node = nil,
        agent = nil,
        x = math.random(0, 100),
        y = math.random(0, 100),
        size = 10,
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

s.resp.leave = function(source, pid)
    if not balls[pid] then
        return false
    end
    balls[pid] = nil
    broadcast({"leave", pid})
end

s.resp.shift = function(source, pid, speedx, speedy)
    local b = balls[pid]
    if not b then
        return false
    end
    b.speedx = speedx
    b.speedy = speedy
end

s.init = function()
    skynet.fork(function()
        local stime = skynet.now()
        local frame = 0
        -- one round per 0.2 second
        while true do
            frame = frame + 1
            local is_ok, error = pcall(update, frame)
            if not is_ok then
                utils.debug(error)
            end
            local etime = skynet.now()
            local waittime = frame * 20 - (etime - stime)
            if waittime < 0 then
                waittime = 2
            end
            skynet.sleep(waittime)
        end 
    end)
end

function update() 
    move_update()
    food_update()
    eat_update()
end

function move_update()
    for k, v in pairs(balls) do
        v.x = v.x + v.speedx * 0.2
        v.y = v.y + v.speedy * 0.2
        if v.speedx ~= 0 and v.speedy ~= 0 then
            broadcast({"move", v.pid, v.x, v.y})
        end
    end    
end

function food_update()
    if food_count > 50 then
        return 
    end     
    -- generate food'chance is 1% per second
    if math.random(1, 100) < 98 then
        return 
    end
    food_maxId = food_maxId + 1
    food_count = food_count + 1

    --food's position duplicate probably
    local f = food()
    f.id = food_maxId
    foods[f.id] = f

    broadcast({"addfood", f.id, f.x, f.y})
end

function eat_update()
    for pid, ball in pairs(balls) do
        for fid, food in pairs(foods)do
            if (ball.x - food.x)^2 + (ball.y - food.y)^2 < ball.size^2 then
                ball.size = ball.size + 1
                food_count = food_count - 1
                broadcast({"eat", ball.pid, fid, ball.size})
                foods[fid] = nil
            end 
        end
    end 
end

s.start(...)