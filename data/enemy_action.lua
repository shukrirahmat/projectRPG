local action_data = require('data.action_data')

local enemy_action = {}

local action = {}

function action.goblin(enemy)
    
    --[[if enemy.current_mp >= action_data['icicle_I'].cost then
        return 'icicle_I'
    end]]
    
    return 'normal_attack'
end

function action.skeleton(enemy) 
    
    --[[if enemy.current_mp >= action_data['lumina_I'].cost then
        return 'lumina_I'
    end]]
    
    return 'normal_attack'
end

function action.dragon(enemy) 
    
    --[[if enemy.current_mp >= action_data['cyclone_I'].cost then
        return 'cyclone_I'
    end]]
    
    return 'normal_attack'
end


function enemy_action.get(enemy)
    if enemy.status['SEAL'] then return 'normal_attack' end
    
    local ref = enemy.ref
    return action[ref](enemy)
end

return enemy_action

