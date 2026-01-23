local component = require("component")
local serialization = require("serialization")
local filesystem = require("filesystem")
local pp = require("pretty_serialize")

Config = {}
Config.__index = Config

function Config.new(name)
    local self = setmetatable({}, Config)
    self.name = name
    self.inputs = {}
    self.controller = {}
    self.outputs = {}
    return self
end

function Config:addInput(address, source_side, source_tank, sink_side, sink_tank, transfer_unit, fluid)
    local input = {
        address = address,
        source_side = source_side,
        source_tank = source_tank,
        sink_side = sink_side,
        sink_tank = sink_tank,
        transfer_unit = transfer_unit,
        fluid = fluid
    }
    table.insert(self.inputs, input)
    return #self.inputs
end

function Config:addOutput(address, source_side, source_tank, sink_side, sink_tank, transfer_unit, fluid)
    local output = {
        address = address,
        source_side = source_side,
        source_tank = source_tank,
        sink_side = sink_side,
        sink_tank = sink_tank,
        transfer_unit = transfer_unit,
        fluid = fluid
    }
    table.insert(self.outputs, output)
    return #self.outputs
end

function Config:addPlainRedstoneSignalController(address, side)
    local controller = {
        address = address,
        side = side,
    }
    self.controller = controller
end

return Config
