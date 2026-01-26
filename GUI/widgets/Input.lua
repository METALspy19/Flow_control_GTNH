local gpu     = require("component").gpu
local utils   = require("GUI.utils")
local unicode = require("unicode")

local Input   = {}
Input.__index = Input


---@param size {x:integer,y:integer,w:integer,h?:integer}
---@param colors? {default_background:color,focused_background:color}
---@param placeholder string
---@param bind {table:table,key:string}
function Input.new(size, placeholder, colors, bind)
    return setmetatable({
        x = tonumber(size.x),
        y = tonumber(size.y),
        w = tonumber(size.w),
        h = tonumber(size.h) or 1,
        -- binding
        bind = bind, -- { table = ..., key = ... }

        -- fallback if unbound
        text = "",

        placeholder = placeholder or "",
        default_background = colors and colors.default_background or utils:config().BACKGROUND_COLOR,
        focused_background = colors and colors.focused_background or colors and colors.default_background or
            utils:config().BACKGROUND_COLOR,
        focused = false
    }, Input)
end

function Input:draw()
    local oldColor, oldPalette = gpu.getBackground()
    local bg_col = self.focused and self.focused_background or self.default_background
    gpu.setBackground(bg_col.color, bg_col.palette)

    gpu.set(self.x, self.y, string.rep(" ", self.w))

    local text = self:getText()
    local t = (#text > 0) and text or self.placeholder

    if self.focused then
        gpu.set(self.x, self.y, text:sub(1, self.w))
        gpu.set(self.x + #text, self.y, "_")
    else
        gpu.set(self.x, self.y, t:sub(1, self.w))
    end
    gpu.setBackground(oldColor, oldPalette)
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
            self.focused = true
            return { draw = true, consume = true }
        else
            self.focused = false
            return { draw = true, consume = false }
        end
    elseif self.focused and e[1] == "clipboard" then
        -- e[3] contains the pasted text
        local text = self:getText()
        local pasted = e[3]:gsub("[\r\n]", "")
        text = text .. pasted
        self:setText(text)
        return { draw = true, consume = true }
    elseif self.focused and e[1] == "key_down" then
        local c = e[3]
        local code = e[4]
        local text = self:getText()

        if code == 14 then
            text = text:sub(1, -2)
        elseif code == 28 then
            self.focused = false
        elseif c > 0 then
            text = text .. unicode.char(c)
        end

        self:setText(text)
        return { draw = true, consume = true }
    end
    return { draw = false, consume = false }
end

return Input
