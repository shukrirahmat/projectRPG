local itemData = require('data.itemData')

local itemCreator = {}

function itemCreator.new(ref)
    data = itemData[ref]
    
    local item = {}
    item.ref = ref
    item.id = data.id
    item.name = data.name
    item.desc = data.desc
    
    return item
end

return itemCreator