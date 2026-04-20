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
    sprite = 'one'
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
    sprite = 'two'
}

party_data.initial[3] = {
    id = 3,
    name = 'THREE',
    lvl = 1,
    hp = 25,
    mp = 13,
    str = 7,
    vit = 8,
    agi = 7,
    skills = {},
    passive_skills = {},
    status = {},
    total_exp = 0,
    sprite = 'three'
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
    sprite = 'four'
}

---------------TEST----------------

party_data.test = {}

party_data.test[1] = {
    id = 1,
    name = 'ONE',
    lvl = 1,
    hp = 127,
    mp = 112,
    str = 58,
    vit = 7,
    agi = 7,
    skills = {},
    passive_skills = {'basher', 'armor_breaker', 'dual_wield', 'regenerate', 'last_stand'},
    status = {},
    total_exp = 0,
    sprite = 'one'
}

party_data.test[2] = {
    id = 2,
    name = 'TWO',
    lvl = 1,
    hp = 124,
    mp = 115,
    str = 56,
    vit = 6,
    agi = 8,
    skills = {'lightning_I'},
    passive_skills = {'mage_slayer', 'crippler', 'dual_wield', 'dual_cast', 'arcane_protection'},
    status = {},
    immune = {},
    total_exp = 0,
    sprite = 'two'
}

party_data.test[3] = {
    id = 3,
    name = 'THREE',
    lvl = 1,
    hp = 126,
    mp = 113,
    str = 7,
    vit = 8,
    agi = 7,
    skills = {},
    passive_skills = {'arcane_protection', 'sand_master', 'dual_wield'},
    status = {},
    total_exp = 0,
    sprite = 'three'
}

party_data.test[4] = {
    id = 4,
    name = 'FOUR',
    lvl = 1,
    hp = 128,
    mp = 111,
    str = 9,
    vit = 8,
    agi = 6,
    skills = {},
    passive_skills = {'arcane_protection'},
    status = {},
    total_exp = 0,
    sprite = 'four'
}

return party_data