local skynet = require "skynet"
local socket = require "skynet.socket"

function connect(fd, addr)
    skynet.error(fd .." connect addr:" .. addr)
    socket.start(fd)
    while(1) do
        local readdata = socket.read(fd)
        if readdata then
            print('recv data:' .. readdata)
            socket.write(fd, readdata)
        else
            --connect is close
            print(fd .. "close")
            socket.close(fd)
            return
        end
    end
end

skynet.start(function()
    print('[echo] is start')
    local listenfd = socket.listen("0.0.0.0", 9000)
    --socket 服务不属于任何服务，但是会将收到的数据转发给回调函数的那个服务
    socket.start(listenfd, connect) 
end)