local state = require('state')
local utils = require('utils')
local effect = require('effect')

local actionData = {}

local function normalAttack(user, target, isSecondAttack)

    local result
    local damage
    local crit
    local text

    crit = math.random(1, user.critRate) == 1

    if crit then
        damage = utils.calculateCritDamage(user, target)
    else
        damage = utils.calculateAttackDamage(user, target)
    end

    if isSecondAttack then
        text = ''..user.name..' attacks again!'
    else
        text = ''..user.name..' attacks!'
    end

    if crit then
        text = ''..text..' Critical hit!';
    end

    utils.battleLogAdd(text)
    result = effect.new('damage', user, target, damage)
    table.insert(state.effectList, result)

    if not isSecondAttack then
        local secondAttackChance = math.floor((user.agi - target.agi)/2)
        local secondAttack = math.random(1, 100) < secondAttackChance

        if secondAttack then
            return 'secondAtk'
        end
    end
end

function secondAttack(user, target)
    normalAttack(user, target, true)
end

function defend(user, _)
    user.isDefending = true
    utils.battleLogAdd(''..user.name..' defends!')
end

actionData['normalAtk'] = { 
    execute = normalAttack, 
    cost = 0,
    enemyAnimation = {ref = 'enemyAtk', maxTick = 8, speed = 0.08}
}
actionData['secondAtk'] = {
    execute = secondAttack, 
    cost = 0, 
    priority = true,
    enemyAnimation = {ref = 'enemyAtk', maxTick = 8, speed = 0.08}
}
actionData['defend'] = { 
    execute = defend, 
    cost = 0, 
    priority = true
}

return actionData;