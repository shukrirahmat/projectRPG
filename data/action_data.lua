local action_data = {}

----HELPERS---

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
    if target.is_defending and not target:cannot_act() then
        damage = math.max(math.floor(damage/2), 1)
    end

    if skill.type == 'Magic' and target.status['BARRIER'] then
        damage = math.max(math.floor(damage/2), 1)
    end

    return damage
end

local function healing_reduction_check(user, target, amount)
    if target.status['WOUND'] then
        amount = math.floor(amount * 0.5)
    end

    return math.min(amount, target.max_hp - target.current_hp)
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

local function normal_attack_modifier(skill, user, target, damage)

    local resist = nil

    if skill.special == 'quick_strike' then
        damage = math.max(1, math.floor(damage * 0.5))
    end
    
    if skill.special == 'elemental_attack' then
        local resistance = check_resistance(skill.element, target)
        if resistance == 2 then 
            resist = 'immune'
        elseif resistance == 1 then
            damage = math.max(1, math.floor(damage * 0.5))
            resist = 'resist'
        else
            damage = math.floor(damage * skill.damage_ratio)
        end        
    end

    return { damage = damage, resist = resist }
end

local function attack_miss(user, target)
    if user.status['BLIND'] then
        local roll = math.random(1, 100)
        if roll <= 70 then
            return true
        end
    end

    if target.dodge_rate ~= 0 then
        local roll = math.random(1, target.dodge_rate)
        if roll == 1 then
            return true
        end
    end

    return false
end

----EXECUTION----

local function normal_attack(self, user, targets, engine)

    local text = ''..user.name..' attacks!'

    if self.special then
        if self.special == 'elemental_attack' then
            text = ''..user.name..' used '..self.name..'!'
        else
            text = ''..user.name..' '..self.special_text..''
        end
    end

    for i, target in ipairs(targets) do
        if not target:is_alive() then goto continue end

        if not user.is_focused and attack_miss(user, target) then
            engine.log_action(text)
            engine.add_effect('missed', user, target)
            if not self.special then
                proc_second_attack(user, target, engine)
            end
            goto continue
        end


        local damage
        local crit = math.random(1, user.crit_rate) == 1
        if crit then
            damage = calculate_crit_damage(user, target)
            engine.log_action(text, 'Critical hit!')
        else
            damage = calculate_attack_damage(user, target)
            engine.log_action(text)
        end

        local modifier = normal_attack_modifier(self, user, target, damage)
        
        if not modifier.resist then
            local damage = damage_reduction_check(self, user, target, modifier.damage)
            engine.add_effect('damage', user, target, damage)
        elseif modifier.resist == 'resist' then
            local damage = damage_reduction_check(self, user, target, modifier.damage)
            engine.add_effect('resist', user, target, damage)
        elseif modifier.resist == 'immune' then
            engine.add_effect('immune', user, target)
        end

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

local function skill_cancelled(self, user, targets, engine, var)

    if var.to_use.type == 'Magic' then
        engine.log_action(''..user.name..' tried to cast '..var.to_use.name..'.')
    elseif var.to_use.type == 'Tech' then
        engine.log_action(''..user.name..' tried to use '..var.to_use.name..'.')
    end

    local target = targets[1]
    engine.add_effect('skill_cancelled', user, target)
end

local function stunned(self, user, targets, engine)
    engine.log_action(''..user.name..' is stunned and could not move!')
    engine.add_effect('empty', user, user)
end

local function paralyzed(self, user, targets, engine)
    engine.log_action(""..user.name.."'s action disrupted by paralysis!")
    engine.add_effect('empty', user, user)
end

local function sleeping(self, user, targets, engine)
    engine.log_action(''..user.name..' is sleeping soundly!')
    engine.add_effect('empty', user, user)
end

