local component = require("component")
local serialization = require("serialization")
local filesystem = require("filesystem")
local pp = require("pretty_serialize")

Runtime = {}
Runtime.__index = Runtime

function Runtime.loadConfig(configTable_or_Path)
    local self = setmetatable({}, Runtime)
    if type(configTable_or_Path) == "table" then
        self.config = configTable_or_Path
        return self
    elseif type(configTable_or_Path) == "string" then
        if filesystem.exists(configTable_or_Path) then
            local file <close> = io.open(configTable_or_Path, "r")
            if file then
                local data = file:read("*a")
                self.config = serialization.unserialize(data)
                return self
            end
        end
        return nil
    else
        return nil
    end
end

function Runtime:saveConfig(toPath)
    local file <close> = io.open(toPath, "w")
    if file then
        file:write(pp.serialize(self.config))
        return true
    end
    return false
end

Runtime.States = {
    FILL = "fill",
    RUN = "run",
    EMPTY = "empty"
}
Runtime.DEFAULT_STATE = Runtime.States.FILL
function Runtime:init()
    self.state = Runtime.DEFAULT_STATE
    self.fillCounts = 0
    self.transposers = {}
    for _, list in ipairs({ self.config.inputs, self.config.outputs }) do
        for _, io in ipairs(list) do
            self.transposers[io.address] =
                self.transposers[io.address] or component.proxy(io.address)
        end
    end

    local rc = self.config.controller
    self.redstone = rc.address and component.proxy(rc.address) or nil
end

function Runtime:updateTankCache()
    self._tankCache = {}

    local function cache(address, side)
        local t = self.transposers[address]
        if not t then return end

        local info = t.getFluidInTank(side)
        if info then
            self._tankCache[address] = self._tankCache[address] or {}
            self._tankCache[address][side] = info -- FULL array now
        end
    end

    for _, io in ipairs(self.config.inputs) do
        cache(io.address, io.source_side)
        cache(io.address, io.sink_side)
    end

    for _, io in ipairs(self.config.outputs) do
        cache(io.address, io.source_side)
        cache(io.address, io.sink_side)
    end
end

function Runtime:getTank(address, side, tank)
    local a = self._tankCache and self._tankCache[address]
    local s = a and a[side]
    return s and s[tank] or nil
end

function Runtime:tick()
    if self.state == Runtime.States.FILL then
        self:tickFill()
    elseif self.state == Runtime.States.RUN then
        self:tickRun()
    elseif self.state == Runtime.States.EMPTY then
        self:tickEmpty()
    end
end

function Runtime:tickFill()
    local minTransfers = math.huge

    for _, input in ipairs(self.config.inputs) do
        local source = self:getTank(
            input.address,
            input.source_side,
            input.source_tank
        )
        local sink = self:getTank(
            input.address,
            input.sink_side,
            input.sink_tank
        )

        if not source or not sink then return end

        if not self:tankMatchesFluid(source, input.fluid) then
            return -- wrong fluid in source
        end

        if sink.amount > 0 and not self:tankMatchesFluid(sink, input.fluid) then
            return -- would mix fluids
        end

        local src = math.floor(source.amount / input.transfer_unit)
        local dst = math.floor((sink.capacity - sink.amount) / input.transfer_unit)

        local possible = math.min(src, dst)
        if possible == 0 then return end

        minTransfers = math.min(minTransfers, possible)
    end

    -- Perform transfers
    for _, input in ipairs(self.config.inputs) do
        local t = self.transposers[input.address]

        for i = 1, minTransfers do
            local moved = t.transferFluid(
                input.source_side,
                input.sink_side,
                input.transfer_unit,
                input.source_tank -- IMPORTANT
            )
            if not moved or moved == 0 then break end
        end
    end

    self.fillCounts = self.fillCounts + minTransfers
    self:setMachine(true)
    self.state = Runtime.STATES.RUN
end

function Runtime:tickRun()
    self:setMachine(true)

    if self:outputsFullEnough() then
        self:setMachine(false)
        self.state = Runtime.States.EMPTY
    end
end

function Runtime:tickEmpty()
    local empty = true

    for _, output in ipairs(self.config.outputs) do
        local t = self.transposers[output.address]

        local moved = t.transferFluid(
            output.source_side,
            output.sink_side,
            output.transfer_unit,
            output.source_tank
        )

        if moved and moved > 0 then
            empty = false
        end
    end

    if empty then
        self.fillCounts = 0
        self.state = Runtime.STATES.FILL
    end
end

function Runtime:setMachine(on)
    if not self.redstone then return end

    local rc = self.config.controller
    self.redstone.setOutput(rc.side, (on and 15 or 0))
end

function Runtime:outputsFullEnough()
    for _, output in ipairs(self.config.outputs) do
        local t = self.transposers[output.address]
        local tank = t.getFluidInTank(output.source_side)

        if not tank or not tank[1] then return false end

        local required = output.transfer_unit * self.fillCounts
        if tank[1].amount < required then
            return false
        end
    end
    return true
end

function Runtime:tankMatchesFluid(tank, expected)
    if not tank then return false end
    if not expected then return true end
    return tank.name == expected
end

return Runtime
