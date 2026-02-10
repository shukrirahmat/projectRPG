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


local function damageMagic(self, user, target)
    local var = self.variance or 0.2
    local mod = math.floor(self.baseDamage * var)
    local damage = self.baseDamage + math.random(-mod, mod)
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

    local effect = effect.new(ref, user, target, damage)
    table.insert(state.effectList, effect)
end

local function damageMagicSingle(self, user, target)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)
    damageMagic(self, user, target)
end

local function damageMagicAll(self, user, group)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)
    for i, target in ipairs(group) do
        if not target.isDead then
            damageMagic(self, user, target)
        end
    end
end

local function auraCast(self, user, target)
    local baseDamage = math.floor(user.str * self.auraRatio)
    local mod = math.floor(baseDamage * 0.2)
    local damage = baseDamage + math.random(-mod, mod)
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
    local effect = effect.new(ref, user, target, damage)
    table.insert(state.effectList, effect)
end

local function auraCastSingle(self, user, target)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)
    auraCast(self, user, target)
end

local function auraCastAll(self, user, group)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)
    for i, target in ipairs(group) do
        if not target.isDead then
            auraCast(self, user, target)
        end
    end
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
    desc = 'Deals 8-12 fire damage to one enemy',
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
    desc = 'Deals 32-48 fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'FIRE',
    baseDamage = 40
}

actionData['greatFire'] = {
    name = 'GreatFire', 
    skill = true,
    cost = 8, 
    desc = 'Deals 80-120 fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'FIRE',
    baseDamage = 100
}

actionData['chaosFire'] = {
    name = 'ChaosFire', 
    skill = true,
    cost = 15, 
    desc = 'Deals 200-300 fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'FIRE',
    baseDamage = 250
}

actionData['ice'] = {
    name = 'Ice', 
    skill = true,
    cost = 3, 
    desc = 'Deals 12-18 ice damage to one enemy',
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
    desc = 'Deals 40-60 ice damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'ICE',
    baseDamage = 50
}

actionData['greatIce'] = {
    name = 'GreatIce', 
    skill = true,
    cost = 10, 
    desc = 'Deals 96-144 ice damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'ICE',
    baseDamage = 120
}

actionData['holy'] = {
    name = 'Holy', 
    skill = true,
    cost = 4, 
    desc = 'Deals 16-24 holy damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'HOLY',
    baseDamage = 20
}

actionData['midHoly'] = {
    name = 'MidHoly', 
    skill = true,
    cost = 6, 
    desc = 'Deals 64-96 holy damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'HOLY',
    baseDamage = 80
}

actionData['greatHoly'] = {
    name = 'GreatHoly', 
    skill = true,
    cost = 12, 
    desc = 'Deals 144-216 holy damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'HOLY',
    baseDamage = 180
}

actionData['void'] = {
    name = 'Void', 
    skill = true,
    cost = 4, 
    desc = 'Deals 12-28 void damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'VOID',
    baseDamage = 20,
    variance = 0.4
}

actionData['midVoid'] = {
    name = 'MidVoid', 
    skill = true,
    cost = 6, 
    desc = 'Deals 48-112 void damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'VOID',
    baseDamage = 80,
    variance = 0.4
}

actionData['greatVoid'] = {
    name = 'GreatVoid', 
    skill = true,
    cost = 12, 
    desc = 'Deals 108-252 void damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'VOID',
    baseDamage = 180,
    variance = 0.4
}

actionData['fireBlast'] = {
    name = 'FireBlast', 
    skill = true,
    cost = 4, 
    desc = 'Deals 8-12 fire damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'FIRE',
    baseDamage = 10
}

actionData['midFireBlast'] = {
    name = 'MidFireBlast', 
    skill = true,
    cost = 8, 
    desc = 'Deals 24-36 fire damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'FIRE',
    baseDamage = 30
}