local function confused_idle(self, user, targets, engine)

    local text_list = {
        'is rolling on the ground laughing.',
        'is dancing happily.',
        'is crying for no apparent reason.',
        'pretends to be dead.',
        "picks at it's nose.",
    }

    local text_roll = math.random(1, #text_list)
    engine.log_action(''..user.name..' '..text_list[text_roll]..'')
    engine.add_effect('empty', user, user)
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

local function use_aura(self, user, targets, engine)
    engine.log_action(''..user.name..' used '..self.name..'!')

    for i, target in ipairs(targets) do
        if not target:is_alive() then goto continue end

        local base_damage = math.floor(user.str * self.aura_ratio)
        local mod = math.floor(base_damage * 0.2)
        local damage = base_damage + math.random(-mod, mod)

        if user.is_aura_charged then
            damage = math.floor(damage * 2.5)
        end

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
        engine.add_effect(effect_ref, user, target, math.max(1,damage))

        ::continue::
    end
end

local function aura_charge(self, user, targets, engine)
    engine.log_action(""..user.name.." charged it's aura!")

    local target = targets[1]
    engine.add_effect('aura_charge', user, target)
end

local function life_drain(self, user, targets, engine)

    engine.log_action(''..user.name..' casts '..self.name..'!')

    for i, target in ipairs(targets) do
        if not target:is_alive() then goto continue end

        local base_damage = self.base_damage
        local mod = math.floor(base_damage * 0.2)
        local damage = base_damage + math.random(-mod, mod)

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

        if effect_ref ~= 'immune' then
            local heal_amount = math.min(damage, target.current_hp)
            heal_amount = healing_reduction_check(user, user, heal_amount)
            engine.add_effect('recover', user, user, heal_amount)
        end

        ::continue::
    end
end

local function mana_burn(self, user, targets, engine)

    engine.log_action(''..user.name..' casts '..self.name..'!')

    for i, target in ipairs(targets) do
        if not target:is_alive() then goto continue end

        local base_damage = self.base_damage
        local mod = math.floor(base_damage * 0.2)
        local damage = base_damage + math.random(-mod, mod)
        local resistance = check_resistance(self.element, target)
        local effect_ref

        if resistance == 2 then 
            effect_ref = 'immune'
        elseif resistance == 1 then
            effect_ref = 'mp_resist'
            damage = math.floor(damage/2)
        else
            effect_ref = 'mp_damage'
        end

        damage = damage_reduction_check(self, user, target, damage)
        engine.add_effect(effect_ref, user, target, damage)

        ::continue::
    end
end

local function dragonsbane(self, user, targets, engine)

    engine.log_action(''..user.name..' casts '..self.name..'!')

    for i, target in ipairs(targets) do
        if not target:is_alive() then goto continue end

        local damage;
        if target.species and target.species == 'DRAGON' then
            local mod = math.floor(self.base_damage * 0.2)
            damage = self.base_damage + math.random(-mod, mod)
        else
            engine.add_effect('immune', user, target, damage)
            goto continue
        end

        damage = damage_reduction_check(self, user, target, damage)
        engine.add_effect('damage', user, target, damage)

        ::continue::
    end
end

local function exorcise(self, user, targets, engine)

    engine.log_action(''..user.name..' casts '..self.name..'!')

    for i, target in ipairs(targets) do
        if not target:is_alive() then goto continue end

        if target.species and target.species == 'UNDEAD' then
            local roll = math.random(1, 100)
            if roll <= self.accuracy then
                engine.add_effect('kill', user, target)
            else
                engine.add_effect('missed', user, target)
            end
        else
            engine.add_effect('immune', user, target)
        end

        ::continue::
    end
end

local function death(self, user, targets, engine)

    engine.log_action(''..user.name..' casts '..self.name..'!')

    for i, target in ipairs(targets) do
        if not target:is_alive() then goto continue end

        local resistance = check_resistance(self.element, target)
        local accuracy = self.accuracy
        local resist = false

        if resistance == 2 then 
            engine.add_effect('immune', user, target)
            goto continue
        elseif resistance == 1 then
            accuracy = math.floor(accuracy / 2)
            resist = true
        end

        local roll = math.random(1, 100)
        if roll <= accuracy then
            engine.add_effect('kill', user, target)
        elseif resist then
            engine.add_effect('missed_resist', user, target)
        else
            engine.add_effect('missed', user, target)
        end

        ::continue::
    end
end

local function status_effect(self, user, targets, engine)

    engine.log_action(''..user.name..' casts '..self.name..'!')

    for i, target in ipairs(targets) do
        if not target:is_alive() then goto continue end

        local resistance = check_resistance(self.element, target)
        local accuracy = self.accuracy
        local resist = false

        if resistance == 2 then 
            engine.add_effect('immune', user, target)
            goto continue
        elseif resistance == 1 then
            accuracy = math.floor(accuracy / 2)
            resist = true
        end

        local roll = math.random(1, 100)
        if roll <= accuracy then
            engine.add_effect('add_status', user, target, self.element)
        elseif resist then
            engine.add_effect('missed_resist', user, target)
        else
            engine.add_effect('missed', user, target)
        end

        ::continue::
    end
end

local function heal(self, user, targets, engine)

    engine.log_action(''..user.name..' casts '..self.name..'!')

    if self.scope == 'single' and targets[1].is_dead then
        engine.add_effect('nothing_happened', user, targets[1])
        return
    end

    for i, target in ipairs(targets) do
        if target.is_dead then goto continue end

        local base_amount = self.heal_amount
        local mod = math.floor(base_amount * 0.2)
        local heal_amount = base_amount + math.random(-mod, mod)

        heal_amount = healing_reduction_check(user, target, heal_amount)
        engine.add_effect('recover', user, target, heal_amount)

        ::continue::
    end
end

local function revive(self, user, targets, engine)

    engine.log_action(''..user.name..' casts '..self.name..'!')

    if self.scope == 'single' and targets[1]:is_alive() then
        engine.add_effect('immune', user, targets[1])
        return
    end

    for i, target in ipairs(targets) do
        if target:is_alive() then goto continue end

        local ratio = self.revive_ratio
        local hp_amount = math.floor(target.max_hp * ratio)

        engine.add_effect('revive', user, target, hp_amount)

        ::continue::
    end
end

local function cure_status(self, user, targets, engine)

    engine.log_action(''..user.name..' casts '..self.name..'!')

    if self.scope == 'single' and targets[1].is_dead then
        engine.add_effect('nothing_happened', user, targets[1])
        return
    end

    for i, target in ipairs(targets) do
        if target.is_dead then goto continue end

        local curing;
        for i, status in ipairs(self.statuses) do
            if target.status[status] then
                engine.add_effect('clear_status', user, target, status)
                curing = true
            end
        end

        if not curing and self.scope == 'single' then
            engine.add_effect('immune', user, target)
        end

        ::continue::
    end
end

local function cleanse(self, user, targets, engine)

    engine.log_action(''..user.name..' casts '..self.name..'!')

    if self.scope == 'single' and targets[1].is_dead then
        engine.add_effect('nothing_happened', user, targets[1])
        return
    end

    for i, target in ipairs(targets) do
        if target.is_dead then goto continue end

        engine.add_effect('cleanse', user, target)

        ::continue::
    end
end

local function add_buff(self, user, targets, engine)

    engine.log_action(''..user.name..' casts '..self.name..'!')

    if self.scope == 'single' and targets[1].is_dead then
        engine.add_effect('nothing_happened', user, targets[1])
        return
    end

    for i, target in ipairs(targets) do
        if target.is_dead then goto continue end

        engine.add_effect('add_buff', user, target, self.element)

        ::continue::
    end
end

local function focus(self, user, targets, engine)

    engine.log_action(''..user.name..' increases focus!')

    for i, target in ipairs(targets) do
        if target.is_dead then goto continue end

        engine.add_effect('focus', user, target)

        ::continue::
    end
end

---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------

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
    special = 'second_attack',
    special_text = 'attacks again!'
}

