local skynet = require "skynet"
local cluster = require "skynet.cluster"

skynet.start(function()
    local my_node = skynet.getenv("node")
    skynet.error("[ " .. my_node .. " main start]")
    skynet.exit()
end)