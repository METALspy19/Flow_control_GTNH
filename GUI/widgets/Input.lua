local gpu     = require("component").gpu
local utils   = require("GUI.utils")

local Input   = {}
Input.__index = Input

function Input:new(x, y, w, placeholder)
    return setmetatable({
        x = x,
        y = y,
        w = w,
        h = 1,
        text = "",
        placeholder = placeholder or "",
        focused = false
    }, self)
end

function Input:draw()
    gpu.set(self.x, self.y, string.rep(" ", self.w))
    local t = (#self.text > 0) and self.text or self.placeholder
    gpu.set(self.x, self.y, t:sub(1, self.w))
    if self.focused then
        gpu.set(self.x + #self.text, self.y, "_")
    end
end

function Input:handle(e)
    if e[1] == "touch" then
        if utils.inside(self, e[3], e[4]) then
            self.gui:raise(self) -- 👈 bring forward
            self.focused = true
            return true
        else
            self.focused = false
        end
    elseif self.focused and e[1] == "key_down" then
        local c = e[3]
        if c == 8 then
            self.text = self.text:sub(1, -2)
        elseif c == 13 then
            self.focused = false
        elseif c >= 32 and c <= 126 then
            self.text = self.text .. string.char(c)
        end
        return true
    end
end

return Input
