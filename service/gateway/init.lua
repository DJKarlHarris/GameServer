local service = require "service"
local skynet = require "skynet"
local runconfig = require "runconfig"
local socket = require "skynet.socket"

local str_unpack
local str_pack
local process_msg
local process_buf

conns = {} -- fd -----> con
players = {} -- pid ---> playergate

local conn = function()
    local conn = {
        fd = nil,
        pid = nil,
    }
    return conn
end

local playergate = function()
    local playergate = {
        pid = nil,
        agent = nil,
        conn = nil,
    }
    return playergate
end

service.resp.say = function(address, word)
    skynet.error('saying ' .. word)
end

-- cmd,xxx,xxx,....xxx
str_unpack = function(msg)
    local data = {}
    while(1) do
        local token, rest = string.match(msg, '(.-),(.*)')
        if token then
            table.insert(data, token)
            msg = rest
        else 
            table.insert(data, msg)
            break
        end
    end
    return data[1], data
end

str_pack = function(cmd, msg)
    return table.concat(msg, ",") .. "\r\n" 
end

--this func process msg and dispatch it to other service
process_msg = function(fd, msg)
    print(msg)
    local cmd, msg = str_unpack(msg)
    skynet.error('recv ' .. fd .. " [" .. cmd .. "] " .. "{"  .. table.concat(msg, ',') .. "}")
    local c = conns[fd]
    local pid = c.pid    
    if not pid then
        if cmd == 'login' then
            local mynode = skynet.getenv('node')
            local nodecfg = runconfig[mynode]
            --select a login service to judge player's login
            local loginid = math.random(1, #nodecfg.login)
            local login = 'login' .. loginid
            --service.send(mynode, login, cmd, msg)
            skynet.send(login, 'lua','client', fd, cmd, msg)
        else
            skynet.error(cmd .. ' is error cmd')
            return
        end
    else 
        --other msg
        local player_g = players[pid]
        skynet.send(player_g.agent, 'lua', 'client', fd, cmd, msg)
    end
end

process_buf = function(fd, readbuf)
    while(1) do
        local msg, rest = string.match(readbuf, '(.-)\r\n(.*)')
        if msg then
            --process msg
            readbuf = rest
            process_msg(fd, msg) 
        else
            return readbuf
        end        
    end
end

local disconnect = function(fd)
    --todo
end

local recv_loop = function(fd)
    socket.start(fd)
    local readbuf = ""
    while(true) do
        local readdata = socket.read(fd)
        if readdata then
            readbuf = readbuf .. readdata
            readbuf = process_buf(fd, readbuf)
        else
            skynet.error('socket close' .. fd)
            disconnect(fd)
            socket.close(fd)
            return
        end
    end
end

local connect = function(fd, addr)
    --todo
    local c = conn()
    c.fd = fd
    conns[fd] = c 
    skynet.fork(recv_loop, fd)
end

function service.init()
    local mynode = skynet.getenv("node")
    local nodecfg = runconfig[mynode]
    local port = nodecfg.gateway[service.id].port

    local listenfd = socket.listen('0.0.0.0', port)

    skynet.error("[gate start] listen" .. " 0.0.0.0:" .. port)

    socket.start(listenfd, connect)
end

function service.exit()
    --todo
end

skynet.memlimit(1 * 1024 * 1024 * 100)
service.start(...)