action_data['defend'] = {     
    name = 'Defend',
    execute = defend,
    cost = 0,
    aim = 'allies',
    scope = 'self',
    priority = 2
}

action_data['skill_cancelled'] = {     
    name = 'Skill Cancelled',
    execute = skill_cancelled,
    cost = 0,
    aim = 'allies',
    scope = 'self',
}

action_data['stunned'] = {
    execute = stunned
}

action_data['paralyzed'] = {
    execute = paralyzed
}

action_data['confused_idle'] = {
    execute = confused_idle
}

action_data['confused_attack'] = {     
    name = 'Confused Attack',
    execute = normal_attack,
    cost = 0,
    aim = 'enemies',
    scope = 'single',
    enemy_animation = {type = 'attack', duration = 1},
    special = 'confused_attack',
    special_text = 'attacks while being confused!'
}

action_data['sleeping'] = {
    execute = sleeping
}

action_data['scorch_I'] = {
    name = 'Scorch I', 
    type = 'Magic',
    cost = 2, 
    desc = 'Deals 12~18 FIRE damage to one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'FIRE',
    base_damage = 15
}

action_data['scorch_II'] = {
    name = 'Scorch II', 
    type = 'Magic',
    cost = 5, 
    desc = 'Deals 36~54 FIRE damage to one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'FIRE',
    base_damage = 45
}

action_data['scorch_III'] = {
    name = 'Scorch III', 
    type = 'Magic',
    cost = 8, 
    desc = 'Deals 96~144 FIRE damage to one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'FIRE',
    base_damage = 120
}

action_data['incinerate'] = {
    name = 'Incinerate', 
    type = 'Magic',
    cost = 11, 
    desc = 'Deals 192~288 FIRE damage to one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'FIRE',
    base_damage = 240
}

action_data['inferno_I'] = {
    name = 'Inferno I', 
    type = 'Magic',
    cost = 4, 
    desc = 'Deals 10~14 FIRE damage to all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'FIRE',
    base_damage = 12
}

action_data['inferno_II'] = {
    name = 'Inferno II', 
    type = 'Magic',
    cost = 7, 
    desc = 'Deals 32~46 FIRE damage to all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'FIRE',
    base_damage = 39
}

action_data['inferno_III'] = {
    name = 'Inferno III', 
    type = 'Magic',
    cost = 10, 
    desc = 'Deals 75~111 FIRE damage to all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'FIRE',
    base_damage = 93
}

action_data['icicle_I'] = {
    name = 'Icicle I', 
    type = 'Magic',
    cost = 3, 
    desc = 'Deals 16~24 ICE damage to one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'ICE',
    base_damage = 20
}

