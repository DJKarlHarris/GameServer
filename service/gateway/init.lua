local service = require "service"
local skynet = require "skynet"
local runconfig = require "runconfig"
local utils = require "utils"
local netpack = require "skynet.netpack"
local socketdriver = require "skynet.socketdriver"
local pb = require "load_protocol"

local str_unpack
local str_pack
local process_msg
local process_buf
local disconnect

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

--login ----> gate -------> client
service.resp.send_by_fd = function(source, fd, msg)
    if not conns[fd] then
        return
    end
    local buff = str_pack(msg[1], msg)
    --skynet.error('recv ' .. fd .. " [" .. msg[1] .. "] " .. "{"  .. table.concat(msg, ',') .. "}")
    utils.debug('send ' , fd , " [" , msg[1] , "] " , "{"  , table.concat(msg, ','), "}")
    socketdriver.send(fd, buff)
end

--agent ------>gate ------->client
service.resp.send = function(source, pid, msg)
    local player_g = players[pid] 
    if player_g == nil then
        return
    end
    local c = player_g.conn
    if not c then
        return
    end
    service.resp.send_by_fd(nil, c.fd, msg)
end

service.resp.sure_agent = function(source, fd, pid, agent)
    local conn = conns[fd]
    if not conn then
        skynet.call("agentmgr", "lua", "req_kick", pid, "未完成登录已下线")
        return false
    end

    conn.pid = pid
    
    local player_g = playergate()
    player_g.pid = pid
    player_g.agent = agent
    player_g.conn = conn 
    players[pid] = player_g

    return true
end

service.resp.kick = function(source, pid)
    local player_g = players[pid]
    if not player_g then
        return
    end

    local conn = player_g.conn
    players[pid] = nil

    if not conn then
        return
    end

    conns[conn.fd] = nil
    disconnect(conn.fd)
    socketdriver.close(conn.fd)
end

-- cmd,xxx,xxx,....xxx
--str_unpack = function(msg)
--    local data = {}
--    while(1) do
--        local token, rest = string.match(msg, '(.-),(.*)')
--        if token then
--            table.insert(data, token)
--            msg = rest
--        else 
--            table.insert(data, msg)
--            break
--        end
--    end
--    return data[1], data
--end

str_pack = function(cmd, msg)
    return table.concat(msg, ",") .. "\r\n" 
end


--this func process msg and dispatch it to other service
process_msg = function(fd, msgId, proto_data)
    --local cmd, msg = str_unpack(msg)

    --skynet.error('recv ' .. fd .. " [" .. cmd .. "] " .. "{"  .. table.concat(msg, ',') .. "}")
    --utils.debug('recv ' , fd , " [" , cmd , "] " , "{"  , table.concat(msg, ','),"}")
    local c = conns[fd]
    local pid = c.pid    
    local msg_name = id2msg[msgId]
    local cmd = id2cmd[msgId]

    local data = {}
    if proto_data then
        data = pb.decode(msg_name, proto_data)
    end

    if not pid then
        local mynode = skynet.getenv('node')
        local nodecfg = runconfig[mynode]
        --select a login service to judge player's login
        local loginid = math.random(1, #nodecfg.login)
        local login = 'login' .. loginid
        --service.send(mynode, login, cmd, msg)
        
        skynet.send(login, 'lua', 'client', fd, cmd, data)
    else 
        --other msg
        local player_g = players[pid]
        skynet.send(player_g.agent, 'lua', 'client', cmd, data)
    end
end

--process_buf = function(fd, readbuf)
--    while(1) do
--        local msg, rest = string.match(readbuf, '(.-)\r\n(.*)')
--        if msg then
--            --process msg
--            readbuf = rest
--            process_msg(fd, msg) 
--        else
--            return readbuf
--        end        
--    end
--end

--接收client数据
--local recv_loop = function(fd)
--    socket.start(fd)
--    local readbuf = ""
--    while(true) do
--        local readdata = socket.read(fd)
--        if readdata then
--            readbuf = readbuf .. readdata
--            readbuf = process_buf(fd, readbuf)
--        else
--            utils.debug('socket close' , fd)
--            disconnect(fd)
--            socket.close(fd)
--            return
--        end
--    end
--end

--local connect = function(fd, addr)
--    --todo
--    local c = conn()
--    c.fd = fd
--    conns[fd] = c 
--    skynet.fork(recv_loop, fd)
--end

--客户端断线
--请求 agentmgr 来仲裁断开 ---->resp.kick
--active disconnection  --> disconnect --> my_node:req_kick --> my_node:kick --> disconnect
--passive disconnection --> other_node:req_kick --> my_node:kick --> disconnect
disconnect = function(fd)
    local conn = conns[fd]
    if not conn then
        return
    end

    local pid = conn.pid 
    if not pid then
        return
    end
    
    skynet.send('agentmgr', 'lua', 'req_kick', pid, '断线')
end

local queue

local process_connect = function(fd, addr)
    skynet.error("new conn fd:" .. fd .. " addr:" .. addr)
    local c = conn()
    c.fd = fd
    conns[fd] = c

    socketdriver.start(fd)
end

--msg = [msgid 2B] [protodata]
local process_data = function(fd, msg ,sz) 
    local str = netpack.tostring(msg, sz)

    local len = string.len(str)
    local proto_len = len - 2
    local format = string.format("> i2 c%d", proto_len)
    
    local msgId, proto_data = string.unpack(format, str)
    if id2msg[msgId] == nil or id2cmd[msgId] == nil then
        service.resp.send_by_fd(nil, fd, {'协议号不存在'})
        return  
    end

    process_msg(fd, msgId, proto_data)  
    skynet.error("recv from fd: " .. fd .. " str: " .. str)
end

local process_more = function(fd)
    for fd, msg, sz in netpack.pop, queue do 
        skynet.fork(process_data,fd, msg, sz)
    end
end

local process_close = function(fd)
    disconnect(fd)
    skynet.error("close fd:" .. fd)
end

local process_error = function(fd, error)
    skynet.error(error)
end

local process_warning = function(fd, size)
    skynet.error("warning fd:" .. fd .. " size" .. size)
end

local socket_unpack = function(msg, sz)
    return netpack.filter(queue, msg, sz) 
end

local socket_dispatch = function(_, _, q, type, ...)
    skynet.error("socket_dispatch type:" .. (type or "nil"))
    queue = q
    if type == "open" then
        process_connect(...)
    elseif type == "data" then
        process_data(...)
    elseif type == "more" then
        process_more(...)
    elseif type == "close" then
        process_close(...)
    elseif type == "error" then
        process_error(...)
    elseif type == "warning" then
        process_warning(...) 
    end
end

function service.init()
    local mynode = skynet.getenv("node")
    local nodecfg = runconfig[mynode]
    local port = nodecfg.gateway[service.id].port

    skynet.register_protocol({
        name = "socket",
        id = skynet.PTYPE_SOCKET,
        unpack = socket_unpack,
        dispatch = socket_dispatch,
    })

    local listenfd = socketdriver.listen('0.0.0.0', port)
    skynet.error("[gate start] listen" .. " 0.0.0.0:" .. port)
    socketdriver.start(listenfd)
end

function service.exit()
    netpack.clear(queue)
    --todo
end

--skynet.memlimit(1 * 1024 * 1024 * 1000)
service.start(...)