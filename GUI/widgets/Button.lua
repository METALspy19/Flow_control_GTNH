local gpu   = require("component").gpu
local utils = require("GUI.utils")


local Button   = {}
Button.__index = Button


---@param x number
---@param y number
---@param w number
---@param text string
---@param onclick? function
---@param default_background? number
function Button.new(x, y, w, h, text, default_background, onclick)
    return setmetatable({
        x = x,
        y = y,
        w = w,
        h = h,
        text = text,
        default_background = default_background or utils:config().BACKGROUND_COLOR,
        onclick = onclick
    }, Button)
end

function Button:draw()
    gpu.setBackground(self.default_background)
    for i = 0, self.h - 1 do
        gpu.set(self.x, self.y + i, string.rep(" ", self.w))
    end
    gpu.set(
        self.x + math.floor((self.w - #self.text) / 2),
        self.y + math.floor(self.h / 2),
        self.text
    )
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
    return { draw = false, consume = false }
end

return Button
