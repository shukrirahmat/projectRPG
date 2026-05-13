local enemy_data = {}

local sprite_dimension = 128

enemy_data['goblin'] = {
    
    ref = 'goblin',
    lvl = 1,
    hp = 10,
    mp = 20,
    str = 10,
    vit = 1,
    agi = 8,
    sprite_height = sprite_dimension * 0.75,
    gold_drop = 5,
    exp_drop = 12,
    passive_skills = {},
    strong = {},
    immune = {},
    stealable_gold = 15,
    stealable_item = 'potion',
    snatch_rate = 8,
    item_drop = { ['potion'] = 8 }
}

enemy_data['skeleton'] = {
    
    ref = 'skeleton',
    lvl = 2,
    hp = 15,
    mp = 20,
    str = 15,
    vit = 4,
    agi = 3,
    sprite_height = sprite_dimension * 1,
    gold_drop = 8,
    exp_drop = 20,
    passive_skills = {},
    strong = {},
    immune = {},
    species = 'UNDEAD',
    stealable_gold = 20,
    stealable_item = 'holy_water',
    snatch_rate = 4,
}

enemy_data['dragon'] = {
    
    ref = 'dragon',
    lvl = 5,
    hp = 200,
    mp = 50,
    str = 35,
    vit = 12,
    agi = 15,
    sprite_height = sprite_dimension * 1,
    gold_drop = 25,
    exp_drop = 50,
    passive_skills = {'dual_wield', 'counter_III'},
    strong = {},
    immune = {},
    species = 'DRAGON',
    stealable_gold = 25,
    stealable_item = 'elixir_of_life',
    snatch_rate = 20,
}

return enemy_data