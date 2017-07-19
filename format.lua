local irc = {
  bold = "\2",
  color = "\3",
  underline = "\x1F",
  italic = "\x1D",
  clear = "\x0F",
}

local minecraft = {
  formatChar = "\xC2\xA7",
  bold = "l",
  strikethrough = "m",
  underline = "n",
  italic = "o",
  clear = "r",
}

-- Mapping of IRC color codes to Minecraft color codes
local colors = {
  [0] = "f", -- Black [IRC: 0 Minecraft: f]
  [1] = "0", -- White [IRC: 1 Minecraft: 0]
  [2] = "1", -- Dark Blue [IRC: 2 Minecraft: 1]
  [3] = "2", -- Dark Green [IRC: 3 Minecraft: 2]
  [5] = "4", -- Dark Red
  [6] = "5", -- Dark Purple
  [7] = "6", -- Gold
  [8] = "e", -- Yellow
  [9] = "a", -- Green
  [10] = "3", -- Dark Aqua [IRC: 10 Minecraft: 3]
  [11] = "b", -- Aqua
  [12] = "9", -- Blue
  [13] = "d", -- Light Purple
  [14] = "8", -- Dark Gray
  [15] = "7", -- Gray
}

local function ircToMinecraft(text)
  local out = ""
  for i=1,#text do
    local char = text:sub(i, i)
    if char == irc.color then
      char = minecraft.formatChar
      local color = tonumber(text:sub(i+1, i+2))
      if colors[color] then
        char = char .. colors[color]
      end
    elseif char == irc.bold then
      char = minecraft.formatChar .. minecraft.bold
    elseif char == irc.underline then
      char = minecraft.formatChar .. minecraft.underline
    elseif char == irc.italic then
      char = minecraft.formatChar .. minecraft.italic
    elseif char == irc.clear then
      char = minecraft.formatChar .. minecraft.clear
    end
    out = out .. char
  end
  return out
end

local function minecraftToIRC(text)
  local out = ""
  for i=1,#text do
    local char = text:sub(i, i)
    -- TODO implement
  end
  return out
end

return {
  ircToMinecraft = ircToMinecraft,
}
