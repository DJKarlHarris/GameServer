local skynet = require "skynet"
local s = require"service"

--------------------client ----------------------------
s.client.work_request = function(source, msg)
    s.data.coin = s.data.coin + 1 
    return {'work', s.data.coin}
end


