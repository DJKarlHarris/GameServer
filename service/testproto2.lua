local skynet = require "skynet"
local s = require "service"
local sharedata = require "skynet.sharedata"

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
    --pb.loadfile('./proto/login.pb')
    local pb = sharedata.qurey('protobuf')
    local bytes = assert(pb.encode("person.Person", data))  
    local data2 = pb.decode("person.Person", bytes)

    --print(require "serpent".block(data2))
    print(data2.age)
end

s.start(...)