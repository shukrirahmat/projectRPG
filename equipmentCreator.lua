equipmentCreator = {}

local dataSheet = {}

dataSheet['rustedAxe'] = {
    name = 'Rusted Axe',
    atkPower = 80,
    cat = 'WEAPON',
    subCat = 'AXE'
}

dataSheet['leatherFist'] = {
    name = 'Leather Fist',
    atkPower = 40,
    cat = 'WEAPON',
    subCat = 'FIST'
}

dataSheet['woodenStaff'] = {
    name = 'Wooden Staff',
    atkPower = 40,
    cat = 'WEAPON',
    subCat = 'STAFF',
    passives = {['seraph'] = true}
}

dataSheet['smallDagger'] = {
    name = 'Small Dagger',
    atkPower = 25,
    cat = 'WEAPON',
    subCat = 'DAGGER'
}

dataSheet['bronzeArmor'] = {
    name = 'Bronze Armor',
    defPower = 80,
    cat = 'ARMOR',
    subCat = 'HEAVYARMOR'
}

dataSheet['fireCape'] = {
    name = 'Fire Cape',
    defPower = 25,
    cat = 'ARMOR',
    subCat = 'LIGHTARMOR',
    passives = {['strong:FIRE'] = true }
}

dataSheet['buckler'] = {
    name = 'Buckler',
    defPower = 60,
    cat = 'SHIELD',
    subCat = nil,
}

function equipmentCreator.new(ref)
    
    local data = dataSheet[ref]
    
    local eq = {}
    eq.name = data.name
    eq.atkPower = data.atkPower
    eq.cat = data.cat
    eq.subCat = data.subCat or nil
    eq.atkPower = data.atkPower or 0
    eq.defPower = data.defPower or 0
    eq.passives = data.passives or nil
    eq.weaponWeight = nil
    
    if data.subCat == 'SWORD' or data.subCat == 'DAGGER' or data.subCat == 'FIST' then
        eq.weaponWeight = 'LIGHTWEIGHT'
    elseif data.subCat == 'HAMMER' or data.subCat == 'AXE' or data.subCat == 'SPEAR' then
        eq.weaponWeight = 'HEAVYWEIGHT'
    end
    
    return eq
end

return equipmentCreator