local item_data = {}

item_data['potion'] = { 
    id = 101, 
    name = 'Potion', 
    desc = 'Recovers 40 HP.',
    type = 'CONSUMABLE'
}

item_data['master_potion'] = { 
    id = 102, 
    name = 'Master Potion', 
    desc = 'Recovers HP to full.',
    type = 'CONSUMABLE'
}

item_data['mana_potion'] = { 
    id = 103, 
    name = 'Mana Potion', 
    desc = 'Recovers 50 MP.',
    type = 'CONSUMABLE'
}

item_data['antidote'] = { 
    id = 104, 
    name = 'Antidote', 
    desc = 'Cures POISON.',
    type = 'CONSUMABLE'
}

item_data['holy_water'] = { 
    id = 105, 
    name = 'Holy Water', 
    desc = 'Lift CURSE.',
    type = 'CONSUMABLE'
}

item_data['bandage'] = { 
    id = 106, 
    name = 'Bandage', 
    desc = 'Treats WOUND.',
    type = 'CONSUMABLE'
}

item_data['excite_herb'] = { 
    id = 107, 
    name = 'Excite Herb', 
    desc = 'Cures PARALYSIS.',
    type = 'CONSUMABLE'
}

item_data['smelly_herb'] = { 
    id = 108, 
    name = 'Smelly Herb', 
    desc = 'Wake from SLEEP.',
    type = 'CONSUMABLE'
}

item_data['clarity_brew'] = { 
    id = 109, 
    name = 'Clarity Brew', 
    desc = 'Snaps out of CONFUSE.',
    type = 'CONSUMABLE'
}

item_data['elixir_of_life'] = { 
    id = 110, 
    name = 'Elixir of Life', 
    desc = 'Revive from KO.',
    type = 'CONSUMABLE'
}

item_data['bronze_sword'] = {
    id = 301,
    name = 'Bronze Sword',
    stat = {atk = 35},
    type = 'WEAPON',
    class = 'SWORD'
}

item_data['rusty_axe'] = {
    id = 302,
    name = 'Rusty Axe',
    stat = {atk = 50},
    type = 'WEAPON',
    class = 'AXE'
}

item_data['iron_hammer'] = {
    id = 303,
    name = 'Iron Hammer',
    stat = {atk = 6},
    type = 'WEAPON',
    class = 'HAMMER',
    passives = {'basher'}
}

item_data['bronze_spear'] = {
    id = 304,
    name = 'Bronze Spear',
    stat = {atk = 35},
    type = 'WEAPON',
    class = 'SPEAR'
}

item_data['iron_knuckles'] = {
    id = 305,
    name = 'Iron Knuckles',
    stat = {atk = 15, str = 10},
    type = 'WEAPON',
    class = 'FIST',
}

item_data['poisoned_dagger'] = {
    id = 306,
    name = 'Poisoned Dagger',
    stat = {atk = 10, agi = 5},
    type = 'WEAPON',
    class = 'DAGGER',
    passives = {'toxicity'}
}

item_data['iron_bow'] = {
    id = 307,
    name = 'Iron Bow',
    stat = {atk = 25},
    type = 'WEAPON',
    class = 'BOW',
    passives = {'ranged'}
}

item_data['fire_staff'] = {
    id = 308,
    name = 'Fire Staff',
    stat = {atk = 5},
    type = 'WEAPON',
    class = 'STAFF',
    passives = {'fire_boost'}
}

item_data['bronze_armor'] = {
    id = 309,
    name = 'Bronze Armor',
    stat = {def = 20},
    type = 'ARMOR',
    class = 'HEAVY_ARMOR'
}

item_data['fighter_suit'] = {
    id = 310,
    name = 'Fighter Suit',
    stat = {def = 15},
    type = 'ARMOR',
    class = 'LIGHT_ARMOR',
    passives = {'strong:STUN'}
}

item_data['fire_cape'] = {
    id = 311,
    name = 'Fire Cape',
    stat = {def = 10},
    type = 'ARMOR',
    class = 'ROBE',
    passives = {'strong:FIRE'}
}

item_data['thinking_cap'] = {
    id = 312,
    name = 'Thinking Cap',
    stat = {def = 8},
    type = 'HEADGEAR',
    class = 'HAT',
    passives = {'strong:SEAL'}
}

item_data['steel_helmet'] = {
    id = 313,
    name = 'Steel Helmet',
    stat = {def = 18},
    type = 'HEADGEAR',
    class = 'HELMET',
    passives = {'strong:THUNDER', 'strong:WIND'}
}

item_data['buckler'] = {
    id = 314,
    name = 'Buckler',
    stat = {def = 25},
    type = 'OTHER_EQ',
    class = 'SHIELD'
}

item_data['reflektor'] = {
    id = 315,
    name = 'Reflektor',
    stat = {def = 85},
    type = 'OTHER_EQ',
    class = 'SHIELD',
    passives = {'counter_II'}
}

item_data['feather_greaves'] = {
    id = 316,
    name = 'Feather Greaves',
    stat = {def = 5, agi = 15},
    type = 'OTHER_EQ',
    class = 'BOOT',
}

for ref, item in pairs(item_data) do
    item.ref = ref
end

return item_data;