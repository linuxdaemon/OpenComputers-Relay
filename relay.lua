local event = require("event")
local connection = require("connection")

local function run()
  local config = dofile("config.lua")
  local conn = connection.Connection(config)
  conn:connect()
  while true do
    local data = {event.pullMultiple("interrupted", "chat_message", "internet_ready")}
    local name = data[1]
    if name == "chat_message" then
      local nick = data[3]
      local msg = data[4]
      conn:relayMsg(nick, msg)
    elseif name == "interrupted" then
      conn:send("QUIT")
    elseif name == "internet_ready" then
      if not conn:tryRead() then break end
    end
  end
end

run()
