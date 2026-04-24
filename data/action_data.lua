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

local function damage_reduction_check(skill, user, target, damage, engine)
    if target.is_defending and not target:cannot_act() then
        damage = math.max(math.floor(damage/2), 1)
    end

    if skill.damage_type == 'magic' and target.status['BARRIER'] then
        damage = math.max(math.floor(damage/2), 1)
    end

    if skill.damage_type == 'attack' and target.passives['intangible'] 
    and not user.passives['ethereal'] then
        damage = 1
    end

    if skill.damage_type ~= 'mp' and target.passives['last_stand'] then
        if damage >= target.current_hp and target.current_hp > 1 then
            local roll = math.random(1, 100)
            if roll <= target.last_stand_chance then
                damage = target.current_hp - 1
                target.last_stand_chance = math.ceil(target.last_stand_chance * 0.75)
                engine.add_effect('last_stand', user, target)
            end
        end
    end

    return math.max(1, damage)
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

    if user.passives['dual_wield'] then
        success = true
    else
        success = math.random(1, 100) <= chance
    end

    if success then
        engine.add_combo('second_attack', user, {target})
    end
end

local function proc_counter_attack(user, target, engine)
    if user.passives['ranged'] then return end

    local countering = false
    if target.passives['counter_III'] then
        countering = true
    elseif target.passives['counter_II'] then
        countering = math.random(1, 2) == 1
    elseif target.passives['counter_I'] then
        countering = math.random(1, 4) == 1
    end

    if not countering then return end
    if target:cannot_act() then return end

    engine.add_combo('counter_attack', target, {user})
end

local function check_resistance(element, target)
    if target.immune[element] then return 2 end
    if target.strong[element] then return 1 end
    return 0
end

local function proc_on_hit_effect(user, target, engine)
    local list = {'basher', 'mage_slayer', 'sand_master', 'toxicity', 'armor_breaker', 'crippler'}
    local status = {'STUN', 'SEAL', 'BLIND', 'POISON', 'FRAIL', 'SLOW'}
    local base_acc = {25, 25, 25, 50, 100, 100}
    local resist_acc = {10, 10, 10, 20, 40, 40}

    for i = 1, #list do
        if user.passives[list[i]] then
            local ref = check_resistance(status[i], target)
            local accuracy
            if ref == 0 then 
                accuracy = base_acc[i]
            elseif ref == 1 then
                accuracy = resist_acc[i]
            elseif ref == 2 then
                accuracy = 0
            end

            if status[i] == 'STUN' and target.status['RESILIENT'] then
                accuracy = 0
            end

            if status[i] ~= 'FRAIL' and status[i] ~= 'SLOW' then
                if target.status[status[i]] then
                    accuracy = 0
                end
            end

            if status[i] == 'FRAIL' or status[i] == 'SLOW' then
                if target.status[status[i]] and target.status[status[i]].stack == 2 then
                    accuracy = 0
                end
            end

            local roll = math.random(1, 100)
            if roll <= accuracy then
                engine.add_effect('add_status', user, target, status[i])
            end
        end
    end
end

local function proc_elemental_combo(user, target, engine)
    if user.passives['fire_combo'] then
        engine.add_combo('scorch_combo', user, {target})
    end

    if user.passives['ice_combo'] then
        engine.add_combo('icicle_combo', user, {target})
    end

    if user.passives['wind_combo'] then
        local roll = math.random(1,2)
        if roll == 1 then
            local targets = {unpack(engine.get_own_group(target))}
            engine.add_combo('cyclone_combo', user, targets)
        end
    end

    if user.passives['thunder_combo'] then
        local roll = math.random(1,2)
        if roll == 1 then
            local targets = {unpack(engine.get_own_group(target))}
            engine.add_combo('lightning_combo', user, targets)
        end
    end
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