action_data['icicle_II'] = {
    name = 'Icicle II', 
    type = 'Magic',
    cost = 6, 
    desc = 'Deals 52~78 ICE damage to one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'ICE',
    base_damage = 65
}

action_data['icicle_III'] = {
    name = 'Icicle III', 
    type = 'Magic',
    cost = 9, 
    desc = 'Deals 124~186 ICE damage to one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'ICE',
    base_damage = 155
}

action_data['blizzard_I'] = {
    name = 'Blizzard I', 
    type = 'Magic',
    cost = 3, 
    desc = 'Deals 8~10 ICE damage to all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'ICE',
    base_damage = 9
}

action_data['blizzard_II'] = {
    name = 'Blizzard II', 
    type = 'Magic',
    cost = 6, 
    desc = 'Deals 22~32 ICE damage to all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'ICE',
    base_damage = 27
}

action_data['blizzard_III'] = {
    name = 'Blizzard III', 
    type = 'Magic',
    cost = 9, 
    desc = 'Deals 58~86 ICE damage to all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'ICE',
    base_damage = 72
}

action_data['permafrost'] = {
    name = 'Permafrost', 
    type = 'Magic',
    cost = 12, 
    desc = 'Deals 116~172 ICE damage to all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'ICE',
    base_damage = 144
}

action_data['cyclone_I'] = {
    name = 'Cyclone I', 
    type = 'Magic',
    cost = 5, 
    desc = 'Deals 15~21 WIND damage to all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'WIND',
    base_damage = 18
}

action_data['cyclone_II'] = {
    name = 'Cyclone II', 
    type = 'Magic',
    cost = 8, 
    desc = 'Deals 44~64 WIND damage to all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'WIND',
    base_damage = 54
}

action_data['cyclone_III'] = {
    name = 'Cyclone III', 
    type = 'Magic',
    cost = 11, 
    desc = 'Deals 94~140 WIND damage to all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'WIND',
    base_damage = 117
}

action_data['lightning_I'] = {
    name = 'Lightning I', 
    type = 'Magic',
    cost = 5, 
    desc = 'Deals 11~25 THUNDER damage to all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'THUNDER',
    base_damage = 18,
    variance = 0.4
}

action_data['lightning_II'] = {
    name = 'Lightning II', 
    type = 'Magic',
    cost = 8, 
    desc = 'Deals 33~75 THUNDER damage to all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'THUNDER',
    base_damage = 54,
    variance = 0.4
}

action_data['lightning_III'] = {
    name = 'Lightning III', 
    type = 'Magic',
    cost = 11, 
    desc = 'Deals 71~163 THUNDER damage to all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'THUNDER',
    base_damage = 117,
    variance = 0.4
}

action_data['lumina_I'] = {
    name = 'Lumina I', 
    type = 'Magic',
    cost = 4, 
    desc = 'Deals 24~36 LIGHT damage to one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'LIGHT',
    base_damage = 30
}

action_data['lumina_II'] = {
    name = 'Lumina II', 
    type = 'Magic',
    cost = 7, 
    desc = 'Deals 72~108 LIGHT damage to one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'LIGHT',
    base_damage = 90
}

action_data['lumina_III'] = {
    name = 'Lumina III', 
    type = 'Magic',
    cost = 10, 
    desc = 'Deals 156~234 LIGHT damage to one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'LIGHT',
    base_damage = 195
}

action_data['umbra_I'] = {
    name = 'Umbra I', 
    type = 'Magic',
    cost = 4, 
    desc = 'Deals 18~42 DARK damage to one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'DARK',
    base_damage = 30,
    variance = 0.3
}

action_data['umbra_II'] = {
    name = 'Umbra II', 
    type = 'Magic',
    cost = 7, 
    desc = 'Deals 54~126 DARK damage to one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'DARK',
    base_damage = 90,
    variance = 0.3
}

action_data['umbra_III'] = {
    name = 'Umbra III', 
    type = 'Magic',
    cost = 10, 
    desc = 'Deals 117~273 DARK damage to one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'DARK',
    base_damage = 195,
    variance = 0.4
}

action_data['aura_I'] = {
    name = 'Aura I', 
    type = 'Tech',
    cost = 0, 
    desc = "Deals damage to all enemies using 10% of own's strength.",
    aim = 'enemies',
    scope = 'all',
    execute = use_aura,
    element = 'AURA',
    aura_ratio = 0.1
}

action_data['aura_II'] = {
    name = 'Aura II', 
    type = 'Tech',
    cost = 0, 
    desc = "Deals damage to all enemies using 25% of own's strength.",
    aim = 'enemies',
    scope = 'all',
    execute = use_aura,
    element = 'AURA',
    aura_ratio = 0.25
}

