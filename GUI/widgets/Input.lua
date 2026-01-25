local gpu     = require("component").gpu
local utils   = require("GUI.utils")

local Input   = {}
Input.__index = Input


---@param x number
---@param y number
---@param w number
---@param placeholder string
---@param default_background? number
---@param focused_background? number
---@param bind {table:table,key:string}
function Input.new(x, y, w, placeholder, default_background, focused_background, bind)
    return setmetatable({
        x = x,
        y = y,
        w = w,
        h = 1,
        -- binding
        bind = bind, -- { table = ..., key = ... }

        -- fallback if unbound
        text = "",
        placeholder = placeholder or "",
        default_background = default_background or utils:config().BACKGROUND_COLOR,
        focused_background = focused_background or default_background or utils:config().BACKGROUND_COLOR,
        focused = false
    }, Input)
end

function Input:draw()
    gpu.setBackground(self.focused and self.focused_background or self.default_background)

    gpu.set(self.x, self.y, string.rep(" ", self.w))

    local text = self:getText()
    local t = (#text > 0) and text or self.placeholder
    gpu.set(self.x, self.y, t:sub(1, self.w))

    if self.focused then
        gpu.set(self.x + #text, self.y, "_")
    end
end

function Input:getText()
    if self.bind then
        return tostring(self.bind.table[self.bind.key] or "")
    end
    return self.text
end

function Input:setText(value)
    if self.bind then
        self.bind.table[self.bind.key] = value
    else
        self.text = value
    end
end

---@param e event
---@return {draw:boolean,consume:boolean}
function Input:handle(e)
    if e[1] == "touch" then
        if utils.inside(self, e[3], e[4]) then
            -- self.appref:raise(self) -- 👈 bring forward
            self.focused = true
            return { draw = true, consume = true }
        else
            self.focused = false
            return { draw = true, consume = false }
        end
    elseif self.focused and e[1] == "key_down" then
        local c = e[3]
        local text = self:getText()

        if c == 8 then
            text = text:sub(1, -2)
        elseif c == 13 then
            self.focused = false
        elseif c >= 32 and c <= 126 then
            text = text .. string.char(c)
        end

        self:setText(text)
        return { draw = true, consume = true }
    end
    return { draw = false, consume = false }
end

return Input
