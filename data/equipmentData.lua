local equipmentData = {}

equipmentData['rustedAxe'] = {
    name = 'Rusted Axe',
    atkPower = 80,
    cat = 'WEAPON',
    subCat = 'AXE'
}

equipmentData['leatherFist'] = {
    name = 'Leather Fist',
    atkPower = 40,
    cat = 'WEAPON',
    subCat = 'FIST'
}

equipmentData['woodenStaff'] = {
    name = 'Wooden Staff',
    atkPower = 40,
    cat = 'WEAPON',
    subCat = 'STAFF',
    passives = {['seraph'] = true}
}

equipmentData['smallDagger'] = {
    name = 'Small Dagger',
    atkPower = 25,
    cat = 'WEAPON',
    subCat = 'DAGGER'
}

equipmentData['bronzeArmor'] = {
    name = 'Bronze Armor',
    defPower = 80,
    cat = 'ARMOR',
    subCat = 'HEAVYARMOR'
}

equipmentData['fireCape'] = {
    name = 'Fire Cape',
    defPower = 25,
    cat = 'ARMOR',
    subCat = 'LIGHTARMOR',
    passives = {['strong:FIRE'] = true }
}

equipmentData['buckler'] = {
    name = 'Buckler',
    defPower = 60,
    cat = 'SHIELD',
    subCat = nil,
}

equipmentData['reflector'] = {
    name = 'Reflector',
    defPower = 80,
    cat = 'SHIELD',
    subCat = nil,
    passives = {['counterII'] = true}
}

return equipmentData;