local function attack_connects(user, target)
    if user.status['BLIND'] then
        local roll = math.random(1, 100)
        if roll <= 70 then
            return false
        end
    end

    if target:get_dodge_rate() ~= 0 then
        local roll = math.random(1, target:get_dodge_rate())
        if roll == 1 then
            return false
        end
    end

    return true
end

local function proc_steal(user, target, engine)
    if user.is_party_member and target.is_party_member then
        return
    end

    if not user.is_party_member and not target.is_party_member then
        return
    end

    if user.passives['pincher'] then
        local success = false
        local roll = math.random(1, 8)
        if roll == 1 or target:cannot_act() then
            success = true
        end

        if success then
            local base_amount = user.lvl * 5
            local mod = math.floor(base_amount * 0.5)
            local amount = base_amount + math.random(-mod, mod)
            local min;

            if target.is_party_member then
                min = engine.get_party_gold()
            else
                min = target.stealable_gold
            end

            local steal_amount = math.min(min, amount)
            engine.add_effect('steal_gold', user, target, steal_amount)
        end
    end

    --[[if user.passives['snatcher'] then
        if target.stealableItem then
            local roll = math.random(1, target.stealableItem.rate)
            if roll == 1 then
                local stealEffect = effectCreator.new('stealItem', user, target, target.stealableItem.item)
                table.insert(effects, stealEffect)
            end
        end
    end]]
end

local function instakill_triggered(user, target)
    if user.passives['executioner'] then
        local ref = check_resistance('DEATH', target)
        local accuracy
        if ref == 0 then 
            accuracy = 20
        elseif ref == 1 then
            accuracy = 5
        elseif ref == 2 then
            accuracy = 0
        end
        local roll = math.random(1, 100)
        if roll <= accuracy then
            return true
        end
    end

    return false
end

local function element_boost(user, element, damage)
    local passives = {
        'fire_boost', 
        'ice_boost', 
        'wind_boost', 
        'thunder_boost', 
        'light_boost', 
        'dark_boost', 
        'drain_boost'
    }
    local elements = {'FIRE', 'ICE', 'WIND', 'THUNDER', 'LIGHT', 'DARK', 'DRAIN'}

    for i = 1, #elements do
        if element == elements[i] and user.passives[passives[i]] == true then
            local multiplier = 1.5
            if elements[i] == 'DRAIN' then multiplier = 2 end
            return math.floor(damage * multiplier)
        end
    end

    return damage
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

        if not user.is_focused and not attack_connects(user, target) then
            engine.log_action(text)
            engine.add_effect('missed', user, target)

            if not self.special then
                proc_counter_attack(user, target, engine)
                proc_second_attack(user, target, engine)
            elseif self.special and self.special ~= 'counter_attack' then
                proc_counter_attack(user, target, engine)
            end

            goto continue
        end

        if instakill_triggered(user, target) then
            engine.log_action(text)
            engine.add_effect('kill', user, target)
            proc_elemental_combo(user, target, engine)
            proc_steal(user, target, engine)
            goto continue
        end

        local damage
        local crit = math.random(1, user:get_crit_rate()) == 1
        if crit then
            damage = calculate_crit_damage(user, target)
            engine.log_action(text, 'Critical hit!', 0.5)
        else
            damage = calculate_attack_damage(user, target)
            engine.log_action(text)
        end

        local modifier = normal_attack_modifier(self, user, target, damage)

        if not modifier.resist then
            local damage = damage_reduction_check(self, user, target, modifier.damage, engine)
            engine.add_effect('damage', user, target, damage)
        elseif modifier.resist == 'resist' then
            local damage = damage_reduction_check(self, user, target, modifier.damage, engine)
            engine.add_effect('resist', user, target, damage)
        elseif modifier.resist == 'immune' then
            engine.add_effect('immune', user, target)
            goto post_attack
        end

        proc_on_hit_effect(user, target, engine)
        proc_elemental_combo(user, target, engine)
        proc_steal(user, target, engine)

        ::post_attack::

        if not self.special then
            proc_counter_attack(user, target, engine)
            proc_second_attack(user, target, engine)
        elseif self.special and self.special ~= 'counter_attack' then
            proc_counter_attack(user, target, engine)
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

    if self.combo then
        engine.log_action('Unleashed '..self.name..'!')
    else
        engine.log_action(''..user.name..' casts '..self.name..'!')
    end

    for i, target in ipairs(targets) do
        if not target:is_alive() then goto continue end

        local base_damage = element_boost(user, self.element, self.base_damage)

        local var = self.variance or 0.2
        local mod = math.floor(base_damage * var)
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

        damage = damage_reduction_check(self, user, target, damage, engine)
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

        damage = damage_reduction_check(self, user, target, damage, engine)
        engine.add_effect(effect_ref, user, target, damage)

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

        local base_damage = element_boost(user, self.element, self.base_damage)
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

        damage = damage_reduction_check(self, user, target, damage, engine)
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

        damage = damage_reduction_check(self, user, target, damage, engine)
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

        damage = damage_reduction_check(self, user, target, damage, engine)
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

        if self.element == 'STUN' or self.element == 'SLEEP' or self.element == 'CONFUSE' then
            if target.status['RESILIENT'] then
                engine.add_effect('immune', user, target)
                goto continue
            end
        end

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

    if self.type == 'Magic' then
        engine.log_action(''..user.name..' casts '..self.name..'!')
    elseif self.type == 'Item' then
        engine.log_action(''..user.name..' used '..self.name..'!')
    end

    if self.scope == 'single' and targets[1].is_dead then
        engine.add_effect('nothing_happened', user, targets[1])
        return
    end

    for i, target in ipairs(targets) do
        if target.is_dead then goto continue end

        if self.heal_amount == 'full' then
            local heal_amount = target.max_hp - target.current_hp
            engine.add_effect('recover', user, target, heal_amount)
            goto continue
        end

        local base_amount = self.heal_amount
        local mod = math.floor(base_amount * 0.2)
        local heal_amount = base_amount + math.random(-mod, mod)

        if self.type == 'Item' then
            heal_amount = base_amount
        end

        heal_amount = healing_reduction_check(user, target, heal_amount)
        engine.add_effect('recover', user, target, heal_amount)

        ::continue::
    end
