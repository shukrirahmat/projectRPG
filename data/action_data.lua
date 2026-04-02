local action_data = {}

local function normal_attack(self, user, targets, logger)
    
    logger.load(''..user.name..' attacks!')
    
end

local function empty_action()
end

action_data['normal_attack'] = {     
    name = 'Normal Attack',
    execute = normal_attack,
    cost = 0,
    aim = 'enemies',
    scope = 'single'    
}

action_data['empty_action'] = {     
    name = 'Empty Action',
    execute = empty_action, 
    cost = 0,
    aim = 'allies',
    scope = 'self'    
}

return action_data