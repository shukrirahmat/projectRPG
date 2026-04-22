local passive_data = {}

passive_data['dual_wield'] = {
    name = 'Dual Wield', 
    desc = 'Attack twice regardless of speed.'
}

passive_data['dual_cast'] = {
    name = 'Dual Cast', 
    desc = 'Magic have 25% chance to be casted twice.'
}

passive_data['fire_boost'] = {
    name = 'Fire Boost', 
    desc = 'Fire magic deals 1.5x more damage'
}
passive_data['ice_boost'] = {
    name = 'Ice Boost', 
    desc = 'Ice magic deals 1.5x more damage'
}
passive_data['wind_boost'] = {
    name = 'Wind Boost', 
    desc = 'Wind magic deals 1.5x more damage'
}
passive_data['thunder_boost'] = {
    name = 'Thunder Boost', 
    desc = 'Thunder magic deals 1.5x more damage'
}
passive_data['light_boost'] = {
    name = 'Light Boost', 
    desc = 'Light magic deals 1.5x more damage'
}
passive_data['dark_boost'] = {
    name = 'Dark Boost', 
    desc = 'Dark magic deals 1.5x more damage'
}
passive_data['drain_boost'] = {
    name = 'Drain Boost', 
    desc = 'Drain magic deals 2x more damage'
}

passive_data['precision_I'] = {
    name = 'Precision I', desc = 'Normal attack have 6% chance to critical hit.'
}

passive_data['precision_II'] = {
    name = 'Precision II', desc = 'Normal attack have 12% chance to critical hit.'
}

passive_data['evasion_I'] = {
    name = 'Evasion I', desc = 'Chance to dodge normal attack becomes 12%.'
}

passive_data['evasion_II'] = {
    name = 'Evasion II', desc = 'Chance to dodge normal attack becomes 25%.'
}

passive_data['arcane_protection'] = {
    name = 'Arcane Protection', 
    desc = 'gain strong resistance to FIRE, ICE, WIND and THUNDER'
}
passive_data['celestial_protection'] = {
    name = 'Celestial Protection', 
    desc = 'gain strong resistance to LIGHT and DARK'
}

passive_data['regenerate'] = {
    name = 'Regenerate', desc = 'Recover some HP each turn'
}

passive_data['last_stand'] = {
    name = 'Last Stand', desc = 'Might stay alive with 1 HP when dealt a killing blow'
}

passive_data['basher'] = {
    name = 'Basher', desc = 'May apply STUN to the enemy with normal attack'
}

passive_data['mage_slayer'] = {
    name = 'Mage Slayer', desc = 'May apply SEAL to the enemy with normal attack'
}

passive_data['sand_master'] = {
    name = 'Sand Master', desc = 'May apply BLIND to the enemy with normal attack'
}

passive_data['toxicity'] = {
    name = 'Toxicity', desc = 'May apply POISON to the enemy with normal attack'
}

passive_data['armor_breaker'] = {
    name = 'armor_breaker', desc = 'May apply FRAIL to the enemy with normal attack'
}

passive_data['crippler'] = {
    name = 'crippler', desc = 'May apply SLOW to the enemy with normal attack'
}

passive_data['counter_I'] = {
    name = 'Counter', desc = '50% chance to counters when being attacked'
}

passive_data['counter_II'] = {
    name = 'Counter', desc = 'Always counters when being attacked'
}

passive_data['ranged'] = {
    name = 'Ranged', desc = 'Normal attack cannot be countered'
}

passive_data['intangible'] = {
    name = 'Intangible', desc = '(Enemy exclusive) Normal attacks only deals 1 damage'
}

passive_data['ethereal'] = {
    name = 'Ethereal', desc = 'Normal attack can damage intangible enemies'
}

passive_data['fire_combo'] = {
    name = 'Fire Combo', desc = 'Normal attack will unleash Scorch I'
}
passive_data['ice_combo'] = {
    name = 'Ice Combo', desc = 'Normal attack will unleash Icicle I'
}
passive_data['wind_combo'] = {
    name = 'Wind Combo', desc = 'Normal attack have 50% chance to unleash Cyclone I'
}
passive_data['thunder_combo'] = {
    name = 'Thunder Combo', desc = 'Normal attack have 50% chance to unleash Lightning I'
}

passive_data['mana_saver'] = {
    name = 'Mana Saver', desc = '25% chance to regain back the MP cost after casting magic'
}

local weapon_mastery = {'SWORD', 'AXE', 'HAMMER', 'FIST', 'SPEAR', 'DAGGER', 'BOW'}

for i, weapon in ipairs(weapon_mastery) do
    passive_data['mastery:'..weapon..''] = {
        name = ''..weapon:sub(1,1):upper() .. weapon:sub(2):lower()..' Mastery',
        desc = '1.5x bonus attack power when equipped with '..weapon:lower()..''
    }
end

local resistances = { 
        'FIRE', 'ICE', 'WIND', 'THUNDER', 'LIGHT', 'DARK', 'AURA', 'DRAIN', 'MANABURN',
        'BLIND', 'SEAL', 'STUN', 'POISON', 'WOUND', 'CURSE', 'SLEEP', 'CONFUSE', 'PARALYSIS',
        'DEATH', 'FRAIL', 'SLOW'
}

for i, res in ipairs(resistances) do
    passive_data['strong:'..res..''] = {name = 'Anti-'..res:sub(1,1):upper() .. res:sub(2):lower()..'', 
        desc = 'Gain strong resistance to '..res..''};
    passive_data['immune:'..res..''] = {name = 'Immune-'..res:sub(1,1):upper() .. res:sub(2):lower()..'', 
        desc = 'Gain immunity to '..res..''};
end


return passive_data