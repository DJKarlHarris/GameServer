local skynet = require "skynet"
local socket = require "skynet.socket"


local clients = {} 

--接受客户连接
function connect(fd, addr)
    skynet.error(fd .." connect addr:" .. addr)
    socket.start(fd)
    clients[fd] = {} 
    while(1) do
        local readdata = socket.read(fd)
        if readdata then
            broadcast(fd, 'user' .. fd .. ' say: ' .. readdata)
        else
            --connect is close
            broadcast(fd, fd .. " is exit chatroom")
            print(fd .. " is close")
            client[fd] = nil
            socket.close(fd)
            return
        end
    end
end

function broadcast(fd, data)
    for k, _ in pairs(clients) do
        if k ~= fd then
            socket.write(k, data)
        end
    end
end

skynet.start(function()
    print('[echo] is start')
    local listenfd = socket.listen("0.0.0.0", 9000)
    --socket 服务不属于任何服务，但是会将收到的数据转发给回调函数的那个服务
    socket.start(listenfd, connect) 
end)