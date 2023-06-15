local skynet = require "skynet"
local mysql = require "skynet.db.mysql"

skynet.start(function()
    local db = mysql.connect({
        host = "192.168.5.129",
        port = 3306,
        database = "game",
        user = "root",
        password = "123456",
        max_packet_size = 1024 * 1024,
        on_connect = nil
    })

    local res = db:query("insert into message_board (text) values (\'nihao\')")
    res = db:query("select * from message_board")

    for i, v in pairs(res) do
        print(i .. " " .. v.id .. " " .. v.text)
    end
end)
