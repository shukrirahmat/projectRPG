local sprites = require('graphics.sprites')

local ogStats = {}

ogStats[1] = {
    id = 1,
    name = 'ONE',
    lvl = 1,
    hp = 32,
    mp = 12,
    str = 8,
    vit = 7,
    agi = 7,
    skills = {},
    passiveSkills = {},
    status = {},
    totalExp = 0,
}

ogStats[2] = {
    id = 2,
    name = 'TWO',
    lvl = 1,
    hp = 29,
    mp = 15,
    str = 6,
    vit = 6,
    agi = 8,
    skills = {},
    passiveSkills = {},
    status = {},
    totalExp = 0,
}

ogStats[3] = {
    id = 3,
    name = 'THREE',
    lvl = 1,
    hp = 31,
    mp = 13,
    str = 7,
    vit = 8,
    agi = 7,
    skills = {},
    passiveSkills = {},
    status = {},
    totalExp = 0
}

ogStats[4] = {
    id = 4,
    name = 'FOUR',
    lvl = 1,
    hp = 33,
    mp = 11,
    str = 9,
    vit = 8,
    agi = 6,
    skills = {},
    passiveSkills = {},
    status = {},
    totalExp = 0
}

local memberStats = {}

memberStats[1] = {
    id = 1,
    name = 'ONE',
    lvl = 1,
    hp = 32,
    mp = 12,
    str = 8,
    vit = 7,
    agi = 7,
    skills = {'flameI', 'flameII', 'flameIII', 'lightningI', 'lightningII', 'lightningIII', 'healI', 'healII', 'healIII', 'reviveI', 'reviveII'},
    passiveSkills = {},
    status = {},
    totalExp = 0,
    sprite = sprites['member_one']
}

memberStats[2] = {
    id = 2,
    name = 'TWO',
    lvl = 1,
    hp = 29,
    mp = 15,
    str = 6,
    vit = 6,
    agi = 8,
    skills = {'frostI', 'frostII', 'frostIII'},
    passiveSkills = {},
    status = {},
    totalExp = 0,
    sprite = sprites['member_two']
}

memberStats[3] = {
    id = 3,
    name = 'THREE',
    lvl = 1,
    hp = 31,
    mp = 13,
    str = 7,
    vit = 8,
    agi = 7,
    skills = {},
    passiveSkills = {},
    status = {},
    totalExp = 0,
    sprite = sprites['member_three']
}

memberStats[4] = {
    id = 4,
    name = 'FOUR',
    lvl = 1,
    hp = 33,
    mp = 11,
    str = 9,
    vit = 8,
    agi = 6,
    skills = {},
    passiveSkills = {},
    status = {},
    totalExp = 0,
    sprite = sprites['member_four']
}

return memberStats