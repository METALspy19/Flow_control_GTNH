local flowcontrol = require("Multiflow")
local GUI = require("GUI")
local colors = require("colors")
local sides = require("sides")
local component = require("component")
local App = GUI.App.new()

local label_bg = { color = colors.black, palette = true }
local input_bg2 = { color = colors.purple, palette = true }
local input_bg3 = { color = colors.green, palette = true }
local input_bg4 = { color = colors.red, palette = true }
local input_focus = { color = 0x878787, palette = false }

---@type indexmap
local direction_names = {
    [-1] = "NONE",
    [0] = "DOWN",
    [1] = "UP",
    [2] = "NORTH",
    [3] = "SOUTH",
    [4] = "WEST",
    [5] = "EAST",
}

local newConfig_form_data = {
    name = "",
    number_of_inputs = 0,
    number_of_outputs = 0,
    controller_type = nil
}


---@class io_state
---@field inputs table<io_config>
---@field outputs table<io_config>
local io_state = {
    mode = "input", -- or "output"
    index = 1,      -- current IO being configured
    inputs = {},
    outputs = {}
}

---@class io_config
---@field address string
---@field source_side integer
---@field source_tank integer
---@field sink_side integer
---@field sink_tank integer
---@field transfer_unit integer
---@field fluid string
local io_config = {}
io_config.__index = io_config
function io_config.new()
    local self = setmetatable({}, io_config)
    self.address = ""
    self.source_side = -1
    self.source_tank = 0
    self.sink_side = -1
    self.sink_tank = 0
    self.transfer_unit = 0
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
        function()
            for _, io in ipairs(io_state.inputs) do
                if #io.address < 1
                    or #io.fluid < 1
                    or io.source_side == -1
                    or io.source_tank < 1
                    or io.sink_side == -1
                    or io.transfer_unit <= 0
                    or io.sink_tank < 1 then
                    return
                end
            end
            for _, io in ipairs(io_state.outputs) do
                if #io.address < 1
                    or #io.fluid < 1
                    or io.source_side == -1
                    or io.source_tank < 1
                    or io.sink_side == -1
                    or io.transfer_unit <= 0
                    or io.sink_tank < 1 then
                    return
                end
            end
            local config = flowcontrol.Config.new()
            for _, io in ipairs(io_state.inputs) do
                config:addInput(io.address, io.source_side, io.source_tank, io.sink_side, io.sink_tank, io.transfer_unit,
                    io.fluid)
            end
            for _, io in ipairs(io_state.outputs) do
                config:addOutput(io.address, io.source_side, io.source_tank, io.sink_side, io.sink_tank, io
                    .transfer_unit, io.fluid)
            end
            config:addPlainRedstoneSignalController("default_addr", 0)
            local saveAgent = flowcontrol.Runtime.loadConfig(config):saveConfig("/home/FluidControl/" ..
                newConfig_form_data.name .. ".cfg")
        end), "NewConfig")

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

App:add(GUI.Widgets.NumericInput.new(
        { x = 40, y = 5, w = 39, buttonWidth = 3, h = 1 },
        { neg = "<", pos = ">", invalid = "" },
        { default_background = input_bg2, button_background = input_focus },
        { table = currentIO, key = "source_side", map = direction_names }, { step = 1, max = 5, min = 0 }),
    "IOConfig")
App:add(GUI.Widgets.NumericInput.new(
        { x = 40, y = 7, w = 39, buttonWidth = 3, h = 1 }, { neg = "-", pos = "+", invalid = "" },
        { default_background = input_bg2, button_background = input_focus },
        { table = currentIO, key = "source_tank" }, { step = 1, max = 20, min = 1 }),
    "IOConfig")
App:add(GUI.Widgets.NumericInput.new(
        { x = 40, y = 9, w = 39, buttonWidth = 3, h = 1 }, { neg = "<", pos = ">", invalid = "" },
        { default_background = input_bg2, button_background = input_focus },
        { table = currentIO, key = "sink_side", map = direction_names }, { step = 1, max = 5, min = 0 }),
    "IOConfig")
App:add(GUI.Widgets.NumericInput.new(
        { x = 40, y = 11, w = 39, buttonWidth = 3, h = 1 }, { neg = "-", pos = "+", invalid = "" },
        { default_background = input_bg2, button_background = input_focus },
        { table = currentIO, key = "sink_tank" }, { step = 1, max = 20, min = 1 }),
    "IOConfig")
App:add(GUI.Widgets.Input.new(
        { x = 3, y = 13, w = 57, h = 1 }, "Fluid name",
        { default_background = input_bg2, focused_background = input_focus },
        { table = currentIO, key = "fluid" }),
    "IOConfig")
App:add(GUI.Widgets.NumericInput.new(
        { x = 40, y = 15, w = 39, buttonWidth = 3, h = 1 }, { neg = "-", pos = "+", invalid = "" },
        { default_background = input_bg2, button_background = input_focus },
        { table = currentIO, key = "transfer_unit" }, { step = 1000, max = 800000, min = 0 }),
    "IOConfig")

App:add(GUI.Widgets.Button.new(
        { x = 3, y = 5, w = 11, h = 1 },
        { table = { text = "Source Side" }, key = "text" },
        { default_background = label_bg }),
    "IOConfig")
App:add(GUI.Widgets.Button.new(
        { x = 3, y = 7, w = 11, h = 1 },
        { table = { text = "Source Tank" }, key = "text" },
        { default_background = label_bg }),
    "IOConfig")
App:add(GUI.Widgets.Button.new(
        { x = 3, y = 9, w = 9, h = 1 },
        { table = { text = "Sink Side" }, key = "text" },
        { default_background = label_bg }),
    "IOConfig")
App:add(GUI.Widgets.Button.new(
        { x = 3, y = 11, w = 9, h = 1 },
        { table = { text = "Sink Tank" }, key = "text" },
        { default_background = label_bg }),
    "IOConfig")
App:add(GUI.Widgets.Button.new(
        { x = 3, y = 15, w = 27, h = 1 },
        { table = { text = "Recipe Amount/Transfer Unit" }, key = "text" },
        { default_background = label_bg }),
    "IOConfig")



App:add(
    GUI.Widgets.Button.new(
        { x = 63, y = 13, w = 16, h = 1 },
        { table = { text = "Scan for fluid" }, key = "text" },
        { default_background = input_bg2 },
        function()
            if currentIO.source_side and currentIO.source_tank and currentIO.address then
                local scan = component.proxy(currentIO.address).getFluidInTank(currentIO.source_side)
                if scan then
                    if scan[currentIO.source_tank] then
                        local new_name = scan[currentIO.source_tank].name
                        if new_name then
                            currentIO.fluid = tostring(new_name)
                        else
                            currentIO.fluid = "No fluid in tank"
                        end
                    else
                        currentIO.fluid = "No tank with this index"
                    end
                else
                    currentIO.fluid = "No fluid tank block detected"
                end
            end
        end),
    "IOConfig")

-- App:add(
--     GUI.Widgets.Button.new(
--         { x = 20, y = 20, w = 40, h = 3 },
--         { table = { text = "Validate" }, key = "text" },
--         { default_background = input_bg2 }),
--     "IOConfig")

App:add(IO_index_swich, "IOConfig")

---------------------------------------------------------------------------
--#endregion

App:switch("Main")
App:run()