action_data['aura_III'] = {
    name = 'Aura III', 
    type = 'Tech',
    cost = 0, 
    desc = "Deals damage to all enemies using 50% of own's strength.",
    aim = 'enemies',
    scope = 'all',
    execute = use_aura,
    element = 'AURA',
    aura_ratio = 0.5
}

action_data['aura_beam_I'] = {
    name = 'Aura Beam I', 
    type = 'Tech',
    cost = 0, 
    desc = "Deals damage to one enemy using 80% of own's strength.",
    aim = 'enemies',
    scope = 'single',
    execute = use_aura,
    element = 'AURA',
    aura_ratio = 0.8
}

action_data['aura_beam_II'] = {
    name = 'Aura Beam II', 
    type = 'Tech',
    cost = 0, 
    desc = "Deals damage to one enemy using 120% of own's strength.",
    aim = 'enemies',
    scope = 'single',
    execute = use_aura,
    element = 'AURA',
    aura_ratio = 1.2
}

action_data['aura_charge'] = {
    name = 'Aura Charge', 
    type = 'Tech',
    cost = 5, 
    desc = 'Next aura skill will deal x2.5 more damage',
    aim = 'allies',
    scope = 'self',
    execute = aura_charge,
}

action_data['life_drain_I'] = {
    name = 'Life Drain I', 
    type = 'Magic',
    cost = 5, 
    desc = 'Deals 28~42 damage to one enemy and recovers the same amount.',
    aim = 'enemies',
    scope = 'single',
    execute = life_drain,
    element = 'DRAIN',
    base_damage = 35,
}

action_data['life_drain_II'] = {
    name = 'Life Drain II', 
    type = 'Magic',
    cost = 8, 
    desc = 'Deals 80~120 damage to one enemy and recovers the same amount.',
    aim = 'enemies',
    scope = 'single',
    execute = life_drain,
    element = 'DRAIN',
    base_damage = 100,
}

action_data['mana_burn_I'] = {
    name = 'Mana Burn I', 
    type = 'Magic',
    cost = 2, 
    desc = 'Reduce 4~6 MP from all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = mana_burn,
    element = 'MANABURN',
    base_damage = 5,
}

action_data['mana_burn_II'] = {
    name = 'Mana Burn II', 
    type = 'Magic',
    cost = 5, 
    desc = 'Reduce 12~18 MP from all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = mana_burn,
    element = 'MANABURN',
    base_damage = 15,
}

action_data['dragonsbane_I'] = {
    name = "Dragonsbane I", 
    type = 'Magic',
    cost = 4, 
    desc = 'Deals 80~120 damage. Only works on dragons.',
    aim = 'enemies',
    scope = 'single',
    execute = dragonsbane,
    base_damage = 100
}

action_data['dragonsbane_II'] = {
    name = "Dragonsbane II", 
    type = 'Magic',
    cost = 8, 
    desc = 'Deals 180~270 damage. Only works on dragons.',
    aim = 'enemies',
    scope = 'single',
    execute = dragonsbane,
    base_damage = 225
}

action_data['exorcise_I'] = {
    name = 'Exorcise I', 
    type = 'Magic',
    cost = 3, 
    desc = '80% chance to instantly kill one undead enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = exorcise,
    accuracy = 80
}

action_data['exorcise_II'] = {
    name = 'Exorcise II', 
    type = 'Magic',
    cost = 5, 
    desc = '80% chance to instantly kill all undead enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = exorcise,
    accuracy = 80
}

action_data['death_I'] = {
    name = 'Death I', 
    type = 'Magic',
    cost = 5, 
    desc = '25% chance to instantly kill one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = death,
    element = 'DEATH',
    accuracy = 25
}

action_data['death_II'] = {
    name = 'Death II', 
    type = 'Magic',
    cost = 10, 
    desc = '25% chance to instantly kill all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = death,
    element = 'DEATH',
    accuracy = 25
}

action_data['death_III'] = {
    name = 'Death III', 
    type = 'Magic',
    cost = 15, 
    desc = '50% chance to instantly kill all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = death,
    element = 'DEATH',
    accuracy = 50
}

action_data['sandstorm_I'] = {
    name = 'Sandstorm I', 
    type = 'Magic',
    cost = 3, 
    desc = '50% chance to apply BLIND to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = status_effect,
    element = 'BLIND',
    accuracy = 50
}

action_data['sandstorm_II'] = {
    name = 'Sandstorm II', 
    type = 'Magic',
    cost = 5, 
    desc = '80% chance to apply BLIND to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = status_effect,
    element = 'BLIND',
    accuracy = 80
}

action_data['spellseal_I'] = {
    name = 'Spellseal I', 
    type = 'Magic',
    cost = 3, 
    desc = '50% chance to apply SEAL to all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = status_effect,
    element = 'SEAL',
    accuracy = 50
}

