local action_data = require('data.action_data')

local enemy_action = {}

local action = {}

function action.goblin(enemy)
    
    return 'normal_attack'
end

function action.skeleton(enemy) 
    
    return 'normal_attack'
end

function action.dragon(enemy) 
    
    if enemy.current_mp >= action_data['sandstorm_I'].cost then
        return 'sandstorm_I'
    end
    
    return 'normal_attack'
end


function enemy_action.get(enemy)
    local ref = enemy.ref
    return action[ref](enemy)
end

return enemy_action

