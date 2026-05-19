local utils = {}

function utils.capitalize(string)
    return (string:gsub("(%a)([%w_]*)", function(first, rest)
                return first:upper() .. rest:lower()
            end))
end

return utils