action_data['spellseal_II'] = {
    name = 'Spellseal II', 
    type = 'Magic',
    cost = 5, 
    desc = '80% chance to apply SEAL to all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = status_effect,
    element = 'SEAL',
    accuracy = 80
}

action_data['tremor_I'] = {
    name = 'Tremor I', 
    type = 'Magic',
    cost = 4, 
    desc = '40% chance to STUN all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = status_effect,
    element = 'STUN',
    accuracy = 30
}

action_data['tremor_II'] = {
    name = 'Tremor II', 
    type = 'Magic',
    cost = 6, 
    desc = '70% chance to STUN all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = status_effect,
    element = 'STUN',
    accuracy = 60
}

action_data['rupture_I'] = {
    name = 'Rupture I', 
    type = 'Magic',
    cost = 3, 
    desc = '50% chance to WOUND all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = status_effect,
    element = 'WOUND',
    accuracy = 50
}

action_data['rupture_II'] = {
    name = 'Rupture II', 
    type = 'Magic',
    cost = 5, 
    desc = '80% chance to WOUND all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = status_effect,
    element = 'WOUND',
    accuracy = 80
}

action_data['toxin_I'] = {
    name = 'Toxin I', 
    type = 'Magic',
    cost = 2, 
    desc = '80% chance to POISON one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = status_effect,
    element = 'POISON',
    accuracy = 80
}

action_data['toxin_II'] = {
    name = 'Toxin II', 
    type = 'Magic',
    cost = 4, 
    desc = '80% chance to POISON all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = status_effect,
    element = 'POISON',
    accuracy = 80
}

action_data['hex_I'] = {
    name = 'Hex I', 
    type = 'Magic',
    cost = 3, 
    desc = '60% chance to put a CURSE on one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = status_effect,
    element = 'CURSE',
    accuracy = 80
}

action_data['hex_II'] = {
    name = 'Hex II', 
    type = 'Magic',
    cost = 5, 
    desc = '60% chance to put a CURSE on all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = status_effect,
    element = 'CURSE',
    accuracy = 80
}

action_data['paralyze_I'] = {
    name = 'Paralyze I', 
    type = 'Magic',
    cost = 3, 
    desc = '80% chance to cause PARALYSIS to one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = status_effect,
    element = 'PARALYSIS',
    accuracy = 80
}

action_data['paralyze_II'] = {
    name = 'Paralyze II', 
    type = 'Magic',
    cost = 5, 
    desc = '80% chance to cause PARALYSIS to all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = status_effect,
    element = 'PARALYSIS',
    accuracy = 80
}

action_data['slumber_I'] = {
    name = 'Slumber I', 
    type = 'Magic',
    cost = 3, 
    desc = '60% chance to put one enemy to SLEEP.',
    aim = 'enemies',
    scope = 'single',
    execute = status_effect,
    element = 'SLEEP',
    accuracy = 60
}

action_data['slumber_II'] = {
    name = 'Slumber II', 
    type = 'Magic',
    cost = 5, 
    desc = '60% chance to put all enemies to SLEEP.',
    aim = 'enemies',
    scope = 'all',
    execute = status_effect,
    element = 'SLEEP',
    accuracy = 60
}

action_data['mindblast_I'] = {
    name = 'Mindblast I', 
    type = 'Magic',
    cost = 3, 
    desc = '60% chance to CONFUSE one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = status_effect,
    element = 'CONFUSE',
    accuracy = 60
}

action_data['mindblast_II'] = {
    name = 'Mindblast II', 
    type = 'Magic',
    cost = 5, 
    desc = '60% chance to CONFUSE all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = status_effect,
    element = 'CONFUSE',
    accuracy = 60
}

action_data['heal_I'] = {
    name = 'Heal I', 
    type = 'Magic',
    cost = 2, 
    desc = 'Recover 32~48 HP to one ally',
    aim = 'allies',
    scope = 'single',
    execute = heal,
    heal_amount = 40
}

action_data['heal_II'] = {
    name = 'Heal II', 
    type = 'Magic',
    cost = 5, 
    desc = 'Recover 80~120 HP to one ally',
    aim = 'allies',
    scope = 'single',
    execute = heal,
    heal_amount = 100
}

action_data['heal_III'] = {
    name = 'Heal III', 
    type = 'Magic',
    cost = 8, 
    desc = 'Recover 200~300 HP to one ally',
    aim = 'allies',
    scope = 'single',
    execute = heal,
    heal_amount = 250
}

action_data['final_heal'] = {
    name = 'Final Heal', 
    type = 'Magic',
    cost = 12, 
    desc = 'Recover 640~960 HP to one ally',
    aim = 'allies',
    scope = 'single',
    execute = heal,
    heal_amount = 800
}

