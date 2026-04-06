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

local function proc_second_attack(user, target, engine)
    local chance = math.floor((user:get_spd() - target:get_spd())/2)
    local success
    success = math.random(1, 100) <= chance

    if success then
        engine.add_combo('second_attack', user, {target})
    end
end

local function normal_attack(self, user, targets, engine)
    
    local text = ''..user.name..' attacks!'
    
    if self.special == 'second_attack' then
        text = ''..user.name..' attacks again!'
    end

    for i, target in ipairs(targets) do
        local damage
        local crit = math.random(1, user.crit_rate) == 1
        if crit then
            damage = calculate_crit_damage(user, target)
            engine.log_action(text, 'Critical hit!')
        else
            damage = calculate_attack_damage(user, target)
            engine.log_action(text)
        end
        engine.add_effect('damage', user, target, damage)
        
        if not self.special then
            proc_second_attack(user, target, engine)
        end
    end
end

local function empty_action()
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

action_data['empty_action'] = {     
    name = 'Empty Action',
    execute = empty_action, 
    cost = 0,
    aim = 'allies',
    scope = 'self'    
}

return action_data