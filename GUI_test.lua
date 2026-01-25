local GUI = require("GUI")

local App = GUI.App

App:newPage("main")
App:newPage("settings")

-- print("pages_ok")

App:add(GUI.Widgets.Input.new(5, 5, 20, "Group name", 0x5A5A5A, 0x878787), "main")


-- print("input ok")

App:add(GUI.Widgets.Button.new(2, 24, 14, 3, "Settings", function() App:switch("settings") end), "main")

App:add(GUI.Widgets.Button.new(5, 5, 14, 3, "Back", function() App:switch("main") end), "settings")

-- print("add ok")
App.running = true

App:run()
