local equipment_data = require('data.equipment_data')

local party_data = {}

party_data.initial = {}

party_data.initial[1] = {
    id = 1,
    name = 'ONE',
    lvl = 1,
    hp = 27,
    mp = 12,
    str = 8,
    vit = 7,
    agi = 7,
    skills = {},
    passive_skills = {},
    status = {},
    total_exp = 0,
    sprite = 'one',
    can_equip = { 'SWORD', 'AXE', 'LIGHT_ARMOR', 'HELMET', 'SHIELD', 'BOOT'}
}

party_data.initial[2] = {
    id = 2,
    name = 'TWO',
    lvl = 1,
    hp = 24,
    mp = 15,
    str = 6,
    vit = 6,
    agi = 8,
    skills = {},
    passive_skills = {},
    status = {},
    total_exp = 0,
    sprite = 'two',
    can_equip = { 'DAGGER', 'STAFF', 'ROBE', 'HAT', 'BOOT' }
}

party_data.initial[3] = {
    id = 3,
    name = 'THREE',
    lvl = 1,
    hp = 25,
    mp = 13,
    str = 7,
    vit = 7,
    agi = 7,
    skills = {},
    passive_skills = {},
    status = {},
    total_exp = 0,
    sprite = 'three',
    can_equip = { 'HAMMER', 'STAFF', 'LIGHT_ARMOR', 'ROBE', 'HELMET', 'BOOT'}
}

party_data.initial[4] = {
    id = 4,
    name = 'FOUR',
    lvl = 1,
    hp = 28,
    mp = 11,
    str = 9,
    vit = 8,
    agi = 6,
    skills = {},
    passive_skills = {},
    status = {},
    total_exp = 0,
    sprite = 'four',
    can_equip = { 'FIST', 'SPEAR', 'LIGHT_ARMOR', 'HELMET', 'SHIELD', 'BOOT'}
}

---------------TEST----------------

party_data.test = {}

party_data.test[1] = {
    id = 1,
    name = 'ONE',
    lvl = 1,
    hp = 27,
    mp = 12,
    str = 8,
    vit = 7,
    agi = 7,
    skills = {},
    passive_skills = {},
    status = {},
    total_exp = 0,
    sprite = 'one',
    weapon = equipment_data['poisoned_dagger'],
    armor = equipment_data['fire_cape'],
    can_equip = { 'SWORD', 'AXE', 'LIGHT_ARMOR', 'HELMET', 'SHIELD', 'BOOT'}
}

party_data.test[2] = {
    id = 2,
    name = 'TWO',
    lvl = 1,
    hp = 24,
    mp = 15,
    str = 6,
    vit = 6,
    agi = 8,
    skills = {},
    passive_skills = {},
    status = {},
    total_exp = 0,
    sprite = 'two',
    armor = equipment_data['fire_cape'],
    can_equip = { 'DAGGER', 'STAFF', 'ROBE', 'HAT', 'BOOT' }
}

party_data.test[3] = {
    id = 3,
    name = 'THREE',
    lvl = 1,
    hp = 25,
    mp = 13,
    str = 7,
    vit = 7,
    agi = 7,
    skills = {},
    passive_skills = {},
    status = {},
    total_exp = 0,
    sprite = 'three',
    headgear = equipment_data['thinking_cap'],
    can_equip = { 'HAMMER', 'STAFF', 'LIGHT_ARMOR', 'ROBE', 'HELMET', 'BOOT'}
}

party_data.test[4] = {
    id = 4,
    name = 'FOUR',
    lvl = 1,
    hp = 28,
    mp = 11,
    str = 9,
    vit = 8,
    agi = 6,
    skills = {},
    passive_skills = {},
    status = {},
    total_exp = 0,
    sprite = 'four',
    other_eq = equipment_data['feather_greaves'],
    can_equip = { 'FIST', 'SPEAR', 'LIGHT_ARMOR', 'HELMET', 'SHIELD', 'BOOT'}
}

return party_data