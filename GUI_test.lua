local GUI = require("GUI")

local App = GUI.App

App:newPage("main")
App:newPage("settings")

App:add(GUI.Widgets.Input:new(5, 5, 20, "Group name"), "main")

App:add(GUI.Widgets.Button:new(5, 8, 14, 3, "Settings", function()
    GUI:switch("settings")
end), "main")

App:add(GUI.Widgets.Button:new(5, 5, 14, 3, "Back", function()
    GUI:switch("main")
end), "settings")

App:draw()
