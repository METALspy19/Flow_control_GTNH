local M = {}

local function isSimpleKey(k)
    return type(k) == "string" and k:match("^[%a_][%w_]*$")
end

local function serializeValue(value, indent)
    indent = indent or 0
    local spacing = string.rep("  ", indent)

    if type(value) == "table" then
        local result = "{\n"

        for k, v in pairs(value) do
            local key
            if isSimpleKey(k) then
                key = k
            else
                key = "[" .. serializeValue(k, 0) .. "]"
            end

            result = result
                .. spacing .. "  "
                .. key .. " = "
                .. serializeValue(v, indent + 1)
                .. ",\n"
        end

        return result .. spacing .. "}"
    end

    if type(value) == "string" then
        return string.format("%q", value)
    end

    return tostring(value)
end

function M.serialize(value)
    return serializeValue(value, 0)
end

return M
