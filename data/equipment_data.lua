local equipment_data = {}

equipment_data['bronze_sword'] = {
    name = 'Bronze Sword',
    stat = {atk = 35},
    type = 'WEAPON',
    class = 'SWORD'
}

equipment_data['rusty_axe'] = {
    name = 'Rusty Axe',
    stat = {atk = 50},
    type = 'WEAPON',
    class = 'AXE'
}

equipment_data['iron_hammer'] = {
    name = 'Iron Hammer',
    stat = {atk = 60},
    type = 'WEAPON',
    class = 'HAMMER',
    passives = {'basher'}
}

equipment_data['bronze_spear'] = {
    name = 'Bronze Spear',
    stat = {atk = 35},
    type = 'WEAPON',
    class = 'SPEAR'
}

equipment_data['iron_knuckles'] = {
    name = 'Iron Knuckles',
    stat = {atk = 15, str = 10},
    type = 'WEAPON',
    class = 'FIST',
}

equipment_data['poisoned_dagger'] = {
    name = 'Poisoned Dagger',
    stat = {atk = 10, agi = 5},
    type = 'WEAPON',
    class = 'DAGGER',
    passives = {'toxicity'}
}

equipment_data['iron_bow'] = {
    name = 'Iron Bow',
    stat = {atk = 25},
    type = 'WEAPON',
    class = 'BOW',
    passives = {'ranged'}
}

equipment_data['fire_staff'] = {
    name = 'Fire Staff',
    stat = {atk = 5},
    type = 'WEAPON',
    class = 'STAFF',
    passives = {'fire_boost'}
}

equipment_data['bronze_armor'] = {
    name = 'Bronze Armor',
    stat = {def = 20},
    type = 'ARMOR',
    class = 'HEAVY_ARMOR'
}

equipment_data['fighter_suit'] = {
    name = 'Fighter Suit',
    stat = {def = 15},
    type = 'ARMOR',
    class = 'LIGHT_ARMOR',
    passives = {'strong:STUN'}
}

equipment_data['fire_cape'] = {
    name = 'Fire Cape',
    stat = {def = 10},
    type = 'ARMOR',
    class = 'ROBE',
    passives = {'strong:FIRE'}
}

equipment_data['thinking_cap'] = {
    name = 'Thinking Cap',
    stat = {def = 8},
    type = 'HEADGEAR',
    class = 'HAT',
    passives = {'strong:SEAL'}
}

equipment_data['steel_helmet'] = {
    name = 'Steel Helmet',
    stat = {def = 18},
    type = 'HEADGEAR',
    class = 'HELMET',
    passives = {'strong:THUNDER', 'strong:WIND'}
}

equipment_data['buckler'] = {
    name = 'Buckler',
    stat = {def = 25},
    type = 'OTHER_EQ',
    class = 'SHIELD'
}

equipment_data['reflektor'] = {
    name = 'Reflektor',
    stat = {def = 85},
    type = 'OTHER_EQ',
    class = 'SHIELD',
    passives = {'counter_II'}
}

equipment_data['feather_greaves'] = {
    name = 'Feather Greaves',
    stat = {def = 5, agi = 15},
    type = 'OTHER_EQ',
    class = 'BOOT',
}

return equipment_data;