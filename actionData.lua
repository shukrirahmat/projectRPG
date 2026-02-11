local state = require('state')
local utils = require('utils')
local effect = require('effect')

local actionData = {}

local function normalAttack(self, user, target, isSecondAttack)
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
    local damageEffect = effect.new('damage', user, target, damage)
    table.insert(state.effectList, damageEffect)

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

local function noMp(self, user, target, skill)
    local text
    if skill.magic then
        text = ''..user.name..' casts '..skill.name..'';
    else
        text = ''..user.name..' used '..skill.name..'';
    end
    utils.battleLogAdd(text)
    local noMPeffect = effect.new('noMp', user, target)
    table.insert(state.effectList, noMPeffect)
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

    local damageEffect = effect.new(ref, user, target, damage)
    table.insert(state.effectList, damageEffect)
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

    if user.isAuraCharged then
        damage = math.floor(damage * 2.5)
    end

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
    local damageEffect = effect.new(ref, user, target, damage)
    table.insert(state.effectList, damageEffect)
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

local function auraCharge(self, user)
    local text = ''..user.name..' charged itself';
    utils.battleLogAdd(text)
    user.isAuraCharged = { counter = 2 }
end

local function castDrain(self, user, target)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)

    local hpBonus = math.floor(user.maxHp * self.drainBonus)
    local baseDamage = self.baseDamage + hpBonus
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

    local damageEffect = effect.new(ref, user, target, damage)
    table.insert(state.effectList, damageEffect)

    if ref ~= 'immune' then
        local amount = math.min(damage, target.currentHp)
        local recoverEffect = effect.new('recover', user, user, amount)
        table.insert(state.effectList, recoverEffect)
    end
end

local function castManaBurn(self, user, group)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)

    for i, target in ipairs(group) do
        if not target.isDead then

            local mod = math.floor(self.baseDamage * 0.2)
            local burnAmount = self.baseDamage + math.random(-mod, mod)
            local resistance = utils.checkResistance(self.element, target)
            local ref

            if resistance == 2 then 
                ref = 'immune'
            elseif resistance == 1 then
                ref = 'mpResisted'
                burnAmount = math.floor(burnAmount/2)
            else
                ref = 'mpDamage'
            end

            local damageEffect = effect.new(ref, user, target, burnAmount)
            table.insert(state.effectList, damageEffect)
        end
    end
end

local function castDracoBomb(self, user, target)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)
    
    local damage;
    
    if target.specialType == 'DRAGON' then
        local mod = math.floor(self.baseDamage * 0.2)
        damage = self.baseDamage + math.random(-mod, mod)
    else
        damage = 1
    end
        
    local damageEffect = effect.new('damage', user, target, damage)
    table.insert(state.effectList, damageEffect)
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

actionData['noMp'] = { 
    execute = noMp
}

actionData['fire'] = {
    name = 'Fire', 
    magic = true,
    cost = 2, 
    desc = 'Deals small fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'FIRE',
    baseDamage = 10
}

actionData['midFire'] = {
    name = 'MidFire', 
    magic = true,
    cost = 4, 
    desc = 'Deals medium fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'FIRE',
    baseDamage = 40
}

actionData['greatFire'] = {
    name = 'GreatFire', 
    magic = true,
    cost = 8, 
    desc = 'Deals large fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'FIRE',
    baseDamage = 100
}

actionData['chaosFire'] = {
    name = 'ChaosFire', 
    magic = true,
    cost = 15, 
    desc = 'Deals very large fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'FIRE',
    baseDamage = 250
}

actionData['ice'] = {
    name = 'Ice', 
    magic = true,
    cost = 3, 
    desc = 'Deals small ice damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'ICE',
    baseDamage = 15
}

actionData['midIce'] = {
    name = 'MidIce', 
    magic = true,
    cost = 5, 
    desc = 'Deals medium ice damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'ICE',
    baseDamage = 50
}

