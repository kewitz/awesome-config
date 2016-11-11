-- Sputnik based on Anon.

local awful = require("awful")
awful.util = require("awful.util")

theme = {}

home          = os.getenv("HOME")
config        = awful.util.getdir("config")
shared        = "/usr/share/awesome"
if not awful.util.file_readable(shared .. "/icons/awesome16.png") then
    shared    = "/usr/share/local/awesome"
end
sharedicons   = shared .. "/icons"
sharedthemes  = shared .. "/themes"
themes        = config .. "/themes"
themename     = "/sputnik"
if not awful.util.file_readable(themes .. themename .. "/theme.lua") then
       themes = sharedthemes
end
themedir      = themes .. themename

wallpaper1    = home .. "/.wallpaper"
wallpaper2    = "/home/leo/Pictures/Wallpapers/active.jpg"
wallpaper3    = sharedthemes .. "/zenburn/zenburn-background.png"
wallpaper4    = sharedthemes .. "/default/background.png"
wpscript      = home .. "/.wallpaper"

if awful.util.file_readable(wallpaper1) then
	theme.wallpaper = wallpaper1
elseif awful.util.file_readable(wallpaper2) then
	theme.wallpaper = wallpaper2
elseif awful.util.file_readable(wpscript) then
	theme.wallpaper_cmd = { "sh " .. wpscript }
elseif awful.util.file_readable(wallpaper3) then
	theme.wallpaper = wallpaper3
else
	theme.wallpaper = wallpaper4
end

theme.font          = "Silkscreen 6"

theme.bg_normal     = "#00000088"
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

theme.taglist_squares = true
theme.titlebar_close_button = true
theme.tasklist_disable_icon = true
theme.useless_gap_width = 20

theme.taglist_squares_sel   = themedir .. "/taglist14/squaref.png"
theme.taglist_squares_unsel = themedir .. "/taglist14/square.png"

theme.widget_mem      = themes .. "/icons/dust12/ram.png"
theme.widget_swap     = themes .. "/icons/dust12/swap.png"
theme.widget_fs       = themes .. "/icons/dust12/fs_01.png"
theme.widget_fs2      = themes .. "/icons/dust12/fs_02.png"
theme.widget_up       = themes .. "/icons/dust12/up.png"
theme.widget_down     = themes .. "/icons/dust12/down.png"

theme.layout_fairh      = themedir .. "/layouts14/fairhw.png"
theme.layout_fairv      = themedir .. "/layouts14/fairvw.png"
theme.layout_floating   = themedir .. "/layouts14/floatingw.png"
theme.layout_magnifier  = themedir .. "/layouts14/magnifierw.png"
theme.layout_max        = themedir .. "/layouts14/maxw.png"
theme.layout_fullscreen = themedir .. "/layouts14/fullscreenw.png"
theme.layout_tilebottom = themedir .. "/layouts14/tilebottomw.png"
theme.layout_tileleft   = themedir .. "/layouts14/tileleftw.png"
theme.layout_tile       = themedir .. "/layouts14/tilew.png"
theme.layout_tiletop    = themedir .. "/layouts14/tiletopw.png"
theme.layout_spiral     = themedir .. "/layouts14/spiralw.png"
theme.layout_dwindle    = themedir .. "/layouts14/dwindlew.png"

return theme
