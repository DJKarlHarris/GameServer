local skynet = require "skynet"
local s = require "service"
local pb = require "load_protocol"

s.init = function()
    
    local data = {
        name = "tom",
        age  = 18,
        contacts = {
            { name = "alice", phonenumber = 12312341234 },
            { name = "bob",   phonenumber = 45645674567 }
        }
    }
    --local file = io.open('./proto/login.pb')
    --io.input(file)
    
    --pb.load(pbio.read('./proto/login.pb'))
    local bytes = assert(pb.encode("person.Person", data))  
    local data2 = pb.decode("person.Person", bytes)

    --print(require "serpent".block(data2))
    print(data2.name)
end

s.start(...)
