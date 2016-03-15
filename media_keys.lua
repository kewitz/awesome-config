-- dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous
local io = require("io")
local awful = require("awful")
local naughty = require("naughty")

local media = {}

local function getPlayers()
  local f = assert(io.popen("qdbus org.mpris.MediaPlayer2*"))
  local players = {}
  for line in f:lines() do
    players[#players + 1] = line
  end
  f:close()
  return players
end

function media.sendCmd(cmd)
  local players = getPlayers()
  if (#players == 0) then
    naughty.notify({ text = "No mpris player running." })
  else
    awful.util.spawn("qdbus " .. players[1] .. " /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player." .. cmd)
  end
end

return media