end

local function heal_mp(self, user, targets, engine)

    if self.type == 'Magic' then
        engine.log_action(''..user.name..' casts '..self.name..'!')
    elseif self.type == 'Item' then
        engine.log_action(''..user.name..' used '..self.name..'!')
    end

    if self.scope == 'single' and targets[1].is_dead then
        engine.add_effect('nothing_happened', user, targets[1])
        return
    end

    for i, target in ipairs(targets) do
        if target.is_dead then goto continue end

        if self.heal_amount == 'full' then
            local heal_amount = target.max_mp - target.current_mp
            engine.add_effect('recover_mp', user, target, heal_amount)
            goto continue
        end

        engine.add_effect('recover_mp', user, target, self.heal_amount)

        ::continue::
    end
end

local function revive(self, user, targets, engine)

    if self.type == 'Magic' then
        engine.log_action(''..user.name..' casts '..self.name..'!')
    elseif self.type == 'Item' then
        engine.log_action(''..user.name..' used '..self.name..'!')
    end

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

    if self.type == 'Magic' then
        engine.log_action(''..user.name..' casts '..self.name..'!')
    elseif self.type == 'Item' then
        engine.log_action(''..user.name..' used '..self.name..'!')
    end

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

    if self.type == 'Tech' then
        engine.log_action(''..user.name..' used '..self.name..'!')
    elseif self.type == 'Magic' then
        engine.log_action(''..user.name..' casts '..self.name..'!')
    end

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

local function purge(self, user, targets, engine)

    engine.log_action(''..user.name..' used '..self.name..'!')

    for i, target in ipairs(targets) do
        if target.is_dead then goto continue end

        engine.add_effect('purge', user, target)

        ::continue::
    end
