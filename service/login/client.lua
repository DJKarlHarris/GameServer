package.cpath = "/usr/local/lib/lua/5.1/socket/?.so"
local socket = require "core"

local addr = "127.0.0.1"
local port = 8001

local fd = socket.connect(addr, port)

fd:send("login,1,123\r\n")

local recvdata = fd:receive(1024)

print(recvdata)


--for k, v in pairs(res) do
--    print(v)
--end