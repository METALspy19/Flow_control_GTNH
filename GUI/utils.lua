local filesystem = require("filesystem")
local colors = require("colors")
local serialization = require("serialization")

local utils = {}
utils.__index = utils

function utils.config()
    return {
        BACKGROUND_COLOR = { color = colors.purple, palette = true },
        FOREGROUND_COLOR = { color = colors.white, palette = true },
        SIZE = { x = 80, y = 25 }
    }
end

function utils.inside(w, x, y)
    return x >= w.x and x < w.x + w.w
        and y >= w.y and y < w.y + w.h
end

return utils
