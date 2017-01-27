-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local lain = require("lain")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local mediaKeys = require("media_keys")

awful.rules = require("awful.rules")
require("awful.autofocus")

-- Notify config
naughty.config.defaults.icon_size = 64

-- Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
           title = "Oops, there were errors during startup!",
            text = awesome.startup_errors })
end
do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true
    naughty.notify({ preset = naughty.config.presets.critical,
             title = "Oops, an error happened!",
             text = err })
    in_error = false
  end)
end

-- Functions
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
    findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

-- Auto Start
run_once("xset s off")
run_once("killall -g syndaemon; syndaemon -d -k -t -i 1.5")
run_once("killall unagi; sleep 1; unagi &")
-- run_once("gnome-settings-daemon")
-- run_once("xinput --set-prop 13 \"Synaptics Two-Finger Scrolling\" 1 1")
-- run_once("xfce4-volumed")
-- run_once("xfce4-power-manager --restart")
-- run_once("xset s off")
-- run_once("xinput --set-prop 13 \"Synaptics Two-Finger Scrolling\" 1 1")

-- Theme
-- Themes define colours, icons, font and wallpapers.
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/noir/theme.lua")

-- Varibles
-- This is used later as the default terminal and editor to run.
terminal = "gnome-terminal --hide-menubar"
filemanager = "nautilus"
editor = "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"

-- Layouts
local layouts = {
  lain.layout.uselesstile,
  lain.layout.uselesstile.left,
  lain.layout.uselesstile.top,
  awful.layout.suit.floating
}

-- Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end

-- Tags
tags = {
  names = { "1", "2", "3", "4", "5", "6" },
}
for s = 1, screen.count() do
  tags[s] = awful.tag(tags.names, s, layouts[1])
end

-- Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
  { "manual", terminal .. " -e man awesome" },
  { "edit config", editor_cmd .. " " .. awesome.conffile },
  { "restart", awesome.restart },
  { "quit", awesome.quit }
}
mydisplaymenu = {
  { "Notebook", "xrandr --output eDP1 --auto --output HDMI1 --off" },
  { "HDMI", "xrandr --output eDP1 --off --output HDMI1 --auto" },
  { "Dual", "xrandr --output eDP1 --left-of HDMI1 --auto --output HDMI1 --primary --auto" }
}
mymainmenu = awful.menu({ items = {
  { "awesome", myawesomemenu, beautiful.awesome_icon },
  { "display", mydisplaymenu },
  { "Lock", "dm-tool lock" }
}})
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Widgets
markup    = lain.util.markup
accent   = "#ffffff"
-- Clock
clockwidget = awful.widget.textclock(markup(accent, " %a, %d %b").." %H:%M ")
-- CPU
cpuwidget = lain.widgets.cpu({
  settings = function()
    widget:set_markup(markup(accent, " CPU ") .. cpu_now.usage .. "% ")
  end
})
-- Battery
batwidget = lain.widgets.bat({
  settings = function()
    bat_perc = bat_now.perc
    time = ""
    if bat_now.status == "Discharging" then time = "(" .. bat_now.time .. ") " end
    if bat_perc == "N/A" then bat_perc = "Plug" end
    widget:set_markup(markup(accent, " Bat ") .. bat_perc .. "% ".. time)
  end
})
-- Net checker
netwidget = lain.widgets.net({
  settings = function()
    if net_now.state == "up" then net_state = "On"
    else net_state = "Off" end
    widget:set_markup(markup(accent, " Net ") .. net_state .. " ")
  end
})
-- Volume
volumewidget = lain.widgets.alsa({
  cmd = "amixer -c 1",
  settings = function()
    header = " Vol "
    vlevel  = volume_now.level or ""
    if volume_now.status == "off" then vlevel = vlevel .. "M "
    else vlevel = vlevel .. " " end
    widget:set_markup(markup(accent, header) .. vlevel)
  end
})
volumewidget.widget:buttons(awful.util.table.join(
	awful.button({ }, 1, function () awful.util.spawn("pactl set-sink-mute 1 toggle") volumewidget.update() end),
	awful.button({ }, 4, function () awful.util.spawn("pactl set-sink-volume 1 +2%") volumewidget.update() end),
	awful.button({ }, 5, function () awful.util.spawn("pactl set-sink-volume 1 -2%") volumewidget.update() end)
))