actionData['greatFireBlast'] = {
    name = 'GreatFireBlast', 
    skill = true,
    cost = 12, 
    desc = 'Deals 64-96 fire damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'FIRE',
    baseDamage = 80
}

actionData['iceFrost'] = {
    name = 'IceFrost', 
    skill = true,
    cost = 3, 
    desc = 'Deals 7-9 ice damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'ICE',
    baseDamage = 8
}

actionData['midIceFrost'] = {
    name = 'MidIceFrost', 
    skill = true,
    cost = 6, 
    desc = 'Deals 16-24 ice damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'ICE',
    baseDamage = 20
}

actionData['greatIceFrost'] = {
    name = 'GreatIceFrost', 
    skill = true,
    cost = 10, 
    desc = 'Deals 48-72 ice damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'ICE',
    baseDamage = 60
}

actionData['chaosIceFrost'] = {
    name = 'ChaosIceFrost', 
    skill = true,
    cost = 20, 
    desc = 'Deals 120-180 ice damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'ICE',
    baseDamage = 150
}

actionData['typhoon'] = {
    name = 'Typhoon', 
    skill = true,
    cost = 5, 
    desc = 'Deals 12-18 wind damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'WIND',
    baseDamage = 15
}

actionData['midTyphoon'] = {
    name = 'MidTyphoon', 
    skill = true,
    cost = 9, 
    desc = 'Deals 40-60 wind damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'WIND',
    baseDamage = 50
}

actionData['greatTyphoon'] = {
    name = 'GreatTyphoon', 
    skill = true,
    cost = 14, 
    desc = 'Deals 80-120 wind damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'WIND',
    baseDamage = 100,
}

actionData['lightning'] = {
    name = 'Lightning', 
    skill = true,
    cost = 5, 
    desc = 'Deals 9-21 bolt damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'BOLT',
    baseDamage = 15,
    variance = 0.4
}

actionData['midLightning'] = {
    name = 'MidLightning', 
    skill = true,
    cost = 9, 
    desc = 'Deals 30-70 bolt damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'BOLT',
    baseDamage = 50,
    variance = 0.4
}

actionData['greatLightning'] = {
    name = 'GreatLightning', 
    skill = true,
    cost = 14, 
    desc = 'Deals 60-140 bolt damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'BOLT',
    baseDamage = 100,
    variance = 0.4
}

actionData['aura'] = {
    name = 'Aura', 
    skill = true,
    cost = 0, 
    desc = 'Deals damage to all enemies using small percentage of strength',
    aim = 'enemies',
    scope = 'all',
    execute = auraCastAll,
    element = 'AURA',
    auraRatio = 0.2
}

actionData['midAura'] = {
    name = 'MidAura', 
    skill = true,
    cost = 0, 
    desc = 'Deals damage to all enemies using medium percentage of strength',
    aim = 'enemies',
    scope = 'all',
    execute = auraCastAll,
    element = 'AURA',
    auraRatio = 0.5
}

actionData['greatAura'] = {
    name = 'GreatAura', 
    skill = true,
    cost = 0, 
    desc = 'Deals damage to all enemies using high percentage of strength',
    aim = 'enemies',
    scope = 'all',
    execute = auraCastAll,
    element = 'AURA',
    auraRatio = 0.8
}

actionData['auraBeam'] = {
    name = 'AuraBeam', 
    skill = true,
    cost = 0, 
    desc = 'Deals damage to one enemies using high percentage of strength',
    aim = 'enemies',
    scope = 'single',
    execute = auraCastSingle,
    element = 'AURA',
    auraRatio = 1.2
}

actionData['greatAuraBeam'] = {
    name = 'GreatAuraBeam', 
    skill = true,
    cost = 0, 
    desc = 'Deals damage to one enemies using very high percentage of strength',
    aim = 'enemies',
    scope = 'single',
    execute = auraCastSingle,
    element = 'AURA',
    auraRatio = 1.8
}


return actionData;