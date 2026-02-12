local state = require('state')
local utils = require('utils')
local effect = require('effect')

local actionData = {}

local function normalAttack(self, user, target, isSecondAttack)
    local damage
    local text
    local miss

    if isSecondAttack then
        text = ''..user.name..' attacks again!'
    else
        text = ''..user.name..' attacks!'
    end

    if user.status['BLIND'] then
        local rand = math.random(1, 100)
        if rand <= 75 then
            miss = true
        end
    end

    if not miss then

        local crit = math.random(1, user.critRate) == 1

        if crit then
            damage = utils.calculateCritDamage(user, target)
            text = ''..text..' Critical hit!';
        else
            damage = utils.calculateAttackDamage(user, target)
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
    else
        utils.battleLogAdd(text)
        local missedEffect = effect.new('missed', user, target)
        table.insert(state.effectList, missedEffect)
    end
end

local function secondAttack(self, user, target)
    normalAttack(self, user, target, true)
end

local function defend(self, user, _)
    user.isDefending = true
    utils.battleLogAdd(''..user.name..' defends!')
end

local function skillCanceled(self, user, target, skill)
    local text
    if skill.magic then
        text = ''..user.name..' casts '..skill.name..'';
    else
        text = ''..user.name..' tried to used '..skill.name..'';
    end
    utils.battleLogAdd(text)
    local noSkilleffect = effect.new('skillCanceled', user, target)
    table.insert(state.effectList, noSkilleffect)
end

local function stunned(self, user)
    local text = ''..user.name..' is stunned and could not move!';
    utils.battleLogAdd(text)
end

local function paralyzed(self, user)
    local text = "Paralysis disrupted "..user.name.."'s action!";
    utils.battleLogAdd(text)
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

    if target.specialType and target.specialType == 'DRAGON' then
        local mod = math.floor(self.baseDamage * 0.2)
        damage = self.baseDamage + math.random(-mod, mod)
    else
        damage = 1
    end

    local damageEffect = effect.new('damage', user, target, damage)
    table.insert(state.effectList, damageEffect)
end

local function castExorcism(self, user, target)

    if target.specialType and target.specialType == 'UNDEAD' then
        local chance = math.random(1, 100)
        if chance <= self.accuracy then
            local killEffect = effect.new('instakill', user, target)
            table.insert(state.effectList, killEffect)
        else
            local missEffect = effect.new('missed', user, target)
            table.insert(state.effectList, missEffect)
        end
    else
        local immuneEffect = effect.new('immune', user, target)
        table.insert(state.effectList, immuneEffect)
    end
end

local function castExorcismSingle(self, user, target)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)
    castExorcism(self, user, target)
end

local function castExorcismAll(self, user, group)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)
    for i, target in ipairs(group) do
        if not target.isDead then
            castExorcism(self, user, target)
        end
    end
end

local function statusEffect(self, user, target)
    local accuracy = self.accuracy
    local resistance = utils.checkResistance(self.element, target)

    if target.status[self.element] then
        local statusEffect = effect.new('addStatus', user, target, self.element)
        table.insert(state.effectList, statusEffect)
    else
        if resistance == 2 then 
            local immuneEffect = effect.new('immune', user, target)
            table.insert(state.effectList, immuneEffect)
        else
            if resistance == 1 then
                accuracy = math.floor(accuracy / 2)
            end
            local chance = math.random(1, 100)
            if chance <= accuracy then
                if self.element == 'DEATH' then
                    local killEffect = effect.new('instakill', user, target)
                    table.insert(state.effectList, killEffect)
                else
                    local statusEffect = effect.new('addStatus', user, target, self.element)
                    table.insert(state.effectList, statusEffect)
                end
            else
                local missEffect = effect.new('missed', user, target)
                table.insert(state.effectList, missEffect)
            end
        end
    end
end

local function statusEffectSingle(self, user, target)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)
    statusEffect(self, user, target)
end

local function statusEffectAll(self, user, group)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)

    for i, target in ipairs(group) do
        if not target.isDead then
            statusEffect(self, user, target)
        end
    end
end

local function heal(self, user, target)
    local amount
    if self.name == 'FullHeal' then
        amount = target.maxHp - target.currentHp
    else
        amount = self.healAmount
        local mod = math.floor(amount*0.2)
        amount = amount + math.random(-mod, mod)
    end
    
    local recoverEffect = effect.new('recover', user, target, amount)
    table.insert(state.effectList, recoverEffect)
end

local function healSingle(self, user, target)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)
    heal(self, user, target)
end

local function healAll(self, user, group)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)
    for i, target in ipairs(group) do
        if not target.isDead then
            heal(self, user, target)
        end
    end
end