action_data['all_heal_I'] = {
    name = 'All Heal I', 
    type = 'Magic',
    cost = 15, 
    desc = 'Recover 64~96 HP to all allies',
    aim = 'allies',
    scope = 'all',
    execute = heal,
    heal_amount = 80
}

action_data['all_heal_II'] = {
    name = 'All Heal II', 
    type = 'Magic',
    cost = 25, 
    desc = 'Recover 160~240 HP to all allies',
    aim = 'allies',
    scope = 'all',
    execute = heal,
    heal_amount = 200
}

action_data['revive_I'] = {
    name = 'Revive I', 
    type = 'Magic',
    cost = 25, 
    desc = 'Revive one dead ally at 25% HP',
    aim = 'allies',
    scope = 'dead',
    execute = revive,
    revive_ratio = 0.25
}

action_data['revive_II'] = {
    name = 'Revive II', 
    type = 'Magic',
    cost = 50, 
    desc = 'Revive one dead ally to full HP',
    aim = 'allies',
    scope = 'dead',
    execute = revive,
    revive_ratio = 1
}

action_data['neutralize_I'] = {
    name = 'Neutralize I', 
    type = 'Magic',
    cost = 1, 
    desc = 'Cures one ally from poison',
    aim = 'allies',
    scope = 'single',
    execute = cure_status,
    statuses = {'POISON'}
}

action_data['neutralize_II'] = {
    name = 'Neutralize II', 
    type = 'Magic',
    cost = 3, 
    desc = 'Cures all allies from poison',
    aim = 'allies',
    scope = 'all',
    execute = cure_status,
    statuses = {'POISON'}
}

action_data['purify_I'] = {
    name = 'Purify I', 
    type = 'Magic',
    cost = 1, 
    desc = 'Cures one ally from curse',
    aim = 'allies',
    scope = 'single',
    execute = cure_status,
    statuses = {'CURSE'}
}

action_data['purify_II'] = {
    name = 'Purify II', 
    type = 'Magic',
    cost = 3, 
    desc = 'Cures all allies from curse',
    aim = 'allies',
    scope = 'all',
    execute = cure_status,
    statuses = {'CURSE'}
}

action_data['limber_I'] = {
    name = 'Limber I', 
    type = 'Magic',
    cost = 2, 
    desc = 'Cures one ally from paralysis',
    aim = 'allies',
    scope = 'single',
    execute = cure_status,
    statuses = {'PARALYSIS'}
}

action_data['limber_II'] = {
    name = 'Limber II', 
    type = 'Magic',
    cost = 5, 
    desc = 'Cures all allies from paralysis',
    aim = 'allies',
    scope = 'all',
    execute = cure_status,
    statuses = {'PARALYSIS'}
}

action_data['mend'] = {
    name = 'Mend', 
    type = 'Magic',
    cost = 5, 
    desc = 'Cures all allies from wound',
    aim = 'allies',
    scope = 'all',
    execute = cure_status,
    statuses = {'WOUND'}
}

action_data['refresh'] = {
    name = 'Refresh', 
    type = 'Magic',
    cost = 5, 
    desc = 'Cures all allies from sleep and confuse',
    aim = 'allies',
    scope = 'all',
    execute = cure_status,
    statuses = {'SLEEP', 'CONFUSE'}
}

action_data['cleanse'] = {
    name = 'Cleanse', 
    type = 'Magic',
    cost = 10, 
    desc = 'Cures one ally from all status effects',
    aim = 'allies',
    scope = 'single',
    execute = cleanse,
}

action_data['steel_I'] = {
    name = 'Steel I', 
    type = 'Magic',
    cost = 2, 
    desc = 'Increase defense of one ally by 40%. Stacks twice.',
    aim = 'allies',
    scope = 'single',
    execute = add_buff,
    element = 'STEEL'
}

action_data['steel_II'] = {
    name = 'Steel II', 
    type = 'Magic',
    cost = 5, 
    desc = 'Increase defense of all allies by 40%. Stacks twice.',
    aim = 'allies',
    scope = 'all',
    execute = add_buff,
    element = 'STEEL'
}

action_data['haste_I'] = {
    name = 'Haste I', 
    type = 'Magic',
    cost = 2, 
    desc = 'Increase speed of one ally by 40%. Stacks twice.',
    aim = 'allies',
    scope = 'single',
    execute = add_buff,
    element = 'HASTE'
}

action_data['haste_II'] = {
    name = 'Haste II', 
    type = 'Magic',
    cost = 5, 
    desc = 'Increase speed of all allies by 40%. Stacks twice.',
    aim = 'allies',
    scope = 'all',
    execute = add_buff,
    element = 'HASTE'
}

action_data['barrier'] = {
    name = 'Barrier', 
    type = 'Magic',
    cost = 12, 
    desc = 'Reduce magic damage toward allies by 50%.',
    aim = 'allies',
    scope = 'all',
    execute = add_buff,
    element = 'BARRIER',
}

