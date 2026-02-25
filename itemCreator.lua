local itemData = {}

itemData['healingTonic'] = { id = 1, name = 'Healing Tonic', desc = 'Recover small amount of HP'}
itemData['prismTonic'] = { id = 2, name = 'Prism Tonic', desc = 'Recover HP to full'}
itemData['goldenNectar'] = { id = 3, name = 'Golden Nectar', desc = 'Recover small amount of MP'}
itemData['antidote'] = { id = 4, name = 'Antidote', desc = 'Cures poison from one ally'}
itemData['holyWater'] = { id = 5, name = 'Holy Water', desc = 'Cures curse from one ally'}
itemData['bandage'] = { id = 6, name = 'Bandage', desc = 'Cures wound from one ally'}
itemData['wigglyGrass'] = { id = 7, name = 'Wiggly Grass', desc = 'Cures paralysis from one ally'}
itemData['fairyBell'] = { id = 8, name = 'Fairy Bell', desc = 'Wake one ally from sleep'}
itemData['clarityBrew'] = { id = 9, name = 'Clarity Brew', desc = 'Snap one ally from confuse'}

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