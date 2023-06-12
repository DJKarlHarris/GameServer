local cjson = require "cjson"
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
end

test1()