end

local function undo(self, user, targets, engine)

    engine.log_action(''..user.name..' casts '..self.name..'!')

    for i, target in ipairs(targets) do
        if target.is_dead then goto continue end

        engine.add_effect('undo', user, target)

        ::continue::
    end
end

local function mana_share(self, user, targets, engine)

    engine.log_action(''..user.name..' used '..self.name..'!')

    if self.scope == 'single' and targets[1].is_dead then
        engine.add_effect('nothing_happened', user, targets[1])
        return
    end

    for i, target in ipairs(targets) do
        if target.is_dead then goto continue end
        if target == user then goto continue end

        local recover_amount = math.min(target.max_mp - target.current_mp, self.amount)
        engine.add_effect('recover_mp', user, target, recover_amount)

        ::continue::
    end
end

local function guardian_angel(self, user, targets, engine)

    engine.log_action(''..user.name..' casts '..self.name..'!', 'The party become invincible!')

    for i, target in ipairs(targets) do
        if not target:is_alive() then goto continue end

        engine.add_effect('guardian', user, target)

        ::continue::
    end
end

local function cover(self, user, targets, engine)

    for i, target in ipairs(targets) do
        if not target:is_alive() then goto continue end

        engine.log_action(''..user.name..' covers '..target.name..'!')
        engine.add_effect('cover', user, target)

        ::continue::
    end
end

local function ram(self, user, targets, engine)

    engine.log_action(''..user.name..' used '..self.name..'!')

    for i, target in ipairs(targets) do
        if not target:is_alive() then goto continue end

        local base_damage = math.max(1, math.floor(user.current_hp * 0.2))
        local mod = math.floor(base_damage * 0.2) 
        local damage = base_damage + math.random(-mod, mod)

        local enemy_damage = damage * 2
        local recoil = damage

        enemy_damage = damage_reduction_check(self, user, target, enemy_damage, engine)
        engine.add_effect('damage', user, target, enemy_damage)

        recoil = damage_reduction_check(self, user, user, recoil, engine)
        engine.add_effect('damage', user, user, recoil)

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
    enemy_animation = {type = 'attack', duration = 1},
    damage_type = 'attack'
}

action_data['second_attack'] = {     
    name = 'Second Attack',
    execute = normal_attack,
    cost = 0,
    aim = 'enemies',
    scope = 'single',
    enemy_animation = {type = 'attack', duration = 1},
    special = 'second_attack',
    special_text = 'attacks again!',
    damage_type = 'attack'
}

action_data['counter_attack'] = {     
    name = 'Counter Attack',
    execute = normal_attack,
    cost = 0,
    aim = 'enemies',
    scope = 'single',
    enemy_animation = {type = 'attack', duration = 1},
    special = 'counter_attack',
    special_text = 'counters!',
    damage_type = 'attack'
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
    special_text = 'attacks while being confused!',
    damage_type = 'attack'
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
    base_damage = 15,
    damage_type = 'magic'
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
    base_damage = 45,
    damage_type = 'magic'
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
    base_damage = 120,
    damage_type = 'magic'
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
    base_damage = 240,
    damage_type = 'magic'
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
    base_damage = 12,
    damage_type = 'magic'
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
    base_damage = 39,
    damage_type = 'magic'
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
    base_damage = 93,
    damage_type = 'magic'
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
    base_damage = 20,
    damage_type = 'magic'
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
    base_damage = 65,
    damage_type = 'magic'
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
    base_damage = 155,
    damage_type = 'magic'
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
    base_damage = 9,
    damage_type = 'magic'
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
    base_damage = 27,
    damage_type = 'magic'
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
    base_damage = 72,
    damage_type = 'magic'
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
    base_damage = 144,
    damage_type = 'magic'
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
    base_damage = 18,
    damage_type = 'magic'
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
    base_damage = 54,
    damage_type = 'magic'
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
    base_damage = 117,
    damage_type = 'magic'
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
    variance = 0.4,
    damage_type = 'magic'
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
    variance = 0.4,
    damage_type = 'magic'
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
    variance = 0.4,
    damage_type = 'magic'
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
    base_damage = 30,
    damage_type = 'magic'
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
    base_damage = 90,
    damage_type = 'magic'
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
    base_damage = 195,
    damage_type = 'magic'
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
    variance = 0.3,
    damage_type = 'magic'
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
    variance = 0.3,
    damage_type = 'magic'
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
    variance = 0.4,
    damage_type = 'magic'
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
    aura_ratio = 0.1,
    damage_type = 'aura'
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
    aura_ratio = 0.25,
    damage_type = 'aura'
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
    aura_ratio = 0.5,
    damage_type = 'aura'
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
    aura_ratio = 0.8,
    damage_type = 'aura'
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
    aura_ratio = 1.2,
    damage_type = 'aura'
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
    damage_type = 'magic'
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
    damage_type = 'magic'
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
    damage_type = 'mp'
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
    damage_type = 'mp'
}

