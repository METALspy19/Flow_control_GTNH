local gpu         = require("component").gpu
local utils       = require("GUI.utils")

local NumericIn   = {}
NumericIn.__index = NumericIn

---@param size {x:integer,y:integer,w:integer,buttonWidth:integer,h?:integer}
---@param texts {neg:string,pos:string,invalid:string}
---@param colors {default_background:color,button_background:color}}
---@param bind {table:table,key:string}
---@param limits {step?:integer,max?:integer,min?:integer}
---@param onValueChanged? function
function NumericIn.new(size, texts, colors, bind, limits, onValueChanged)
    return setmetatable({
        x = tonumber(size.x),
        y = tonumber(size.y),
        w = tonumber(size.w),
        buttonWidth = tonumber(size.buttonWidth),
        h = tonumber(size.h) or 1,
        -- binding
        bind = bind, -- { table = ..., key = ... }
        step = limits.step or 1,

        max = limits.max,
        min = limits.min,
        onValueChanged = onValueChanged,

        -- fallback if unbound
        value = 0,
        placeholder = texts or { neg = "<", pos = ">", invalid = "|" },
        default_background = colors.default_background or utils:config().BACKGROUND_COLOR,
        button_background = colors.button_background or colors.default_background or utils:config().BACKGROUND_COLOR,
    }, NumericIn)
end

function NumericIn:draw()
    local oldColor, oldPalette = gpu.getBackground()
    local value = self:getValue() or 0


    gpu.setBackground(self.button_background.color, self.button_background.palette)
    for i = 0, self.h - 1 do
        gpu.set(self.x, self.y + i, string.rep(" ", self.buttonWidth))
    end
    if self.min ~= nil and value <= self.min then
        gpu.set(
            self.x + math.floor((self.buttonWidth - #self.placeholder.invalid) / 2),
            self.y + math.floor((self.h - 1) / 2),
            self.placeholder.invalid
        )
    else
        gpu.set(
            self.x + math.floor((self.buttonWidth - #self.placeholder.neg) / 2),
            self.y + math.floor((self.h - 1) / 2),
            self.placeholder.neg
        )
    end


    gpu.setBackground(self.default_background.color, self.default_background.palette)
    gpu.set(self.x + self.buttonWidth, self.y + math.floor((self.h - 1) / 2),
        string.rep(" ", self.w - 2 * self.buttonWidth))
    gpu.set(
        self.x + self.buttonWidth + math.floor((self.w - 2 * self.buttonWidth) / 2) - math.floor(#tostring(value) / 2),
        self.y + math.floor((self.h - 1) / 2),
        tostring(value):sub(1, self.w - 2 * self.buttonWidth))



    gpu.setBackground(self.button_background.color, self.button_background.palette)
    for i = 0, self.h - 1 do
        gpu.set(self.x + self.w - self.buttonWidth, self.y + i, string.rep(" ", self.buttonWidth))
    end
    if self.max ~= nil and value >= self.max then
        gpu.set(
            self.x + self.w - self.buttonWidth + math.floor((self.buttonWidth - #self.placeholder.invalid) / 2),
            self.y + math.floor((self.h - 1) / 2),
            self.placeholder.invalid
        )
    else
        gpu.set(
            self.x + self.w - self.buttonWidth + math.floor((self.buttonWidth - #self.placeholder.pos) / 2),
            self.y + math.floor((self.h - 1) / 2),
            self.placeholder.pos
        )
    end

    gpu.setBackground(oldColor, oldPalette)
end

function NumericIn:getValue()
    if self.bind then
        return tonumber(self.bind.table[self.bind.key]) or 0
    end
    return self.value
end

function NumericIn:setValue(value)
    if self.min ~= nil then
        value = math.max(self.min, value)
    end
    if self.max ~= nil then
        value = math.min(self.max, value)
    end

    if self.bind then
        self.bind.table[self.bind.key] = value
    else
        self.value = value
    end
end

---@param e event
---@return {draw:boolean,consume:boolean}
function NumericIn:handle(e)
    if e[1] == "touch" then
        if utils.inside({ x = self.x, y = self.y, w = self.buttonWidth, h = self.h }, e[3], e[4]) then
            --decrement bind value
            local value = self:getValue()
            value = value - self.step
            self:setValue(value)

            if self.onValueChanged then self.onValueChanged() end
            return { draw = true, consume = true }
        elseif utils.inside({ x = self.x + self.w - self.buttonWidth, y = self.y, w = self.buttonWidth, h = self.h }, e[3], e[4]) then
            --increment bind value
            local value = self:getValue()
            value = value + self.step
            self:setValue(value)
            if self.onValueChanged then self.onValueChanged() end
            return { draw = true, consume = true }
        end
    end



    return { draw = false, consume = false }
end

return NumericIn
