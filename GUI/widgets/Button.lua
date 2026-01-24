local gpu      = require("component").gpu
local utils    = require("GUI.utils")

local Button   = {}
Button.__index = Button

function Button:new(x, y, w, h, text, onclick)
    return setmetatable({
        x = x,
        y = y,
        w = w,
        h = h,
        text = text,
        onclick = onclick
    }, self)
end

function Button:draw()
    for i = 0, self.h - 1 do
        gpu.set(self.x, self.y + i, string.rep(" ", self.w))
    end
    gpu.set(
        self.x + math.floor((self.w - #self.text) / 2),
        self.y + math.floor(self.h / 2),
        self.text
    )
end

function Button:handle(e)
    if e[1] == "touch" then
        if utils.inside(self, e[3], e[4]) then
            self.gui:raise(self) -- 👈 z-order hook
            if self.onclick then self.onclick() end
            return true
        end
    end
end

return Button
