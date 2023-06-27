local skynet = require "skynet"
local s = require "service"
local utils = require "utils"

local players = {}

STATUS = {
    LOGIN = 2,
    GAME = 3,
    LOGOUT = 4,
}

function Player()
    local m ={
        pid = nil,
        node = nil,
        agent = nil,
        gate = nil,
        status = nil,
    }
    return m
end

s.resp.req_login = function(source, pid, src_node, src_gate)
    local mplayer = players[pid]

    if mplayer and mplayer.status == STATUS.LOGOUT then
        utils.debug("reqlogin fail, this player is at status LOGOUT")
        return false
    end  
    if mplayer and mplayer.status == STATUS.LOGIN then
        utils.debug("reqlogin fail, this player is at status LOGIN")
    end

    if mplayer then
        local pnode = mplayer.node 
        local pagent = mplayer.agent
        local pgate = mplayer.gate
        mplayer.status = STATUS.LOGOUT
        s.call(pnode, pagent, 'kick')
        s.send(pnode, pagent, 'exit')
        s.send(pnode, pgate, 'send', pid, {"kick", "顶替下线"})
        s.call(pnode, pgate, 'kick', pid)
    end

    local player = Player()
    player.pid = pid
    player.node = src_node
    player.gate = src_gate
    player.agent = nil
    player.status = STATUS.LOGIN
    players[pid] = player
    local agent = s.call(src_node, "nodemgr", "newservice", "agent", ".agent", pid)
    player.agent = agent
    player.status = STATUS.GAME
    return true, agent
end

s.resp.req_kick = function(source, pid)
    local player = players[pid]
    if not player then
        return false
    end

    if player.status ~= STATUS.GAME then
        return false        
    end

    local pnode = player.node
    local pagent = player.agent
    local pgate = player.gate

    player.status = STATUS.LOGOUT
    s.call(pnode, pagent, 'kick', pid)
    s.send(pnode, pagent, 'exit')
    s.call(pnode, pgate, 'kick', pid)
    players[pid] = nil

    return true
end

s.init = function()

end

s.exit = function()

end

s.start(...)