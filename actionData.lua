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

    --[[if not isSecondAttack then
        local secondAttackChance = math.floor((user.agility - target.agility)/2)
        local secondAttack = math.random(1, 100) < secondAttackChance

        if secondAttack then
            addAction({actionType = 'SECONDATK', user = user, target = target})
        end
    end]]

    result = effect.new('damage', user, target, damage)
    table.insert(state.effectList, result)
end

function defend(user, _)
    user.isDefending = true
    utils.battleLogAdd(''..user.name..' defends!')
end

actionData['normalAtk'] = { execute = normalAttack, cost = 0 }
actionData['defend'] = { execute = defend, cost = 0, priority = true}


return actionData;