action_data['dragonsbane_I'] = {
    name = "Dragonsbane I", 
    type = 'Magic',
    cost = 4, 
    desc = 'Deals 80~120 damage. Only works on dragons.',
    aim = 'enemies',
    scope = 'single',
    execute = dragonsbane,
    base_damage = 100,
    damage_type = 'magic'
}

action_data['dragonsbane_II'] = {
    name = "Dragonsbane II", 
    type = 'Magic',
    cost = 8, 
    desc = 'Deals 180~270 damage. Only works on dragons.',
    aim = 'enemies',
    scope = 'single',
    execute = dragonsbane,
    base_damage = 225,
    damage_type = 'magic'
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
    desc = 'Recover full HP to one ally. Unaffected by WOUND status',
    aim = 'allies',
    scope = 'single',
    execute = heal,
    heal_amount = 'full'
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
    special_text = 'attacks swiftly!',
    damage_type = 'attack'
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
    damage_ratio = 1.3,
    damage_type = 'attack'
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
    damage_ratio = 1.3,
    damage_type = 'attack'
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
    damage_ratio = 1.4,
    damage_type = 'attack'
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
    damage_ratio = 1.4,
    damage_type = 'attack'
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
    damage_ratio = 1.5,
    damage_type = 'attack'
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
    damage_ratio = 1.5,
    damage_type = 'attack'
}

action_data['focus'] = {
    name = 'Focus', 
    type = 'Tech',
    cost = 0, 
    desc = 'Ensure next normal attack to 100% hit',
    aim = 'allies',
    scope = 'self',
    execute = focus,
}

action_data['purge'] = {
    name = 'Purge', 
    type = 'Tech',
    cost = 2, 
    desc = 'Remove defense and speed reduction from self.',
    aim = 'allies',
    scope = 'self',
    execute = purge,
}

action_data['undo'] = {
    name = 'Undo', 
    type = 'Magic',
    cost = 15, 
    desc = 'Remove attack, defense and speed increases from all enemies.',
    aim = 'enemies',
    scope = 'all',
    execute = undo,
}

action_data['mana_share'] = {
    name = 'Mana Share', 
    type = 'Tech',
    cost = 25, 
    desc = 'Recover 20 MP to one ally.',
    aim = 'allies',
    scope = 'single',
    exclude_self = true,
    execute = mana_share,
    amount = 20
}

action_data['mana_share_all'] = {
    name = 'Mana Share All', 
    type = 'Tech',
    cost = 50, 
    desc = 'Recover 20 MP to all allies.',
    aim = 'allies',
    scope = 'all',
    execute = mana_share,
    amount = 20
}

action_data['valiant_breath'] = {
    name = 'Valiant Breath', 
    type = 'Tech',
    cost = 8, 
    desc = 'Become immune to STUN, SLEEP and CONFUSE for several turns.',
    aim = 'allies',
    scope = 'self',
    execute = add_buff,
    element = 'RESILIENT'
}

