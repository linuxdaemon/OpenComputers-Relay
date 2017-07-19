local class = require("class")
local internet = require("internet")
local component = require("component")

local chat_box = component.getPrimary("chat_box")

local function sanitize(msg)
  local cleanMsg = msg
  if cleanMsg:sub(1, 1) == ":" then
    cleanMsg = cleanMsg:sub(2)
  end
  return cleanMsg
end

local Connection = class()

function Connection:_init(config)
  self.nick = config.nick
  self.chan = config.channel
  self.server = config.server
  self.port = config.port
end

function Connection:onMsg(nick, chan, msg)
  chat_box.say(chan .. ": <" .. nick .. "> " .. msg)
end

function Connection:connect()
  self.sock = internet.socket(self.server, self.port)
  self.buffer = ""
  self:send("NICK " .. self.nick)
  self:send("USER " .. self.nick .. " 0 * :" .. self.nick)
  self:tryRead()
end

function Connection:send(line)
  print(">> " .. line)
  self.sock:write(line .. "\r\n")
end

function Connection:parse(line)
  local pfx,cmd = "",""
  local words,params = {},{}
  for word in line:gmatch("[^ ]+") do
    words[#words + 1] = word
  end
  if words[1]:sub(1,1) == ":" then
    pfx = table.remove(words, 1)
  end
  cmd = table.remove(words, 1)
  while #words > 0 do
    if words[1]:sub(1,1) == ":" then
      params[#params + 1] = table.concat(words, " ")
      words = {}
    else
      params[#params + 1] = table.remove(words, 1)
    end
  end
  return {prefix=pfx, command=cmd, params=params}
end

function Connection:handleData(data)
  self.buffer = self.buffer .. data
  while true do
    local _, _, line, new_buffer = self.buffer:find("([^\r\n]+)[\r\n]*(.*)")
    if line == nil then break end
    self.buffer = new_buffer
    print(line)
    line = self:parse(line)
    if line.command == "PING" then
      self:send("PONG " .. line.params[#line.params])
    elseif line.command == "004" then
      self:send("JOIN " .. self.chan)
    elseif line.command == "PRIVMSG" then
      local nick = line.prefix:match("[^!]+"):sub(2)
      local chan = line.params[1]
      local msg = line.params[2]
      local cleanMsg = format.ircToMinecraft(sanitize(msg))
      self:onMsg(nick, chan, cleanMsg)
    end
  end
end

function Connection:msg(target, msg)
  self:send("PRIVMSG " .. target .. " :" .. msg)
end

function Connection:relayMsg(nick, msg)
  -- Add a zero-width space to avoid pinging users when they talk
  local nick = nick:sub(1, 1) .. "\xE2\x80\x8B" .. nick:sub(2)
  self:msg(self.chan, "<" .. nick .. "> " .. msg)
end

function Connection:tryRead()
  local data = self.sock:read()
  if data == nil then
    print("EOF")
    self.sock = nil
    return false
  end
  self:handleData(data)
  return true
end

return {Connection = Connection}
