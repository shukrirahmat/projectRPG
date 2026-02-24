local itemData = {}

itemData['healingTonic'] = { id = 1, name = 'Healing Tonic', desc = 'Recover small amount of HP'}
itemData['prismTonic'] = { id = 2, name = 'Prism Tonic', desc = 'Recover medium amount of HP'}
itemData['talisman'] = { id = 3, name = 'Talisman', desc = 'Remove curse to one ally'}

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