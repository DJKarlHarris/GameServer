local skynet = require "skynet"

skynet.start(function()
    --消息初始化
    skynet.error("[ping_main] start")
    local ping1 = skynet.newservice("ping")
    local ping2 = skynet.newservice("ping")
    skynet.send(ping1, "lua", "start", ping2)
    skynet.exit()
end

