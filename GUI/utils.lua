local utils = {}

function utils.inside(w, x, y)
    return x >= w.x and x < w.x + w.w
        and y >= w.y and y < w.y + w.h
end

return utils
