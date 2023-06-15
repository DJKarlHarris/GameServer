local skynet = require "skynet"
local mysql = require "skynet.db.mysql"
local socket = require "skynet.socket"

local db = nil
skynet.start(function()
    local listenfd = socket.listen("0.0.0.0", 8888)
    socket.start(listenfd, connect)
    db = mysql.connect({
        host = "192.168.5.129",
        port = 3306,
        database = "game",
        user = "root",
        password = "123456",
        max_packet_size = 1024 * 1024,
        on_connect = nil
    })

end)

function connect(fd, addr) 
    socket.start(fd)    
    while(1) do
        local readdata = socket.read(fd)
        if readdata then
            if readdata == 'get\r\n' then
                local res = db:query('select * from message_board')
                for i, v in pairs(res) do
                    socket.write(fd, i .. " " .. v.id .. " " .. v.text .. "\r\n")
                end
            elseif string.match(readdata, '^set') then
                local data = string.match(readdata, 'set (.-)\r\n')
                db:query("insert into message_board (text) values (\'" .. data .. "\')")
            elseif string.match(readdata, '^delete') then
                db:query("delete from message_board")
            end
        else
            socket.close(fd) 
            return
        end
    end
end
