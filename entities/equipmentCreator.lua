local equipmentData = require('data.equipmentData')

local equipmentCreator = {}

function equipmentCreator.new(ref)
    
    local data = equipmentData[ref]
    
    local eq = {}
    eq.name = data.name
    eq.cat = data.cat
    eq.subCat = data.subCat or nil
    eq.atkPower = data.atkPower or 0
    eq.defPower = data.defPower or 0
    eq.passives = data.passives or nil
    eq.class = nil
    
    if data.subCat == 'SWORD' or data.subCat == 'DAGGER' or data.subCat == 'FIST' then
        eq.class = 'LIGHTWEIGHT'
    elseif data.subCat == 'HAMMER' or data.subCat == 'AXE' or data.subCat == 'SPEAR' then
        eq.class = 'HEAVYWEIGHT'
    end
    
    return eq
end

return equipmentCreator