-- Separators
spr = wibox.widget.textbox("  ")


-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
  awful.button({ }, 1, awful.tag.viewonly),
  awful.button({ modkey }, 1, awful.client.movetotag),
  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, awful.client.toggletag),
  awful.button({ }, 5, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
  awful.button({ }, 4, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
  awful.button({ }, 1, function (c)
    if c == client.focus then
      c.minimized = true
    else
      -- Without this, the following
      -- :isvisible() makes no sense
      c.minimized = false
      if not c:isvisible() then awful.tag.viewonly(c:tags()[1]) end
      -- This will also un-minimize
      -- the client, if needed
      client.focus = c
      c:raise()
    end
  end),
  awful.button({ }, 3, function ()
    if instance then
      instance:hide()
      instance = nil
    else
      instance = awful.menu.clients({ theme = { width = 250 } })
    end
  end),
  awful.button({ }, 4, function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end),
  awful.button({ }, 5, function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end)
)

-- Make Toolbar
for s = 1, screen.count() do
  -- Create a promptbox for each screen
  mypromptbox[s] = awful.widget.prompt()
  -- Create an imagebox widget which will contains an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
    awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end))
	)
  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Create a tasklist widget
  mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons, {bg_normal = "#00000000"})

  -- Create the wibox
  mywibox[s] = awful.wibox({ position = "top", screen = s })

  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(mylauncher)
  left_layout:add(mytaglist[s])
  left_layout:add(mypromptbox[s])

  -- Widgets that are aligned to the right
  local right_layout = wibox.layout.fixed.horizontal()
  if s == 1 then right_layout:add(wibox.widget.systray()) end
  right_layout:add(spr)
  right_layout:add(cpuwidget)
  right_layout:add(batwidget)
  right_layout:add(netwidget)
  right_layout:add(volumewidget)
  right_layout:add(clockwidget)

  -- Now bring it all together (with the tasklist in the middle)
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_middle(mytasklist[s])
  layout:set_right(right_layout)

  mywibox[s]:set_widget(layout)
end


-- Dekstop Mouse bindings
root.buttons(awful.util.table.join(
  awful.button({ }, 3, function () mymainmenu:toggle() end)
))