actionData['greatIce'] = {
    name = 'GreatIce', 
    magic = true,
    cost = 10, 
    desc = 'Deals large ice damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'ICE',
    baseDamage = 120
}

actionData['holy'] = {
    name = 'Holy', 
    magic = true,
    cost = 4, 
    desc = 'Deals small holy damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'HOLY',
    baseDamage = 20
}

actionData['midHoly'] = {
    name = 'MidHoly', 
    magic = true,
    cost = 6, 
    desc = 'Deals medium holy damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'HOLY',
    baseDamage = 80
}

actionData['greatHoly'] = {
    name = 'GreatHoly', 
    magic = true,
    cost = 12, 
    desc = 'Deals large holy damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'HOLY',
    baseDamage = 180
}

actionData['void'] = {
    name = 'Void', 
    magic = true,
    cost = 4, 
    desc = 'Deals small void damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'VOID',
    baseDamage = 20,
    variance = 0.4
}

actionData['midVoid'] = {
    name = 'MidVoid', 
    magic = true,
    cost = 6, 
    desc = 'Deals medium void damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'VOID',
    baseDamage = 80,
    variance = 0.4
}

actionData['greatVoid'] = {
    name = 'GreatVoid', 
    magic = true,
    cost = 12, 
    desc = 'Deals large void damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = damageMagicSingle,
    element = 'VOID',
    baseDamage = 180,
    variance = 0.4
}

actionData['fireBlast'] = {
    name = 'FireBlast', 
    magic = true,
    cost = 4, 
    desc = 'Deals small fire damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'FIRE',
    baseDamage = 10
}

actionData['midFireBlast'] = {
    name = 'MidFireBlast', 
    magic = true,
    cost = 8, 
    desc = 'Deals medium fire damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'FIRE',
    baseDamage = 30
}

actionData['greatFireBlast'] = {
    name = 'GreatFireBlast', 
    magic = true,
    cost = 12, 
    desc = 'Deals large fire damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'FIRE',
    baseDamage = 80
}

actionData['iceFrost'] = {
    name = 'IceFrost', 
    magic = true,
    cost = 3, 
    desc = 'Deals small ice damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'ICE',
    baseDamage = 8
}

actionData['midIceFrost'] = {
    name = 'MidIceFrost', 
    magic = true,
    cost = 6, 
    desc = 'Deals medium ice damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'ICE',
    baseDamage = 20
}

actionData['greatIceFrost'] = {
    name = 'GreatIceFrost', 
    magic = true,
    cost = 10, 
    desc = 'Deals large ice damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'ICE',
    baseDamage = 60
}

actionData['chaosIceFrost'] = {
    name = 'ChaosIceFrost', 
    magic = true,
    cost = 20, 
    desc = 'Deals very large ice damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'ICE',
    baseDamage = 150
}

actionData['typhoon'] = {
    name = 'Typhoon', 
    magic = true,
    cost = 5, 
    desc = 'Deals small wind damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'WIND',
    baseDamage = 15
}

actionData['midTyphoon'] = {
    name = 'MidTyphoon', 
    magic = true,
    cost = 9, 
    desc = 'Deals medium wind damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'WIND',
    baseDamage = 50
}

actionData['greatTyphoon'] = {
    name = 'GreatTyphoon', 
    magic = true,
    cost = 14, 
    desc = 'Deals large wind damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'WIND',
    baseDamage = 100,
}

actionData['lightning'] = {
    name = 'Lightning', 
    magic = true,
    cost = 5, 
    desc = 'Deals small bolt damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'BOLT',
    baseDamage = 15,
    variance = 0.4
}

actionData['midLightning'] = {
    name = 'MidLightning', 
    magic = true,
    cost = 9, 
    desc = 'Deals medium bolt damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'BOLT',
    baseDamage = 50,
    variance = 0.4
}

