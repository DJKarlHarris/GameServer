local sharedata = require "skynet.sharedata"
local fileName = {
    "login",
    "person",
    "work",
    "scene"
}

id2msg = {}
id2cmd = {}
msg2id = {}

local function up2low(str)
    local result = string.gsub(str, "%u", function(c)
        return string.lower(c)
    end)
    return result
end

local loadPb = function()
    local pb = require "pb"
    local pbio = require "pb.io"
    for _, name in pairs(fileName) do
        local proto_name = './proto/output/' .. name .. '.pb'
        assert(pb.load(pbio.read(proto_name)))

        local msgFileds = name .. ".msgId"
        
        for f_name, f_number in pb.fields(msgFileds) do
            local cmd = up2low(f_name)
            local msg_name = name .. '.' .. cmd 
            id2msg[f_number] = msg_name
            id2cmd[f_number] = cmd
            msg2id[msg_name] = f_number
        end   
    end

    --share pb to other service
    pb.share_state()
    --for name, basename, type in pb.types() do
    --    print(name .. " " ..  basename .. " " .. type)
    --end
end

loadPb()
sharedata.new('id2msg', id2msg)
sharedata.new('id2cmd', id2cmd)
sharedata.new('msg2id', msg2id)


