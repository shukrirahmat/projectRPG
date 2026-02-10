local state = require('state')
local utils = require('utils')
local effect = require('effect')

local actionData = {}

local function normalAttack(self, user, target, isSecondAttack)

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

local function secondAttack(self, user, target)
    normalAttack(self, user, target, true)
end

local function defend(self, user, _)
    user.isDefending = true
    utils.battleLogAdd(''..user.name..' defends!')
end

local function damageMagicSingle(self, user, target)
    local var = self.variance or 0.2
    local mod = math.floor(self.baseDamage * var)
    local damage = self.baseDamage + math.random(-mod, mod)
    local text = ''..user.name..' casts '..self.name..'';
    local resistance = utils.checkResistance(self.element, target)
    local ref
    
    if resistance == 2 then 
        ref = 'immune'
    elseif resistance == 1 then
        ref = 'resisted'
        damage = math.floor(damage/2)
    else
        ref = 'damage'
    end
    
    print(resistance)

    utils.battleLogAdd(text)
    local effect = effect.new(ref, user, target, damage)
    table.insert(state.effectList, effect)
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

actionData['fire'] = {
    name = 'Fire', 
    skill = true,
    cost = 2, 
    desc = 'Deal 8-12 fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'FIRE',
    baseDamage = 10
}

actionData['midFire'] = {
    name = 'MidFire', 
    skill = true,
    cost = 4, 
    desc = 'Deal 32-48 fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'FIRE',
    baseDamage = 40
}

actionData['ice'] = {
    name = 'Ice', 
    skill = true,
    cost = 3, 
    desc = 'Deal 12-18 ice damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'ICE',
    baseDamage = 15
}

actionData['midIce'] = {
    name = 'MidIce', 
    skill = true,
    cost = 5, 
    desc = 'Deal 40-60 ice damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'ICE',
    baseDamage = 50
}

return actionData;