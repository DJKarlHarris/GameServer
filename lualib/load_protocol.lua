local pb = require "pb"
local pbio = require "pb.io"

local fileName = {
    "login",
    "person"
}

local loadPb = function()
    for _, name in pairs(fileName) do
        name = './proto/output/' .. name .. '.pb'
        pb.load(pbio.read(name))
    end
end

loadPb()

return pb

