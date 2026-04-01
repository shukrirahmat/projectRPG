local utils = {}

function utils.capitalize(string)
   return (string:gsub("^%l", string.upper))
end

return utils