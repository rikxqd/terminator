local skynet = require "skynet"
local skynet_manager = require "skynet.manager"
local socket = require "socket"

local logger = require "simple-logger"
require "constants"

local function echo(id, addr)
    socket.start(id)
    while true do
        local str = socket.read(id)
        if str then
            logger("client"..id..":", str)
            socket.write(id, str)
        else
            socket.close(id)
            logger("client"..id, "["..addr.."] disconnected.")
            return
        end
    end
end

skynet.start(function()
    skynet_manager.name(".dbgconsole", skynet.newservice("debug_console", DEBUG_CONSOLE_PORT))

    local addr = skynet.getenv"echo_server"
    logger("getenv:echo_server is", addr)

    local id = assert(socket.listen(addr))

    socket.start(id, function(id, addr)
        logger("client"..id, "["..addr.."] connected.")
        skynet.fork(echo, id, addr)
    end)
end)
