local  skynet = require "skynet"
local cjson = require "cjson"
local utils = require "utils"

--test json
function test1()
    local msg = {
        _cmd = 'balllist',
        balls = {
            [1] = {id = 100, x = 10, y = 20, size = 1},
            [2] = {id = 101, x = 10, y = 30, size = 2},
        }
    }
    local buff = cjson.encode(msg)
    print(buff)

    local isok, msg = pcall(cjson.decode, buff)
    if isok then
        print(msg._cmd)
    else 
        print("error")
    end
end

--test protocol
function test2()
    local msg = {
        _cmd = "playerinfo",
        coin = 100,
        bag = {
            [1] = {1001, 1},
            [2] = {1002, 5}
        },
    }
    
    --encode
    local msg_buff = utils.json_pack('playerinfo', msg)

    --decode
    local len = string.len(msg_buff)
    local format = string.format("> i2 c%d", len - 2)
    local _, buff = string.unpack(format, msg_buff)
    
    local cmd, umsg = utils.json_unpack(buff)
    --print("cmd:" .. cmd)
    --print("coin:" .. umsg.coin)
    --print("sword:" .. umsg.bag[1][2])
end

skynet.start(function()
    test2()
end)