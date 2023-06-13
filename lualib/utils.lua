local skynet = require "skynet"
local cjson = require "cjson"

local utils = {}

-- lua data or other data -----> string data ------> binary data
function utils.json_pack(cmd, msg)
    -- [paketSize] [cmdSize] [cmd] [msg]
    local body = cjson.encode(msg)

    local namelen = string.len(cmd)
    local bodylen = string.len(body)
    local len = namelen + bodylen
    local format = string.format("> i2 i2 c%d c%d", namelen, bodylen)
    local buff = string.pack(format, len, namelen, cmd, body)
    return buff
end

-- binary data ------> string data------> lua data or other data
-- packet len in buff has been removed 
function utils.json_unpack(buff)
    -- i2 cx cx
    local len = string.len(buff)
    --local u_len = string.
    local namelen_format = string.format("> i2 c%d", len - 2)
    local namelen, data = string.unpack(namelen_format, buff)

    local bodylen = len - 2 - namelen 
    local format = string.format("> c%d c%d", namelen, bodylen)
    local cmd, bodyBuff = string.unpack(format, data)

    local isok, msg = pcall(cjson.decode, bodyBuff)
    if not isok or not msg or not msg._cmd or not msg._cmd == cmd then
            print("error")
            return
    end
    return cmd, msg
end

return utils