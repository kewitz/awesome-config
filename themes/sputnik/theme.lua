-- Sputnik based on Anon.
local awful = require("awful")
awful.util = require("awful.util")

theme = {}

home          = os.getenv("HOME")
config        = awful.util.getdir("config")
themes        = config .. "/themes"
themename     = "/sputnik"
themedir      = themes .. themename

theme.font          = "Silkscreen 6"
theme.wallpaper     = home .. "/.wallpaper"

theme.bg_normal     = "#00000066"
theme.bg_focus      = "#00000000"
theme.bg_minimize   = "#00000000"
theme.bg_urgent     = "#aa0000"
theme.fg_normal     = "#999999"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"

theme.border_width  = 0
theme.border_normal = "#252525"
theme.border_focus  = "#252525"
theme.border_marked = "#91231c"

theme.taglist_squares       = true
theme.titlebar_close_button = true
theme.tasklist_disable_icon = true
theme.useless_gap_width     = 10

theme.taglist_squares_sel   = themedir .. "/taglist14/squaref.png"
theme.taglist_squares_unsel = themedir .. "/taglist14/square.png"

return theme
