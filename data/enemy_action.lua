local action_data = require('data.action_data')

local enemy_action = {}

local action = {}

function action.goblin(enemy)
    
    if enemy.current_mp >= action_data['scorch_I'].cost then
        return 'scorch_I'
    end
    
    return 'normal_attack'
end

function action.skeleton(enemy) 
    
    if enemy.current_mp >= action_data['lightning_I'].cost then
        return 'lightning_I'
    end
    
    return 'normal_attack'
end


function enemy_action.get(enemy)
    local ref = enemy.ref
    return action[ref](enemy)
end

return enemy_action

