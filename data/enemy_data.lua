local enemy_data = {}

local sprite_dimension = 128

enemy_data['goblin'] = {
    lvl = 1,
    hp = 8,
    mp = 0,
    str = 6,
    vit = 1,
    agi = 8,
    sprite_height = sprite_dimension * 0.75,
    gold_drop = 5,
    exp_drop = 12,
    passive_skills = {},
    strong = {},
    immune = {},
    sprite = 'goblin'
}

enemy_data['skeleton'] = {
    lvl = 1,
    hp = 15,
    mp = 0,
    str = 12,
    vit = 4,
    agi = 3,
    sprite_height = sprite_dimension * 1,
    gold_drop = 10,
    exp_drop = 16,
    passive_skills = {},
    strong = {},
    immune = {},
    sprite = 'skeleton'
}

return enemy_data