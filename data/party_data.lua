local item_data = require('data.item_data')

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
    can_equip = { ['SWORD'] = true, ['AXE'] = true, ['LIGHT_ARMOR'] = true, ['HELMET'] = true, ['SHIELD'] = true, ['BOOT'] = true}
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
    can_equip = { ['DAGGER'] = true, ['STAFF'] = true, ['ROBE'] = true, ['HAT'] = true, ['BOOT'] = true }
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
    can_equip = { ['HAMMER'] = true, ['STAFF'] = true, ['LIGHT_ARMOR'] = true, ['ROBE'] = true, ['HELMET'] = true, ['BOOT'] = true}
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
    can_equip = { ['FIST'] = true, ['SPEAR'] = true, ['LIGHT_ARMOR'] = true, ['HELMET'] = true, ['SHIELD'] = true, ['BOOT'] = true}
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
    can_equip = { ['SWORD'] = true, ['AXE'] = true, ['LIGHT_ARMOR'] = true, ['HELMET'] = true, ['SHIELD'] = true, ['BOOT'] = true}
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
    can_equip = { ['DAGGER'] = true, ['STAFF'] = true, ['ROBE'] = true, ['HAT'] = true, ['BOOT'] = true }
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
    can_equip = { ['HAMMER'] = true, ['STAFF'] = true, ['LIGHT_ARMOR'] = true, ['ROBE'] = true, ['HELMET'] = true, ['BOOT'] = true}
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
    can_equip = { ['FIST'] = true, ['SPEAR'] = true, ['LIGHT_ARMOR'] = true, ['HELMET'] = true, ['SHIELD'] = true, ['BOOT'] = true}
}

return party_data