action_data['guardian_angel'] = {
    name = 'Guardian Angel', 
    type = 'Magic',
    cost = 20, 
    desc = 'Protects all allies from any effect but they cannot act for the turn.',
    aim = 'allies',
    scope = 'all',
    execute = guardian_angel,
    priority = 3
}

action_data['cover'] = {
    name = 'Cover', 
    type = 'Tech',
    cost = 0, 
    desc = 'Cover an ally from any attack.',
    aim = 'allies',
    scope = 'single',
    execute = cover,
    exclude_self = true,
    priority = 2
}

action_data['ram'] = {
    name = 'Ram', 
    type = 'Tech',
    cost = 0, 
    desc = 'Lose 20% of own HP and deals 2x the amount to one enemy.',
    aim = 'enemies',
    scope = 'single',
    execute = ram,
    damage_type = 'attack'
}

action_data['scorch_combo'] = {
    name = 'Scorch I', 
    type = 'Magic',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'FIRE',
    base_damage = 15,
    damage_type = 'magic',
    combo = true
}

action_data['icicle_combo'] = {
    name = 'Icicle I', 
    type = 'Magic',
    aim = 'enemies',
    scope = 'single',
    execute = damage_magic,
    element = 'ICE',
    base_damage = 20,
    damage_type = 'magic',
    combo = true
}

action_data['cyclone_combo'] = {
    name = 'Cyclone I', 
    type = 'Magic',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'WIND',
    base_damage = 18,
    damage_type = 'magic',
    combo = true
}

action_data['lightning_combo'] = {
    name = 'Lightning I', 
    type = 'Magic',
    aim = 'enemies',
    scope = 'all',
    execute = damage_magic,
    element = 'THUNDER',
    base_damage = 18,
    variance = 0.4,
    damage_type = 'magic',
    combo = true
}

--ITEM ACTIONS--

action_data['potion'] = {
    name = 'Potion', 
    type = 'Item',
    aim = 'allies',
    scope = 'single',
    execute = heal,
    heal_amount = 40
}

action_data['master_potion'] = {
    name = 'Master Potion', 
    type = 'Item',
    aim = 'allies',
    scope = 'single',
    execute = heal,
    heal_amount = 'full'
}

action_data['mana_potion'] = {
    name = 'mana_potion', 
    type = 'Item',
    aim = 'allies',
    scope = 'single',
    execute = heal_mp,
    heal_amount = 50
}

action_data['antidote'] = {
    name = 'Antidote', 
    type = 'Item',
    aim = 'allies',
    scope = 'single',
    execute = cure_status,
    statuses = {'POISON'}
}

action_data['holy_water'] = {
    name = 'Holy Water', 
    type = 'Item',
    aim = 'allies',
    scope = 'single',
    execute = cure_status,
    statuses = {'CURSE'}
}

action_data['bandage'] = {
    name = 'Bandage', 
    type = 'Item',
    aim = 'allies',
    scope = 'single',
    execute = cure_status,
    statuses = {'WOUND'}
}

action_data['excite_herb'] = {
    name = 'Excite Herb', 
    type = 'Item',
    aim = 'allies',
    scope = 'single',
    execute = cure_status,
    statuses = {'PARALYSIS'}
}

action_data['smelly_herb'] = {
    name = 'Smelly Herb', 
    type = 'Item',
    aim = 'allies',
    scope = 'single',
    execute = cure_status,
    statuses = {'SLEEP'}
}

action_data['clarity_brew'] = {
    name = 'Clarity Brew', 
    type = 'Item',
    aim = 'allies',
    scope = 'single',
    execute = cure_status,
    statuses = {'CONFUSE'}
}

action_data['elixir_of_life'] = {
    name = 'Elixir of Life', 
    type = 'Item',
    aim = 'allies',
    scope = 'dead',
    execute = revive,
    revive_ratio = 1
}


return action_data