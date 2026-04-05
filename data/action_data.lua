local action_data = {}

local function calculate_attack_damage(attacker, target) 

    local damage = math.floor(attacker:get_atk()/2) - math.floor(target:get_def()/3)
    local mod = math.floor(damage * 0.2)
    damage = damage + math.floor(math.random(-mod, mod))
    return math.max(damage, 1)
end

local function normal_attack(self, user, targets, engine)

    engine.log_action(''..user.name..' attacks!')

    for i, target in ipairs(targets) do
        local damage = calculate_attack_damage(user, target)
        engine.add_effect('damage', user, target, damage)
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

action_data['empty_action'] = {     
    name = 'Empty Action',
    execute = empty_action, 
    cost = 0,
    aim = 'allies',
    scope = 'self'    
}

return action_data