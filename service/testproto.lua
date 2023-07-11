package.path = "./lualib/?.lua"
package.cpath = "./luaclib/?.so"
--require "load_protocol"
local pb = require "pb"

local test = function()
    
    local data = {
        name = "tom",
        sex = 1,
        number = 123
    }
    --local file = io.open('./proto/login.pb')
    --io.input(file)
    
    --pb.load(pbio.read('./proto/login.pb'))
    local bytes = assert(pb.encode("login.login_request", data))  


    local data2 = pb.decode("person.Person", bytes)
    --print(require "serpent".block(data2))
    --print(data2.name)
end

test()
