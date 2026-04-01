local enemy_action = {}

local action = {}

function action.goblin()
    return 'normal_attack'
end

function action.skeleton()
    return 'normal_attack'
end


function enemy_action.get(enemy)
    local ref = enemy.ref
    return action[ref]()
end

return enemy_action

