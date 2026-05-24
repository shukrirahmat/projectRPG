local item_data = {}

item_data['potion'] = { 
    id = 1, 
    name = 'Potion', 
    desc = 'Recovers 40 HP.',
    type = 'CONSUMABLE'
}

item_data['master_potion'] = { 
    id = 2, 
    name = 'Master Potion', 
    desc = 'Recovers HP to full.',
    type = 'CONSUMABLE'
}

item_data['mana_potion'] = { 
    id = 3, 
    name = 'Mana Potion', 
    desc = 'Recovers 50 MP.',
    type = 'CONSUMABLE'
}

item_data['antidote'] = { 
    id = 4, 
    name = 'Antidote', 
    desc = 'Cures POISON.',
    type = 'CONSUMABLE'
}

item_data['holy_water'] = { 
    id = 5, 
    name = 'Holy Water', 
    desc = 'Lift CURSE.',
    type = 'CONSUMABLE'
}

item_data['bandage'] = { 
    id = 6, 
    name = 'Bandage', 
    desc = 'Treats WOUND.',
    type = 'CONSUMABLE'
}

item_data['excite_herb'] = { 
    id = 7, 
    name = 'Excite Herb', 
    desc = 'Cures PARALYSIS.',
    type = 'CONSUMABLE'
}

item_data['smelly_herb'] = { 
    id = 8, 
    name = 'Smelly Herb', 
    desc = 'Wake from SLEEP.',
    type = 'CONSUMABLE'
}

item_data['clarity_brew'] = { 
    id = 9, 
    name = 'Clarity Brew', 
    desc = 'Snaps out of CONFUSE.',
    type = 'CONSUMABLE'
}

item_data['elixir_of_life'] = { 
    id = 10, 
    name = 'Elixir of Life', 
    desc = 'Revive from KO.',
    type = 'CONSUMABLE'
}

item_data['bronze_sword'] = {
    name = 'Bronze Sword',
    stat = {atk = 35},
    type = 'WEAPON',
    class = 'SWORD'
}

item_data['rusty_axe'] = {
    name = 'Rusty Axe',
    stat = {atk = 50},
    type = 'WEAPON',
    class = 'AXE'
}

item_data['iron_hammer'] = {
    name = 'Iron Hammer',
    stat = {atk = 60},
    type = 'WEAPON',
    class = 'HAMMER',
    passives = {'basher'}
}

item_data['bronze_spear'] = {
    name = 'Bronze Spear',
    stat = {atk = 35},
    type = 'WEAPON',
    class = 'SPEAR'
}

item_data['iron_knuckles'] = {
    name = 'Iron Knuckles',
    stat = {atk = 15, str = 10},
    type = 'WEAPON',
    class = 'FIST',
}

item_data['poisoned_dagger'] = {
    name = 'Poisoned Dagger',
    stat = {atk = 10, agi = 5},
    type = 'WEAPON',
    class = 'DAGGER',
    passives = {'toxicity'}
}

item_data['iron_bow'] = {
    name = 'Iron Bow',
    stat = {atk = 25},
    type = 'WEAPON',
    class = 'BOW',
    passives = {'ranged'}
}

item_data['fire_staff'] = {
    name = 'Fire Staff',
    stat = {atk = 5},
    type = 'WEAPON',
    class = 'STAFF',
    passives = {'fire_boost'}
}

item_data['bronze_armor'] = {
    name = 'Bronze Armor',
    stat = {def = 20},
    type = 'ARMOR',
    class = 'HEAVY_ARMOR'
}

item_data['fighter_suit'] = {
    name = 'Fighter Suit',
    stat = {def = 15},
    type = 'ARMOR',
    class = 'LIGHT_ARMOR',
    passives = {'strong:STUN'}
}

item_data['fire_cape'] = {
    name = 'Fire Cape',
    stat = {def = 10},
    type = 'ARMOR',
    class = 'ROBE',
    passives = {'strong:FIRE'}
}

item_data['thinking_cap'] = {
    name = 'Thinking Cap',
    stat = {def = 8},
    type = 'HEADGEAR',
    class = 'HAT',
    passives = {'strong:SEAL'}
}

item_data['steel_helmet'] = {
    name = 'Steel Helmet',
    stat = {def = 18},
    type = 'HEADGEAR',
    class = 'HELMET',
    passives = {'strong:THUNDER', 'strong:WIND'}
}

item_data['buckler'] = {
    name = 'Buckler',
    stat = {def = 25},
    type = 'OTHER_EQ',
    class = 'SHIELD'
}

item_data['reflektor'] = {
    name = 'Reflektor',
    stat = {def = 85},
    type = 'OTHER_EQ',
    class = 'SHIELD',
    passives = {'counter_II'}
}

item_data['feather_greaves'] = {
    name = 'Feather Greaves',
    stat = {def = 5, agi = 15},
    type = 'OTHER_EQ',
    class = 'BOOT',
}

for ref, item in pairs(item_data) do
    item.ref = ref
end

return item_data;