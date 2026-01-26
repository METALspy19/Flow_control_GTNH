local flowcontrol = require("Multiflow")
local GUI = require("GUI")
local colors = require("colors")
local App = GUI.App.new()

local label_bg = { color = colors.black, palette = true }
local input_bg2 = { color = colors.purple, palette = true }
local input_bg3 = { color = colors.green, palette = true }
local input_bg4 = { color = colors.red, palette = true }
local input_focus = { color = 0x878787, palette = false }

local newConfig_form_data = {
    name = "",
    number_of_inputs = 0,
    number_of_outputs = 0,
    controller_type = nil
}

local io_state = {
    mode = "input", -- or "output"
    index = 1,      -- current IO being configured
    inputs = {},
    outputs = {}
}


local io_config = {}
io_config.__index = io_config
function io_config.new()
    local self = setmetatable({}, io_config)
    self.address = ""
    self.source_side = ""
    self.source_tank = ""
    self.sink_side = ""
    self.sink_tank = ""
    self.fluid = ""
    return self
end

local currentIO = setmetatable({}, {
    __index = function(_, k)
        local list = io_state.mode == "input" and io_state.inputs or io_state.outputs
        local io = list[io_state.index]
        return io and io[k]
    end,
    __newindex = function(_, k, v)
        local list = io_state.mode == "input" and io_state.inputs or io_state.outputs
        local io = list[io_state.index]
        if io then io[k] = v end
    end
})

--#region Dynamic Components

local IO_index_swich = GUI.Widgets.NumericInput.new(
    { x = 1, y = 1, w = 80, buttonWidth = 5, h = 1 },
    { neg = "<", pos = ">", invalid = "|" },
    { default_background = input_bg4, button_background = input_focus },
    { table = io_state, key = "index" },
    { step = 1, max = 100, min = 1 },
    function()
        App:draw()
    end
)
--#endregion
--#region STATIC Components

---------------------------------------------------------------------
App:newPage("Main")
--///////////////////////////// MAIN SCREEN///////////////////////////
App:add(
    GUI.Widgets.Button.new(
        { x = 1, y = 1, w = 80, h = 1 },
        { table = { text = "NewConfig" }, key = "text" },
        { default_background = input_bg2 },
        function() App:switch("NewConfig") end
    ), "Main")



---------------------------------------------------------------------
App:newPage("NewConfig")
--///////////////////////////// New Config Page //////////////////
App:add(
    GUI.Widgets.Button.new(
        { x = 1, y = 25, w = 80, h = 1 },
        { table = { text = "Back" }, key = "text" },
        { default_background = input_bg2 },
        function() App:switch("Main") end), "NewConfig")

App:add(
    GUI.Widgets.Input.new({ x = 3, y = 2, w = 20, h = 1 }, "Control Group Name",
        { default_background = input_bg3, focused_background = input_focus },
        { table = newConfig_form_data, key = "name" }),
    "NewConfig")


App:add(
    GUI.Widgets.Button.new(
        { x = 3, y = 4, w = 10, h = 1 },
        { table = { text = "Inputs  #:" }, key = "text" },
        { default_background = label_bg }), "NewConfig")
App:add(
    GUI.Widgets.NumericInput.new(
        { x = 15, y = 4, w = 15, buttonWidth = 2, h = 1 },
        { neg = "-", pos = "+", invalid = "" },
        { default_background = input_bg4, button_background = input_focus },
        { table = newConfig_form_data, key = "number_of_inputs" },
        { step = 1, max = 100, min = 1 }
    ), "NewConfig")

App:add(
    GUI.Widgets.Button.new(
        { x = 3, y = 6, w = 10, h = 1 },
        { table = { text = "Outputs #:" }, key = "text" },
        { default_background = label_bg }),
    "NewConfig")
App:add(
    GUI.Widgets.NumericInput.new(
        { x = 15, y = 6, w = 15, buttonWidth = 2, h = 1 },
        { neg = "-", pos = "+", invalid = "" },
        { default_background = input_bg4, button_background = input_focus },
        { table = newConfig_form_data, key = "number_of_outputs" },
        { step = 1, max = 100, min = 1 }
    ), "NewConfig")

App:add(
    GUI.Widgets.Button.new(
        { x = 3, y = 8, w = 10, h = 1 },
        { table = { text = "Controller" }, key = "text" },
        { default_background = label_bg }),
    "NewConfig")
App:add(
    GUI.Widgets.Button.new(
        { x = 15, y = 8, w = 15, h = 1 },
        { table = { text = "RedstoneControl" }, key = "text" },
        { default_background = label_bg }),
    "NewConfig")
App:add(
    GUI.Widgets.Button.new(
        { x = 60, y = 2, w = 20, h = 3 },
        { table = { text = "Configure Inputs" }, key = "text" },
        { default_background = input_bg2 },
        function()
            io_state.mode = "input"
            io_state.index = 1

            io_state.inputs = {}
            for i = 1, newConfig_form_data.number_of_inputs do
                io_state.inputs[i] = io_config.new()
            end
            IO_index_swich.max = newConfig_form_data.number_of_outputs

            App:switch("IOConfig")
        end
    ), "NewConfig")
App:add(
    GUI.Widgets.Button.new({ x = 60, y = 6, w = 20, h = 3 }, { table = { text = "Configure Outputs" }, key = "text" },
        { default_background = input_bg2 },
        function()
            io_state.mode = "output"
            io_state.index = 1

            io_state.outputs = {}
            for i = 1, newConfig_form_data.number_of_outputs do
                io_state.outputs[i] = io_config.new()
            end
            IO_index_swich.max = newConfig_form_data.number_of_outputs
            App:switch("IOConfig")
        end), "NewConfig")

App:add(
    GUI.Widgets.Button.new({ x = 60, y = 21, w = 20, h = 3 }, { table = { text = "Save" }, key = "text" },
        { default_background = input_bg2 },
        function() App:switch("Main") end), "NewConfig")

---------------------------------------------------------------------------
App:newPage("IOConfig")
---////////////////////////////// InputConfigure ///////////////////////
---
App:add(
    GUI.Widgets.Button.new(
        { x = 1, y = 25, w = 80, h = 1 },
        { table = { text = "Back" }, key = "text" },
        { default_background = input_bg2 },
        function() App:switch("NewConfig") end),
    "IOConfig")

App:add(GUI.Widgets.Input.new(
        { x = 3, y = 3, w = 76, h = 1 }, "HW Address",
        { default_background = input_bg2, focused_background = input_focus },
        { table = currentIO, key = "address" }),
    "IOConfig")

App:add(IO_index_swich, "IOConfig")

---------------------------------------------------------------------------
--#endregion

App:switch("Main")
App:run()