local function removeStatus(self, user, target)
    if target.status[self.status] then
        local clear = effect.new('clearStatus', user, target, self.status)
        table.insert(state.effectList, clear)
    else
        local immuneEffect = effect.new('immune', user, target)
        table.insert(state.effectList, immuneEffect)
    end
end

local function removeStatusSingle(self, user, target)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)
    removeStatus(self, user, target)
end

local function removeStatusAll(self, user, group)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)
    for i, target in ipairs(group) do
        if not target.isDead then
            removeStatus(self, user, target)
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

actionData['skillCanceled'] = { 
    execute = skillCanceled
}

actionData['stunned'] = {
    execute = stunned
}

actionData['paralyzed'] = {
    execute = paralyzed
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
    baseDamage = 160
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
    baseDamage = 160,
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
    aim = 'allies',
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
    baseDamage = 150
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

actionData['exorcism'] = {
    name = 'Exorcism', 
    magic = true,
    cost = 4, 
    desc = 'High chance to instantly kill an undead enemies',
    aim = 'enemies',
    scope = 'single',
    execute = castExorcismSingle,
    accuracy = 80
}

actionData['greatExorcism'] = {
    name = 'GreatExorcism', 
    magic = true,
    cost = 8, 
    desc = 'High chance to instantly kill all undead enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castExorcismAll,
    accuracy = 80
}

actionData['death'] = {
    name = 'Death', 
    magic = true,
    cost = 5, 
    desc = 'Low chance to instantly kill one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = statusEffectSingle,
    element = 'DEATH',
    accuracy = 25
}

actionData['midDeath'] = {
    name = 'MidDeath', 
    magic = true,
    cost = 10, 
    desc = 'Low chance to instantly kill all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = statusEffectAll,
    element = 'DEATH',
    accuracy = 25
}

actionData['greatDeath'] = {
    name = 'GreatDeath', 
    magic = true,
    cost = 15, 
    desc = 'High chance to instantly kill all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = statusEffectAll,
    element = 'DEATH',
    accuracy = 50
}

actionData['sandstorm'] = {
    name = 'Sandstorm', 
    magic = true,
    cost = 3, 
    desc = 'Low chance to blind all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = statusEffectAll,
    element = 'BLIND',
    accuracy = 50
}

actionData['greatSandstorm'] = {
    name = 'GreatSandstorm', 
    magic = true,
    cost = 5, 
    desc = 'High chance to blind all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = statusEffectAll,
    element = 'BLIND',
    accuracy = 80
}

actionData['silence'] = {
    name = 'Silence', 
    magic = true,
    cost = 3, 
    desc = 'Low chance to seal abilities of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = statusEffectAll,
    element = 'SEAL',
    accuracy = 50
}

actionData['greatSilence'] = {
    name = 'GreatSilence', 
    magic = true,
    cost = 5, 
    desc = 'High chance to seal abilities of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = statusEffectAll,
    element = 'SEAL',
    accuracy = 80
}

actionData['tremor'] = {
    name = 'Tremor', 
    magic = true,
    cost = 5, 
    desc = 'Low chance to stun of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = statusEffectAll,
    element = 'STUN',
    accuracy = 25
}

actionData['greatTremor'] = {
    name = 'GreatTremor', 
    magic = true,
    cost = 8, 
    desc = 'High chance to stun of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = statusEffectAll,
    element = 'STUN',
    accuracy = 50
}

actionData['wound'] = {
    name = 'Wound', 
    magic = true,
    cost = 3, 
    desc = 'Low chance to leave all enemies wounded',
    aim = 'enemies',
    scope = 'all',
    execute = statusEffectAll,
    element = 'WOUND',
    accuracy = 50
}

actionData['greatWound'] = {
    name = 'GreatWound', 
    magic = true,
    cost = 5, 
    desc = 'High chance to leave all enemies wounded',
    aim = 'enemies',
    scope = 'all',
    execute = statusEffectAll,
    element = 'WOUND',
    accuracy = 80
}

actionData['toxin'] = {
    name = 'Toxin', 
    magic = true,
    cost = 2, 
    desc = 'Low chance to poison one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = statusEffectSingle,
    element = 'POISON',
    accuracy = 50
}

actionData['midToxin'] = {
    name = 'MidToxin', 
    magic = true,
    cost = 3, 
    desc = 'Low chance to poison all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = statusEffectAll,
    element = 'POISON',
    accuracy = 50
}

actionData['greatToxin'] = {
    name = 'GreatToxin', 
    magic = true,
    cost = 5, 
    desc = 'High chance to poison all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = statusEffectAll,
    element = 'POISON',
    accuracy = 80
}

actionData['hex'] = {
    name = 'Hex', 
    magic = true,
    cost = 3, 
    desc = 'Low chance to put a curse one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = statusEffectSingle,
    element = 'CURSE',
    accuracy = 40
}

actionData['midHex'] = {
    name = 'MidHex', 
    magic = true,
    cost = 5, 
    desc = 'Low chance to put a curse on all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = statusEffectAll,
    element = 'CURSE',
    accuracy = 40
}

actionData['greatHex'] = {
    name = 'GreatHex', 
    magic = true,
    cost = 8, 
    desc = 'High chance to put a curse on all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = statusEffectAll,
    element = 'CURSE',
    accuracy = 70
}

actionData['paralyze'] = {
    name = 'Paralyze', 
    magic = true,
    cost = 3, 
    desc = 'Low chance to apply paralysis to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = statusEffectSingle,
    element = 'PARALYSIS',
    accuracy = 40
}

actionData['midParalyze'] = {
    name = 'MidParalyze', 
    magic = true,
    cost = 5, 
    desc = 'Low chance to apply paralysis to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = statusEffectAll,
    element = 'PARALYSIS',
    accuracy = 40
}

actionData['greatParalyze'] = {
    name = 'GreatParalyze', 
    magic = true,
    cost = 8, 
    desc = 'High chance to apply paralysis on all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = statusEffectAll,
    element = 'PARALYSIS',
    accuracy = 70
}

actionData['heal'] = {
    name = 'Heal', 
    magic = true,
    cost = 2, 
    desc = 'Recover small amount of HP to one ally',
    aim = 'allies',
    scope = 'single',
    execute = healSingle,
    healAmount = 40
}

actionData['midHeal'] = {
    name = 'MidHeal', 
    magic = true,
    cost = 4, 
    desc = 'Recover medium amount of HP to one ally',
    aim = 'allies',
    scope = 'single',
    execute = healSingle,
    healAmount = 100
}

actionData['greatHeal'] = {
    name = 'GreatHeal', 
    magic = true,
    cost = 6, 
    desc = 'Recover large amount of HP to one ally',
    aim = 'allies',
    scope = 'single',
    execute = healSingle,
    healAmount = 300
}

actionData['fullHeal'] = {
    name = 'FullHeal', 
    magic = true,
    cost = 10, 
    desc = 'Recover HP of one ally to full',
    aim = 'allies',
    scope = 'single',
    execute = healSingle
}

actionData['healAll'] = {
    name = 'HealAll', 
    magic = true,
    cost = 12, 
    desc = 'Recover medium amount of HP to all allies',
    aim = 'allies',
    scope = 'all',
    execute = healAll,
    healAmount = 80
}

actionData['greatHealAll'] = {
    name = 'GreatHealAll', 
    magic = true,
    cost = 20, 
    desc = 'Recover large amount of HP to all allies',
    aim = 'allies',
    scope = 'all',
    execute = healAll,
    healAmount = 250
}

actionData['neutralize'] = {
    name = 'Neutralize', 
    magic = true,
    cost = 2, 
    desc = 'Remove poison from one ally',
    aim = 'allies',
    scope = 'single',
    execute = removeStatusSingle,
    status = 'POISON'
}

actionData['neutralizeAll'] = {
    name = 'NeutralizeAll', 
    magic = true,
    cost = 5, 
    desc = 'Remove poison from all allies',
    aim = 'allies',
    scope = 'all',
    execute = removeStatusAll,
    status = 'POISON'
}

actionData['purify'] = {
    name = 'Purify', 
    magic = true,
    cost = 3, 
    desc = 'Remove curse from one ally',
    aim = 'allies',
    scope = 'single',
    execute = removeStatusSingle,
    status = 'CURSE'
}

actionData['purifyAll'] = {
    name = 'PurifyAll', 
    magic = true,
    cost = 6, 
    desc = 'Remove curse from all allies',
    aim = 'allies',
    scope = 'all',
    execute = removeStatusAll,
    status = 'CURSE'
}

actionData['dispel'] = {
    name = 'Dispel', 
    magic = true,
    cost = 3, 
    desc = 'Remove paralysis from one ally',
    aim = 'allies',
    scope = 'single',
    execute = removeStatusSingle,
    status = 'PARALYSIS'
}

actionData['dispelAll'] = {
    name = 'DispelAll', 
    magic = true,
    cost = 6, 
    desc = 'Remove paralysis from all allies',
    aim = 'allies',
    scope = 'all',
    execute = removeStatusAll,
    status = 'PARALYSIS'
}

actionData['mend'] = {
    name = 'Mend', 
    magic = true,
    cost = 8, 
    desc = 'Remove wound from all allies',
    aim = 'allies',
    scope = 'all',
    execute = removeStatusAll,
    status = 'WOUND'
}


return actionData;