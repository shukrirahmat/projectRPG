local enemyAction = {}

enemyAction['slime'] = {
    get = function(user) 
        return 'normalAtk'
    end
}

enemyAction['goblin'] = {
    get = function(user) 
        return 'normalAtk'
    end
}

return enemyAction