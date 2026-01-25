local flowcontrol = require("Multiflow")
local GUI = require("GUI")

local App = GUI.App.new()

local input_bg = 0x5A5A5A
local input_focus = 0x878787

local newConfig_form_data = {
    name = ""
}

App:newPage("NewConfig")
App:newPage("Main")
-- App:newPage("Main")
-- App:newPage("Main")
App:add(GUI.Widgets.Button.new(1, 1, 80, 1, "NewConfig", input_bg, function() App:switch("NewConfig") end), "Main")
App:add(GUI.Widgets.Button.new(1, 25, 80, 1, "Back", input_bg, function() App:switch("Main") end), "NewConfig")
App:add(
    GUI.Widgets.Input.new(3, 2, 15, "Control Group Name", input_bg, input_focus,
        { table = newConfig_form_data, key = "name" }),
    "NewConfig")
-- App:add(GUI.Widgets.Input.new(3, 4, 10, "name", input_bg, input_focus), "NewConfig")
-- App:add(GUI.Widgets.Input.new(3, 6, 10, "name", input_bg, input_focus), "NewConfig")
-- App:add(GUI.Widgets.Input.new(3, 8, 10, "name", input_bg, input_focus), "NewConfig")
-- App:add(GUI.Widgets.Input.new(3, 10, 10, "name", input_bg, input_focus), "NewConfig")
-- App:add(GUI.Widgets.Input.new(3, 12, 10, "name", input_bg, input_focus), "NewConfig")

App:run()
