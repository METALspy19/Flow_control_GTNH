local component = require("component")
local serialization = require("serialization")
local filesystem = require("filesystem")
local pp = require("pretty_serialize")

Config = {}
Config.__index = Config

---comment
---@param name string
---@return table
function Config.new(name)
    local self = setmetatable({}, Config)
    self.name = name
    self.inputs = {}
    self.controller = {}
    self.outputs = {}
    return self
end

---@param address string
---@param source_side number
---@param source_tank number
---@param sink_side number
---@param sink_tank number
---@param transfer_unit number
---@param fluid string
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

---@param address string
---@param source_side number
---@param source_tank number
---@param sink_side number
---@param sink_tank number
---@param transfer_unit number
---@param fluid string
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

---@param address string
---@param side number
function Config:addPlainRedstoneSignalController(address, side)
    local controller = {
        address = address,
        side = side,
    }
    self.controller = controller
end

return Config
