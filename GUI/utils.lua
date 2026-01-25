local filesystem = require("filesystem")
local colors = require("colors")
local serialization = require("serialization")

local utils = {}
utils.__index = utils

function utils.config()
    return {
        BACKGROUND_COLOR = 0x000000,
        FOREGROUND_COLOR = 0xFFFFFF,
        SIZE = { x = 80, y = 25 }
    }
end

function utils.inside(w, x, y)
    return x >= w.x and x < w.x + w.w
        and y >= w.y and y < w.y + w.h
end

return utils