action_data['might'] = {
    name = 'Might', 
    type = 'Magic',
    cost = 8, 
    desc = 'Increases the attack power of one ally by 80%.',
    aim = 'allies',
    scope = 'single',
    execute = add_buff,
    element = 'MIGHT',
}

action_data['frail_I'] = {
    name = 'Frail I', 
    type = 'Magic',
    cost = 3, 
    desc = 'Reduce defense of one enemy by 40%. Stacks twice.',
    aim = 'enemies',
    scope = 'single',
    execute = status_effect,
    element = 'FRAIL',
    accuracy = 100
}

action_data['frail_II'] = {
    name = 'Frail II', 
    type = 'Magic',
    cost = 6, 
    desc = 'Reduce defense of all enemies by 40%. Stacks twice.',
    aim = 'enemies',
    scope = 'all',
    execute = status_effect,
    element = 'FRAIL',
    accuracy = 100
}

action_data['slow_I'] = {
    name = 'Slow I', 
    type = 'Magic',
    cost = 3, 
    desc = 'Reduce speed of one enemy by 40%. Stacks twice.',
    aim = 'enemies',
    scope = 'single',
    execute = status_effect,
    element = 'SLOW',
    accuracy = 100
}

action_data['slow_II'] = {
    name = 'Slow II', 
    type = 'Magic',
    cost = 6, 
    desc = 'Reduce speed of all enemies by 40%. Stacks twice.',
    aim = 'enemies',
    scope = 'all',
    execute = status_effect,
    element = 'SLOW',
    accuracy = 100
}

action_data['quick_strike'] = {
    name = 'Quick Strike', 
    type = 'Tech',
    cost = 0, 
    desc = 'A fast normal attack but deals half the damage.',
    aim = 'enemies',
    scope = 'single',
    execute = normal_attack,
    priority = 1,
    enemy_animation = {type = 'attack', duration = 1},
    special = 'quick_strike',
    special_text = 'attacks swiftly!'
}

action_data['flame_edge'] = {
    name = 'Flame Edge', 
    type = 'Tech',
    cost = 2, 
    desc = 'A normal attack that deals more damage to targets susceptible to FIRE',
    aim = 'enemies',
    scope = 'single',
    execute = normal_attack,
    enemy_animation = {type = 'attack', duration = 1},
    special = 'elemental_attack',
    element = 'FIRE',
    damage_ratio = 1.3
}

action_data['frost_edge'] = {
    name = 'Frost Edge', 
    type = 'Tech',
    cost = 2, 
    desc = 'A normal attack that deals more damage to targets susceptible to ICE',
    aim = 'enemies',
    scope = 'single',
    execute = normal_attack,
    enemy_animation = {type = 'attack', duration = 1},
    special = 'elemental_attack',
    element = 'ICE',
    damage_ratio = 1.3
}

action_data['bolt_edge'] = {
    name = 'Bolt Edge', 
    type = 'Tech',
    cost = 3, 
    desc = 'A normal attack that deals more damage to targets susceptible to THUNDER',
    aim = 'enemies',
    scope = 'single',
    execute = normal_attack,
    enemy_animation = {type = 'attack', duration = 1},
    special = 'elemental_attack',
    element = 'THUNDER',
    damage_ratio = 1.4
    
}

action_data['gust_edge'] = {
    name = 'Gust Edge', 
    type = 'Tech',
    cost = 3, 
    desc = 'A normal attack that deals more damage to targets susceptible to WIND',
    aim = 'enemies',
    scope = 'single',
    execute = normal_attack,
    enemy_animation = {type = 'attack', duration = 1},
    special = 'elemental_attack',
    element = 'WIND',
    damage_ratio = 1.4
}

action_data['radiant_edge'] = {
    name = 'Radiant Edge', 
    type = 'Tech',
    cost = 4, 
    desc = 'A normal attack that deals more damage to targets susceptible to LIGHT',
    aim = 'enemies',
    scope = 'single',
    execute = normal_attack,
    enemy_animation = {type = 'attack', duration = 1},
    special = 'elemental_attack',
    element = 'LIGHT',
    damage_ratio = 1.5
}

action_data['shadow_edge'] = {
    name = 'Shadow Edge', 
    type = 'Tech',
    cost = 4, 
    desc = 'A normal attack that deals more damage to targets susceptible to DARK',
    aim = 'enemies',
    scope = 'single',
    execute = normal_attack,
    enemy_animation = {type = 'attack', duration = 1},
    special = 'elemental_attack',
    element = 'DARK',
    damage_ratio = 1.5
}

action_data['focus'] = {
    name = 'Focus', 
    type = 'Tech',
    cost = 0, 
    desc = 'Ensure next normal attack to not miss',
    aim = 'allies',
    scope = 'self',
    execute = focus,
}

return action_data