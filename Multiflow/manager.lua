local component       = require("component")
local serialization   = require("serialization")
local filesystem      = require("filesystem")
local Runtime, Config = require("Multiflow.runtime")


Manager = {}
Manager.__index = Manager

Manager._VERSION = "0.0.1"
---@alias Path string
---@param cfgFolder Path
function Manager.loadRuntimesFromConfigs(cfgFolder)
    local self = setmetatable({}, Manager)

    self.Runtimes = {}

    for file in filesystem.list(cfgFolder) do
        local path = filesystem.concat(cfgFolder, file)
        local rt = Runtime.loadConfig(path)
        if rt then
            table.insert(self.Runtimes, rt)
        end
    end

    return self
end

function Manager:tickAll()
    for _, system in ipairs(self.Runtimes) do
        system:tick()
    end
end

return Manager, Runtime, Config
