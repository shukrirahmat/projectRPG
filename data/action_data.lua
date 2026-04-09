local action_data = {}

local function calculate_attack_damage(attacker, target) 

    local damage = math.floor(attacker:get_atk()/2) - math.floor(target:get_def()/3)
    local mod = math.floor(damage * 0.2)
    damage = damage + math.floor(math.random(-mod, mod))
    return math.max(damage, 1)
end

local function calculate_crit_damage(attacker, target)

    local damage = math.floor(attacker:get_atk()/2 * 3) - math.floor(target:get_def()/6)
    local mod = math.floor(damage*0.2)
    damage = damage + math.floor(math.random(-mod, mod))
    return math.max(damage, 1)
end

local function damage_reduction_check(skill, user, target, damage)
    if target.is_defending then
        damage = math.max(math.floor(damage/2), 1)
    end
    
    if skill.type == 'magic' and target.status['BARRIER'] then
        damage = math.max(math.floor(damage/4), 1)
    end

    return damage
end

local function proc_second_attack(user, target, engine)
    local chance = math.floor((user:get_spd() - target:get_spd())/2)
    local success
    success = math.random(1, 100) <= chance

    if success then
        engine.add_combo('second_attack', user, {target})
    end
end

local function check_resistance(element, target)
    if target.immune[element] then return 2 end
    if target.strong[element] then return 1 end
    return 0
end

local function normal_attack(self, user, targets, engine)

    local text = ''..user.name..' attacks!'

    if self.special == 'second_attack' then
        text = ''..user.name..' attacks again!'
    end

    for i, target in ipairs(targets) do
        if not target:is_alive() then goto continue end

        local damage
        local crit = math.random(1, user.crit_rate) == 1
        if crit then
            damage = calculate_crit_damage(user, target)
            engine.log_action(text, 'Critical hit!')
        else
            damage = calculate_attack_damage(user, target)
            engine.log_action(text)
        end

        damage = damage_reduction_check(self, user, target, damage)
        engine.add_effect('damage', user, target, damage)

        if not self.special then
            proc_second_attack(user, target, engine)
        end

        ::continue::
    end
end

local function defend(self, user, targets, engine)

    engine.log_action(''..user.name..' is defending!')

    for i, target in ipairs(targets) do
        if not target:is_alive() then goto continue end

        engine.add_effect('defend', user, target)

        ::continue::
    end
end

local function damage_magic(self, user, targets, engine)

    engine.log_action(''..user.name..' casts '..self.name..'!')

    for i, target in ipairs(targets) do
        if not target:is_alive() then goto continue end

        local var = self.variance or 0.2
        local mod = math.floor(self.base_damage * var)
        local damage = self.base_damage + math.random(-mod, mod)
        local resistance = check_resistance(self.element, target)
        local effect_ref

        if resistance == 2 then 
            effect_ref = 'immune'
        elseif resistance == 1 then
            effect_ref = 'resist'
            damage = math.floor(damage/2)
        else
            effect_ref = 'damage'
        end
        
        damage = damage_reduction_check(self, user, target, damage)
        engine.add_effect(effect_ref, user, target, damage)

        ::continue::
    end
end

action_data['normal_attack'] = {     
    name = 'Normal Attack',
    execute = normal_attack,
    cost = 0,
    aim = 'enemies',
    scope = 'single',
    enemy_animation = {type = 'attack', duration = 1}
}

action_data['second_attack'] = {     
    name = 'Second Attack',
    execute = normal_attack,
    cost = 0,
    aim = 'enemies',
    scope = 'single',
    enemy_animation = {type = 'attack', duration = 1},
    special = 'second_attack'
}

action_data['defend'] = {     
    name = 'Defend',
    execute = defend,
    cost = 0,
    aim = 'allies',
    scope = 'self',
    priority = 2
}

action_data['scorch_I'] = {
    name = 'Scorch I', 
    type = 'magic',
    cost = 2, 
    desc = 'Deals 12~18 FIRE damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'FIRE',
    base_damage = 15
}

action_data['scorch_II'] = {
    name = 'Scorch II', 
    type = 'magic',
    cost = 5, 
    desc = 'Deals 36~54 FIRE damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'FIRE',
    base_damage = 45
}

action_data['scorch_III'] = {
    name = 'Scorch III', 
    type = 'magic',
    cost = 8, 
    desc = 'Deals 96~144 FIRE damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'FIRE',
    base_damage = 120
}

action_data['incinerate'] = {
    name = 'Incinerate', 
    type = 'magic',
    cost = 11, 
    desc = 'Deals 192~288 FIRE damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'FIRE',
    base_damage = 240
}

