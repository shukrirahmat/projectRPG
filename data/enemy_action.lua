local action_data = require('data.action_data')

local enemy_action = {}

local action = {}

function action.goblin(enemy)
    
    if enemy.current_mp >= action_data['haste_II'].cost and not enemy.status['HASTE'] then
        return 'haste_II'
    end
    
    return 'normal_attack'
end

function action.skeleton(enemy) 
    
    if enemy.current_mp >= action_data['slow_II'].cost then
        return 'slow_II'
    end
    
    return 'normal_attack'
end

function action.dragon(enemy) 
    
    if enemy.current_mp >= action_data['frail_II'].cost then
        return 'frail_II'
    end
    
    return 'normal_attack'
end


function enemy_action.get(enemy)
    if enemy.status['SEAL'] then return 'normal_attack' end
    
    local ref = enemy.ref
    return action[ref](enemy)
end

return enemy_action