actionData['greatLightning'] = {
    name = 'GreatLightning', 
    magic = true,
    cost = 14, 
    desc = 'Deals large bolt damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = damageMagicAll,
    element = 'BOLT',
    baseDamage = 100,
    variance = 0.4
}

actionData['aura'] = {
    name = 'Aura', 
    magic = true,
    cost = 0, 
    desc = 'Deals damage to all enemies using small percentage of strength',
    aim = 'enemies',
    scope = 'all',
    execute = auraCastAll,
    element = 'AURA',
    auraRatio = 0.1
}

actionData['midAura'] = {
    name = 'MidAura', 
    magic = true,
    cost = 0, 
    desc = 'Deals damage to all enemies using medium percentage of strength',
    aim = 'enemies',
    scope = 'all',
    execute = auraCastAll,
    element = 'AURA',
    auraRatio = 0.2
}

actionData['greatAura'] = {
    name = 'GreatAura', 
    magic = true,
    cost = 0, 
    desc = 'Deals damage to all enemies using high percentage of strength',
    aim = 'enemies',
    scope = 'all',
    execute = auraCastAll,
    element = 'AURA',
    auraRatio = 0.4
}

actionData['auraBeam'] = {
    name = 'AuraBeam', 
    magic = true,
    cost = 0, 
    desc = 'Deals damage to one enemies using high percentage of strength',
    aim = 'enemies',
    scope = 'single',
    execute = auraCastSingle,
    element = 'AURA',
    auraRatio = 0.8
}

actionData['greatAuraBeam'] = {
    name = 'GreatAuraBeam', 
    magic = true,
    cost = 0, 
    desc = 'Deals damage to one enemies using very high percentage of strength',
    aim = 'enemies',
    scope = 'single',
    execute = auraCastSingle,
    element = 'AURA',
    auraRatio = 1.5
}

actionData['auraCharge'] = {
    name = 'AuraCharge', 
    tech = true,
    cost = 0, 
    desc = 'Next aura magic will deal 2.5 more damage',
    aim = 'party',
    scope = 'self',
    execute = auraCharge,
}

actionData['drain'] = {
    name = 'Drain', 
    magic = true,
    cost = 4, 
    desc = 'Deals damage to one enemy and recovers the same amount',
    aim = 'enemies',
    scope = 'single',
    execute = castDrain,
    element = 'DRAIN',
    baseDamage = 20,
    drainBonus = 0.1
}

actionData['greatDrain'] = {
    name = 'GreatDrain', 
    magic = true,
    cost = 8, 
    desc = 'Deals large damage to one enemy and recovers the same amount',
    aim = 'enemies',
    scope = 'single',
    execute = castDrain,
    element = 'DRAIN',
    baseDamage = 60,
    drainBonus = 0.25
}

actionData['manaBurn'] = {
    name = 'ManaBurn', 
    magic = true,
    cost = 2, 
    desc = 'Reduce small amount of all enemies MP',
    aim = 'enemies',
    scope = 'all',
    execute = castManaBurn,
    element = 'MANABURN',
    baseDamage = 10,
}

actionData['greatManaBurn'] = {
    name = 'GreatManaBurn', 
    magic = true,
    cost = 5, 
    desc = 'Reduce large amount of all enemies MP',
    aim = 'enemies',
    scope = 'all',
    execute = castManaBurn,
    element = 'MANABURN',
    baseDamage = 25,
}

actionData['dracoBomb'] = {
    name = 'DracoBomb', 
    magic = true,
    cost = 4, 
    desc = 'Deals large damage to dragons',
    aim = 'enemies',
    scope = 'single',
    execute = castDracoBomb,
    baseDamage = 120
}

actionData['greatDracoBomb'] = {
    name = 'GreatDracoBomb', 
    magic = true,
    cost = 8, 
    desc = 'Deals very large damage to dragons',
    aim = 'enemies',
    scope = 'single',
    execute = castDracoBomb,
    baseDamage = 300
}


return actionData;