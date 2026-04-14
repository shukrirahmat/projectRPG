local action_data = require('data.action_data')

local enemy_action = {}

local action = {}

function action.goblin(enemy)
    
    if enemy.current_mp >= action_data['sandstorm_II'].cost then
        return 'sandstorm_II'
    end
    
    return 'normal_attack'
end

function action.skeleton(enemy) 
    
    if enemy.current_mp >= action_data['tremor_II'].cost then
        return 'tremor_II'
    end
    
    return 'normal_attack'
end

function action.dragon(enemy) 
    
    if enemy.current_mp >= action_data['spellseal_II'].cost then
        return 'spellseal_II'
    end
    
    return 'normal_attack'
end


function enemy_action.get(enemy)
    if enemy.status['SEAL'] then return 'normal_attack' end
    
    local ref = enemy.ref
    return action[ref](enemy)
end

return enemy_action