action_data['inferno_I'] = {
    name = 'Inferno I', 
    type = 'magic',
    cost = 4, 
    desc = 'Deals 10~14 FIRE damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'FIRE',
    base_damage = 12
}

action_data['inferno_II'] = {
    name = 'Inferno II', 
    type = 'magic',
    cost = 7, 
    desc = 'Deals 32~46 FIRE damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'FIRE',
    base_damage = 39
}

action_data['inferno_III'] = {
    name = 'Inferno III', 
    type = 'magic',
    cost = 10, 
    desc = 'Deals 75~111 FIRE damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'FIRE',
    base_damage = 93
}

action_data['icicle_I'] = {
    name = 'Icicle I', 
    type = 'magic',
    cost = 3, 
    desc = 'Deals 16~24 ICE damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'ICE',
    base_damage = 20
}

action_data['icicle_II'] = {
    name = 'Icicle II', 
    type = 'magic',
    cost = 6, 
    desc = 'Deals 52~78 ICE damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'ICE',
    base_damage = 65
}

action_data['icicle_III'] = {
    name = 'Icicle III', 
    type = 'magic',
    cost = 9, 
    desc = 'Deals 124~186 ICE damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'ICE',
    base_damage = 155
}

action_data['blizzard_I'] = {
    name = 'Blizzard I', 
    type = 'magic',
    cost = 3, 
    desc = 'Deals 8~10 ICE damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'ICE',
    base_damage = 9
}

action_data['blizzard_II'] = {
    name = 'Blizzard II', 
    type = 'magic',
    cost = 6, 
    desc = 'Deals 22~32 ICE damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'ICE',
    base_damage = 27
}

action_data['blizzard_III'] = {
    name = 'Blizzard III', 
    type = 'magic',
    cost = 9, 
    desc = 'Deals 58~86 ICE damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'ICE',
    base_damage = 72
}

action_data['permafrost'] = {
    name = 'Permafrost', 
    type = 'magic',
    cost = 12, 
    desc = 'Deals 116~172 ICE damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'ICE',
    base_damage = 144
}

action_data['cyclone_I'] = {
    name = 'Cyclone I', 
    type = 'magic',
    cost = 5, 
    desc = 'Deals 15~21 WIND damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'WIND',
    base_damage = 18
}

action_data['cyclone_II'] = {
    name = 'Cyclone II', 
    type = 'magic',
    cost = 8, 
    desc = 'Deals 44~64 WIND damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'WIND',
    base_damage = 54
}

action_data['cyclone_III'] = {
    name = 'Cyclone III', 
    type = 'magic',
    cost = 11, 
    desc = 'Deals 94~140 WIND damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'WIND',
    base_damage = 117
}

action_data['lightning_I'] = {
    name = 'Lightning I', 
    type = 'magic',
    cost = 5, 
    desc = 'Deals 11~25 THUNDER damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'THUNDER',
    base_damage = 18,
    variance = 0.4
}

action_data['lightning_II'] = {
    name = 'Lightning II', 
    type = 'magic',
    cost = 8, 
    desc = 'Deals 33~75 THUNDER damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'THUNDER',
    base_damage = 54,
    variance = 0.4
}

action_data['lightning_III'] = {
    name = 'Lightning III', 
    type = 'magic',
    cost = 11, 
    desc = 'Deals 71~163 THUNDER damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'THUNDER',
    base_damage = 117,
    variance = 0.4
}

action_data['lumina_I'] = {
    name = 'Lumina I', 
    type = 'magic',
    cost = 4, 
    desc = 'Deals 24~36 LIGHT damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'LIGHT',
    base_damage = 30
}

action_data['lumina_II'] = {
    name = 'Lumina II', 
    type = 'magic',
    cost = 7, 
    desc = 'Deals 72~108 LIGHT damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'LIGHT',
    base_damage = 90
}

action_data['lumina_III'] = {
    name = 'Lumina III', 
    type = 'magic',
    cost = 10, 
    desc = 'Deals 156~234 LIGHT damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'LIGHT',
    base_damage = 195
}

action_data['umbra_I'] = {
    name = 'Umbra I', 
    type = 'magic',
    cost = 4, 
    desc = 'Deals 18~42 DARK damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'DARK',
    base_damage = 30,
    variance = 0.3
}

action_data['umbra_II'] = {
    name = 'Umbra II', 
    type = 'magic',
    cost = 7, 
    desc = 'Deals 54~126 DARK damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'DARK',
    base_damage = 90,
    variance = 0.3
}

action_data['umbra_III'] = {
    name = 'Umbra III', 
    type = 'magic',
    cost = 10, 
    desc = 'Deals 117~273 DARK damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'DARK',
    base_damage = 195,
    variance = 0.4
}

return action_data