local enemy_data = {}

local sprite_dimension = 128

enemy_data['goblin'] = {
    
    ref = 'goblin',
    lvl = 1,
    hp = 110,
    mp = 20,
    str = 12,
    vit = 1,
    agi = 8,
    sprite_height = sprite_dimension * 0.75,
    gold_drop = 5,
    exp_drop = 12,
    passive_skills = {},
    strong = {},
    immune = {},
}

enemy_data['skeleton'] = {
    
    ref = 'skeleton',
    lvl = 1,
    hp = 115,
    mp = 10,
    str = 20,
    vit = 4,
    agi = 3,
    sprite_height = sprite_dimension * 1,
    gold_drop = 10,
    exp_drop = 16,
    passive_skills = {},
    strong = {},
    immune = {},
    species = 'UNDEAD'
}

enemy_data['dragon'] = {
    
    ref = 'dragon',
    lvl = 5,
    hp = 200,
    mp = 20,
    str = 35,
    vit = 12,
    agi = 1,
    sprite_height = sprite_dimension * 1,
    gold_drop = 25,
    exp_drop = 50,
    passive_skills = {},
    strong = {},
    immune = {},
    species = 'DRAGON'
}

return enemy_data