-- Global Key bindings
globalkeys = awful.util.table.join(
  awful.key({ modkey }, "Left", awful.tag.viewprev),
  awful.key({ modkey }, "Right",  awful.tag.viewnext),
  awful.key({ modkey }, "Escape", awful.tag.history.restore),

  awful.key({ modkey }, "j", function ()
    awful.client.focus.byidx( 1)
    if client.focus then client.focus:raise() end
  end),
  awful.key({ modkey }, "k", function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end),
  awful.key({ modkey }, "w", function () mymainmenu:show() end),

  -- Layout manipulation
  awful.key({ modkey, "Shift" }, "j", function () awful.client.swap.byidx(  1) end),
  awful.key({ modkey, "Shift" }, "k", function () awful.client.swap.byidx( -1) end),
  awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
  awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
  awful.key({ modkey }, "u", awful.client.urgent.jumpto),
  awful.key({ modkey }, "Tab", function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end),
  awful.key({ modkey, "Shift" }, "Tab", function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end),


  -- Standard program
  awful.key({ modkey }, "Return", function () awful.util.spawn(terminal) end),
  awful.key({ modkey }, "e", function () awful.util.spawn(filemanager) end),
  awful.key({ "Control", altkey }, "l", function () awful.util.spawn("dm-tool lock") end),
  awful.key({ modkey, "Control" }, "r", awesome.restart),
  awful.key({ modkey, "Shift"   }, "q", awesome.quit),

  awful.key({ modkey }, "l", function () awful.tag.incmwfact( 0.05) end),
  awful.key({ modkey }, "h", function () awful.tag.incmwfact(-0.05) end),
  awful.key({ modkey, "Shift" }, "h", function () awful.tag.incnmaster( 1) end),
  awful.key({ modkey, "Shift" }, "l", function () awful.tag.incnmaster(-1) end),
  awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol( 1) end),
  awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1) end),
  awful.key({ modkey }, "space", function () awful.layout.inc(layouts,  1) end),
  awful.key({ modkey, "Shift" }, "space", function () awful.layout.inc(layouts, -1) end),
  awful.key({ modkey, "Control" }, "n", awful.client.restore),

  awful.key({ modkey }, "p", function() awful.util.spawn("xrandr --auto") end),
  -- ScreenShots
  awful.key({ }, "Print", function() awful.util.spawn("gnome-screenshot") end),
  awful.key({ "Control" }, "Print", function() awful.util.spawn("gnome-screenshot -c") end),
  awful.key({ "Shift" }, "Print", function() awful.util.spawn("gnome-screenshot -a") end),
  awful.key({ "Control", "Shift"}, "Print", function() awful.util.spawn("gnome-screenshot -ca") end),

  -- Audio
  awful.key({ }, "XF86AudioMute", function() awful.util.spawn("pactl set-sink-mute 1 toggle") end),
  awful.key({ }, "XF86AudioLowerVolume", function() awful.util.spawn("pactl set-sink-volume 1 -5%") end),
  awful.key({ }, "XF86AudioRaiseVolume", function() awful.util.spawn("pactl set-sink-volume 1 +5%") end),
  awful.key({ }, "XF86AudioNext", function () mediaKeys.sendCmd("Next") end),
  awful.key({ }, "XF86AudioPrev", function () mediaKeys.sendCmd("Previous") end),
  awful.key({ }, "XF86AudioPlay", function () mediaKeys.sendCmd("PlayPause") end),
  awful.key({ }, "XF86AudioStop", function () mediaKeys.sendCmd("Stop") end),

  -- Prompt
  awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),
  awful.key({ modkey }, "x", function ()
    awful.prompt.run({ prompt = "Run Lua code: " },
    mypromptbox[mouse.screen].widget,
    awful.util.eval, nil,
    awful.util.getdir("cache") .. "/history_eval")
  end),

  -- Menubar
  awful.key({ modkey }, "s", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
  awful.key({ modkey }, "f", function (c) c.fullscreen = not c.fullscreen end),
  awful.key({ modkey }, "q", function (c) c:kill() end),
  awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle ),
  awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
  awful.key({ modkey }, "o", awful.client.movetoscreen),
  awful.key({ modkey }, "t", function (c) c.ontop = not c.ontopend end),
  awful.key({ modkey }, "m", function (c)
    c.maximized_horizontal = not c.maximized_horizontal
    c.maximized_vertical = not c.maximized_vertical
  end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = awful.util.table.join(globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9,
      function ()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[i]
        if tag then awful.tag.viewonly(tag) end
    end),
    -- Toggle tag.
    awful.key({ modkey, "Control" }, "#" .. i + 9,
      function ()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[i]
        if tag then awful.tag.viewtoggle(tag) end
    end),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function ()
        if client.focus then
          local tag = awful.tag.gettags(client.focus.screen)[i]
          if tag then awful.client.movetotag(tag) end
       end
    end),
    -- Toggle tag.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
      function ()
        if client.focus then
          local tag = awful.tag.gettags(client.focus.screen)[i]
          if tag then awful.client.toggletag(tag) end
        end
    end))
end

clientbuttons = awful.util.table.join(
  awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ "Control", modkey }, 1, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  { rule = { },
    properties = {
			border_width = beautiful.border_width,
    	border_color = beautiful.border_normal,
    	focus = awful.client.focus.filter,
    	raise = true,
    	keys = clientkeys,
    	buttons = clientbuttons
		}
	}
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
  -- Enable sloppy focus
  c:connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
      and awful.client.focus.filter(c) then
      client.focus = c
    end
  end)

  if not startup then
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- awful.client.setslave(c)

    -- Put windows in a smart way, only if they does not set an initial position.
    if not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_overlap(c)
      awful.placement.no_offscreen(c)
    end
  end
end)
