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
    hp = 27,
    mp = 112,
    str = 8,
    vit = 7,
    agi = 7,
    skills = {'scorch_I', 'scorch_II', 'scorch_III', 'incinerate', 'inferno_I', 'inferno_II', 'inferno_III', 'death_I', 'death_II', 'death_III'},
    passive_skills = {},
    status = {},
    total_exp = 0,
    sprite = 'one'
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
    skills = {'mana_burn_I', 'mana_burn_II'},
    passive_skills = {},
    status = {},
    total_exp = 0,
    sprite = 'two'
}

party_data.test[3] = {
    id = 3,
    name = 'THREE',
    lvl = 1,
    hp = 26,
    mp = 13,
    str = 7,
    vit = 8,
    agi = 7,
    skills = {'dragonsbane_I', 'dragonsbane_II'},
    passive_skills = {},
    status = {},
    total_exp = 0,
    sprite = 'three'
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
    skills = {'aura_I', 'aura_II', 'aura_III', 'aura_beam_I', 'aura_beam_II', 'aura_charge'},
    passive_skills = {},
    status = {},
    total_exp = 0,
    sprite = 'four'
}

return party_data