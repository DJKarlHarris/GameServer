local service = require "service"
local skynet = require "skynet"

service.resp.say = function(address, word)
    skynet.error('saying ' .. word)
end

function service.init()
    skynet.error("[start] " .. service.name  .." ".. service.id)
end

function service.exit()
    --todo
end

service.start(...)