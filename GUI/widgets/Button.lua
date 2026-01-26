local gpu   = require("component").gpu
local utils = require("GUI.utils")


local Button   = {}
Button.__index = Button

---@alias color {color:number,palette:boolean}
---@param size {x:integer,y:integer,w:integer,h?:integer}
---@param bind {table:table,key:string}
---@param onclick? function
---@param colors? {default_background:color}
function Button.new(size, bind, colors, onclick)
    return setmetatable({
        x = tonumber(size.x),
        y = tonumber(size.y),
        w = tonumber(size.w),
        h = tonumber(size.h) or 1,
        -- binding
        bind = bind, -- { table = ..., key = ... }
        default_background = colors and colors.default_background or utils:config().BACKGROUND_COLOR,
        onclick = onclick
    }, Button)
end

function Button:draw()
    local oldColor, oldPalette = gpu.getBackground()
    local text = self:getText()
    gpu.setBackground(self.default_background.color, self.default_background.palette)
    for i = 0, self.h - 1 do
        gpu.set(self.x, self.y + i, string.rep(" ", self.w))
    end
    gpu.set(
        self.x + math.floor((self.w - #text) / 2),
        self.y + math.floor(self.h / 2),
        text
    )
    local _reset = utils.config().BACKGROUND_COLOR
    gpu.setBackground(oldColor, oldPalette)
end

---@alias event table
---@param e event
---@return {draw:boolean,consume:boolean}
function Button:handle(e)
    if e[1] == "touch" then
        if utils.inside(self, e[3], e[4]) then
            -- self.appref:raise(self) -- 👈 z-order hook
            if self.onclick then self.onclick() end
            return { draw = true, consume = true }
        end
    end
    return { draw = true, consume = false }
end

function Button:getText()
    if self.bind then
        return tostring(self.bind.table[self.bind.key] or "")
    end
    return ""
end

return Button
