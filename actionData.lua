local state = require('state')
local utils = require('utils')
local effectCreator = require('effectCreator')
local actionCreator = require('actionCreator')

local actionData = {}

local function handleExecutor(user, target)
    if user.passives['executor'] then
        local ref = utils.checkResistance('DEATH', target)
        local accuracy
        if ref == 0 then 
            accuracy = 20
        elseif ref == 1 then
            acurracy = 5
        elseif ref == 2 then
            accuracy = 0
        end
        local roll = math.random(1, 100)
        if roll <= accuracy then
            return true
        end
    end

    return false
end

local function handleOnHitEffects(user, target)
    local psv = {'basher'}
    local status = {'STUN'}

    for i = 1, #psv do
        local p = psv[i]
        if user.passives[p] then
            local ref = utils.checkResistance(status[i], target)
            local accuracy
            if ref == 0 then 
                accuracy = 20
            elseif ref == 1 then
                acurracy = 5
            elseif ref == 2 then
                accuracy = 0
            end
            local roll = math.random(1, 100)
            if roll <= accuracy then
                statusEffect = effectCreator.new('addStatus', user, target, status[i])
                table.insert(state.effectList, statusEffect)
            end
        end
    end
end

local function handleSteal(user, target)
    if user.passives['pincher'] then
        local baseAmount = user.lvl * 5
        local mod = math.floor(baseAmount * 0.5)
        local amount = baseAmount + math.random(-mod, mod)
        local stealEffect = effectCreator.new('stealGold', user, target, amount)
        table.insert(state.effectList, stealEffect)
    end
    
    --PARTY EXCLUSIVES
    if user.passives['snatcher'] then
        if target.stealableItem then
            local roll = math.random(1, target.stealableItem.rate)
            if roll == 1 then
                local stealEffect = effectCreator.new('stealItem', user, target, target.stealableItem.item)
                table.insert(state.effectList, stealEffect)
            end
        end
    end
end

local function handleCounterAttack(user, target)
    if target.passives['counter'] then
        if not target.status['SLEEP'] and not target.status['CONFUSE'] and not target.status['STUN'] then
            local counterAction = actionCreator.new('counterAtk', user, {target})
            table.insert(state.followUp, counterAction)
        end
    end
end

local function checkMiss(user, target)
    if user.status['BLIND'] then
        local roll = math.random(1, 100)
        if roll <= 75 then
            return true
        end
    end

    if target.dodgeRate ~= 0 then
        local roll = math.random(1, target.dodgeRate)
        if roll == 1 then
            return true
        end
    end

    return false
end

local function handleElementalCombo(user, target)
    if user.passives['fireCombo'] then
        local followUp = actionCreator.new('flameI', user, {target})
        followUp.combo = true
        table.insert(state.followUp, followUp)
    end

    if user.passives['iceCombo'] then
        local followUp = actionCreator.new('frostI', user, {target})
        followUp.combo = true
        table.insert(state.followUp, followUp)
    end

    if user.passives['windCombo'] then
        local targets;
        if not target.isPartyMember then
            targets = {unpack(state.enemies)};
        else
            targets = {unpack(state.party)};
        end
        local followUp = actionCreator.new('typhoonI', user, targets)
        followUp.combo = true
        table.insert(state.followUp, followUp)
    end

    if user.passives['boltCombo'] then
        local targets;
        if not target.isPartyMember then
            targets = {unpack(state.enemies)};
        else
            targets = {unpack(state.party)};
        end
        local followUp = actionCreator.new('lightningI', user, targets)
        followUp.combo = true
        table.insert(state.followUp, followUp)
    end
end

local function normalAttack(self, user, targets, special)

    for i, target in ipairs(targets) do

        if not target.isDead then
            local damage
            local text
            local miss
            local resisted

            if special then
                text = ''..user.name..' '..special.text..''
            else
                text = ''..user.name..' attacks!'
            end

            miss = checkMiss(user, target)

            if not miss or user.isFocused then

                if handleExecutor(user, target) then
                    utils.battleLogAdd(text)
                    local killEffect = effectCreator.new('instakill', user, target)
                    table.insert(state.effectList, killEffect)
                    handleSteal(user, target)
                    return
                end

                local crit
                if special and special.cat == 'desperation' then
                    if (user.currentHp/user.maxHp) < 0.2 then
                        crit = math.random(1, 4) < 4
                    else
                        crit = false
                    end
                    if not crit then
                        utils.battleLogAdd(text)
                        local immuneEffect = effectCreator.new('immune', user, target, damage)        
                        table.insert(state.effectList, immuneEffect)
                        return
                    end
                else
                    crit = math.random(1, user.critRate) == 1
                end

                if crit then
                    damage = utils.calculateCritDamage(user, target)
                    text = ''..text..' Critical hit!';
                else
                    damage = utils.calculateAttackDamage(user, target)
                end

                if special and special.cat == 'quickStrike' then
                    damage = math.floor(damage * 0.5)
                end

                if special and special.cat == 'elemental' then
                    local res = utils.checkResistance(special.element, target)
                    if res == 0 then
                        if special.element == 'FIRE' 
                        or special.element == 'ICE'
                        or special.element == 'BOLT'
                        or special.element == 'WIND' then
                            damage = math.floor(damage * 1.5)
                        elseif special.element == 'LIGHT' or special.element == 'VOID' then
                            damage = math.floor(damage * 1.75)
                        end
                    elseif res == 1 then
                        damage = math.floor(damage * 0.5)
                        resisted = true;
                    elseif res == 2 then
                        utils.battleLogAdd(text)
                        local immuneEffect = effectCreator.new('immune', user, target, damage)        
                        table.insert(state.effectList, immuneEffect)
                        return
                    end
                end

                utils.battleLogAdd(text)

                if resisted then
                    local resistedEffect = effectCreator.new('resisted', user, target, damage)        
                    table.insert(state.effectList, resistedEffect)
                else
                    local damageEffect = effectCreator.new('damage', user, target, damage)        
                    table.insert(state.effectList, damageEffect)
                end

                handleOnHitEffects(user, target)
                handleSteal(user, target)
                handleElementalCombo(user, target)

                if not special then
                    handleCounterAttack(user, target)
                elseif special and special.cat ~= 'counter' then
                    handleCounterAttack(user, target)
                end

                if not special then
                    local secondAttackChance = math.floor((user.agi - target.agi)/2)
                    local secondAttack
                    if user.passives['dualWield'] then
                        secondAttack = true
                    else
                        secondAttack = math.random(1, 100) < secondAttackChance
                    end

                    if secondAttack then
                        local followUp = actionCreator.new('secondAtk', user, {target})
                        table.insert(state.followUp, followUp)
                    end
                end
            else
                utils.battleLogAdd(text)
                local missedEffect = effectCreator.new('missed', user, target)
                table.insert(state.effectList, missedEffect)
            end
        end
    end
end

local function secondAttack(self, user, targets)
    local special = {cat ='secondAttack', text = 'attacks again!'}
    normalAttack(self, user, targets, special)
end

local function counterAttack(self, user, targets)
    local special = {cat ='counter', text = 'counters!'}
    normalAttack(self, targets[1], {user}, special)
end

local function quickStrike(self, user, targets)
    local special = {cat ='quickStrike', text = 'attacks swiftly!'}
    normalAttack(self, user, targets, special)
end

local function elementalStrike(self, user, targets)
    local special = {cat = 'elemental', element = self.element, text = 'used '..self.name..''}
    normalAttack(self, user, targets, special)
end

local function desperation(self, user, targets)
    local special = {cat = 'desperation', text = 'tries a desperation attack!'}
    normalAttack(self, user, targets, special)
end

local function defend(self, user)
    user.isDefending = true
    utils.battleLogAdd(''..user.name..' defends!')
end

local function cover(self, user, targets)
    for i, target in ipairs(targets) do
        if not target.isDead then
            target.isCovered = { coveredBy = user }
            utils.battleLogAdd(''..user.name..' covers '..target.name..' from attacks!')
        end
    end
end

local function ram(self, user, targets)
    for i, target in ipairs(targets) do
        if not target.isDead then
            utils.battleLogAdd(''..user.name..' rams into '..target.name..'!')
            local baseDamage = math.floor(user.currentHp*0.6) - math.floor(target.def/3)
            local mod = math.floor(baseDamage*0.2)
            local damage = math.max(1, baseDamage + math.random(-mod, mod))
            local damageEffect = effectCreator.new('damage', user, target, damage)        
            table.insert(state.effectList, damageEffect)

            local ownDamage = math.floor(user.currentHp*0.2)
            local ownMod = math.floor(ownDamage*0.2)
            local recoil = math.max(1, ownDamage + math.random(-ownMod, ownMod))
            local recoilEffect = effectCreator.new('damage', user, user, recoil)        
            table.insert(state.effectList, recoilEffect)
        end
    end
end

local function skillCanceled(self, user, targets, skill)
    local text
    if skill.magic then
        text = ''..user.name..' casts '..skill.name..'';
    else
        text = ''..user.name..' tried to used '..skill.name..'';
    end
    utils.battleLogAdd(text)
    local noSkilleffect = effectCreator.new('skillCanceled', user, targets)
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

local function sleeping(self, user)
    local text = ''..user.name..' is sleeping soundly!';
    utils.battleLogAdd(text)
end

local function confused(self, user)

    local textList = {
        'is rolling on the ground laughing.',
        'is dancing happily.',
        'is crying at himself.',
        'pretends to be dead.',
    }

    local target
    local roll = math.random(1,3)
    if roll == 1 then
        target = utils.selectTargetRandomly(state.party)
        normalAttack(self, user, {target}, {cat = 'confused', text = 'attacks while being confused'})
    elseif roll == 2 then
        target = utils.selectTargetRandomly(state.enemies)
        normalAttack(self, user, {target}, {cat = 'confused', text = 'attacks while being confused'})
    elseif roll == 3 then
        local textRoll = math.random(1, #textList)
        local text = ''..user.name..' '..textList[textRoll]..'';
        utils.battleLogAdd(text)
    end
end

local function barrierCheck(target, damage)
    if target.status['BARRIER'] then
        return math.floor(damage * 0.5)
    else
        return damage
    end
end

local function passiveBoost(user, element, damage)
    local passives = {'fireLord', 'iceLord', 'windLord', 'thunderLord', 'seraph', 'demonLord', 'leechLord'}
    local elements = {'FIRE', 'ICE', 'WIND', 'BOLT', 'LIGHT', 'VOID', 'DRAIN'}

    for i = 1, #elements do
        if element == elements[i] and user.passives[passives[i]] == true then
            local multiplier = 1.5
            if elements[i] == 'DRAIN' then multiplier = 2 end
            return math.floor(damage * multiplier)
        end
    end

    return damage
end

local function castDamageMagic(self, user, targets, special)

    local text = ''..user.name..' casts '..self.name..'';
    if special and special.combo then
        text = 'Unleashed '..self.name..'';
    end
    utils.battleLogAdd(text)

    for i, target in ipairs(targets) do
        if not target.isDead then
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

            damage = passiveBoost(user, self.element, damage)
            damage = barrierCheck(target, damage)

            local damageEffect = effectCreator.new(ref, user, target, damage)
            table.insert(state.effectList, damageEffect)
        end
    end
end

local function useAura(self, user, targets)

    local text = ''..user.name..' uses '..self.name..'';
    utils.battleLogAdd(text)

    for i, target in ipairs(targets) do
        if not target.isDead then

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

            local damageEffect = effectCreator.new(ref, user, target, damage)
            table.insert(state.effectList, damageEffect)
        end
    end
end

local function auraCharge(self, user)
    local text = ''..user.name..' charged itself';
    utils.battleLogAdd(text)
    user.isAuraCharged = { counter = 2 }
end

local function focus(self, user)
    local text = ''..user.name..' increases their focus';
    utils.battleLogAdd(text)
    user.isFocused = { counter = 2 }
end

local function castDrain(self, user, targets)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)

    for i, target in ipairs(targets) do
        if not target.isDead then

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

            damage = passiveBoost(user, self.element, damage)
            damage = barrierCheck(target, damage)

            local damageEffect = effectCreator.new(ref, user, target, damage)
            table.insert(state.effectList, damageEffect)

            if ref ~= 'immune' then
                local amount = math.min(damage, target.currentHp)
                local recoverEffect = effectCreator.new('recover', user, user, amount)
                table.insert(state.effectList, recoverEffect)
            end
        end
    end
end

local function castManaBurn(self, user, targets)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)

    for i, target in ipairs(targets) do
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

            damage = barrierCheck(target, burnAmount)

            local damageEffect = effectCreator.new(ref, user, target, burnAmount)
            table.insert(state.effectList, damageEffect)
        end
    end
end

local function castDracoBomb(self, user, targets)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)

    for i, target in ipairs(targets) do 
        if not target.isDead then

            local damage;

            if target.specialType and target.specialType == 'DRAGON' then
                local mod = math.floor(self.baseDamage * 0.2)
                damage = self.baseDamage + math.random(-mod, mod)
            else
                damage = 1
            end

            local damageEffect = effectCreator.new('damage', user, target, damage)
            table.insert(state.effectList, damageEffect)
        end
    end
end

local function castExorcism(self, user, targets)

    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)

    for i, target in ipairs(targets) do
        if not target.isDead then

            if target.specialType and target.specialType == 'UNDEAD' then
                local chance = math.random(1, 100)
                if chance <= self.accuracy then
                    local killEffect = effectCreator.new('instakill', user, target)
                    table.insert(state.effectList, killEffect)
                else
                    local missEffect = effectCreator.new('missed', user, target)
                    table.insert(state.effectList, missEffect)
                end
            else
                local immuneEffect = effectCreator.new('immune', user, target)
                table.insert(state.effectList, immuneEffect)
            end
        end
    end
end

local function castStatusEffect(self, user, targets)

    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)

    for i, target in ipairs(targets) do
        if not target.isDead then

            local accuracy = self.accuracy
            local resistance = utils.checkResistance(self.element, target)

            if target.status[self.element] then
                local statusEffect;
                if self.element == 'DEFUP'
                or self.element == 'AGIUP'
                or self.element == 'DEFDOWN'
                or self.element == 'AGIDOWN' 
                or self.element == 'MIGHT' then
                    statusEffect = effectCreator.new('addStatChange', user, target, self.element)
                else
                    statusEffect = effectCreator.new('addStatus', user, target, self.element)
                end
                table.insert(state.effectList, statusEffect)
            else
                if resistance == 2 then 
                    local immuneEffect = effectCreator.new('immune', user, target)
                    table.insert(state.effectList, immuneEffect)
                else
                    if resistance == 1 then
                        accuracy = math.floor(accuracy / 2)
                    end

                    local chance = math.random(1, 100)
                    if chance <= accuracy then
                        if self.element == 'DEATH' then
                            local killEffect = effectCreator.new('instakill', user, target)
                            table.insert(state.effectList, killEffect)
                        else
                            local statusEffect;
                            if self.element == 'DEFUP'
                            or self.element == 'AGIUP'
                            or self.element == 'DEFDOWN'
                            or self.element == 'AGIDOWN'
                            or self.element == 'MIGHT' then
                                statusEffect = effectCreator.new('addStatChange', 
                                    user, target, self.element)
                            else
                                statusEffect = effectCreator.new('addStatus', 
                                    user, target, self.element)
                            end
                            table.insert(state.effectList, statusEffect)
                        end
                    else
                        local missEffect
                        if resistance == 1 then
                            missEffect = effectCreator.new('missedResist', user, target)
                        else
                            missEffect = effectCreator.new('missed', user, target)
                        end
                        table.insert(state.effectList, missEffect)
                    end
                end
            end
        end
    end
end

local function castGuardian(self, user, targets)
    castStatusEffect(self, user, targets)

    if user.isPartyMember then
        for i, member in ipairs(state.party) do
            utils.removeAction(member)
        end
    elseif not user.isPartyMember then
        for i, enemy in ipairs(state.enemies) do
            utils.removeAction(enemies)
        end
    end
end


local function  castHeal(self, user, targets)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)

    for i, target in ipairs(targets) do
        if not target.isDead then
            local amount
            if self.name == 'FullHeal' then
                amount = target.maxHp - target.currentHp
            else
                amount = self.healAmount
                local mod = math.floor(amount*0.2)
                amount = amount + math.random(-mod, mod)
            end

            local recoverEffect = effectCreator.new('recover', user, target, amount)
            table.insert(state.effectList, recoverEffect)
        end
    end
end

local function castRevive(self, user, targets)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)

    for i, target in ipairs(targets) do
        if not target.isDead then 
            local immuneEffect = effectCreator.new('immune', user, target)
            table.insert(state.effectList, immuneEffect)
        else
            local reviveEffect = effectCreator.new('revive', user, target, self.reviveRatio)
            table.insert(state.effectList, reviveEffect)
        end
    end
end

local function castRemoveStatus(self, user, target)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)

    for i, target in ipairs(targets) do
        if not target.isDead then
            if target.status[self.status] then
                local clear = effectCreator.new('clearStatus', user, target, self.status)
                table.insert(state.effectList, clear)
            else
                local immuneEffect = effectCreator.new('immune', user, target)
                table.insert(state.effectList, immuneEffect)
            end
        end
    end
end

local function castCleanse(self, user, targets)
    local text = ''..user.name..' casts '..self.name..'';
    utils.battleLogAdd(text)

    for i, target in ipairs(targets) do
        if not target.isDead then
            for i, status in ipairs({'POISON', 'CURSE', 'WOUND', 'SLEEP', 'CONFUSE', 'PARALYSIS'}) do
                if target.status[status] then

                    local clear = effectCreator.new('clearStatus', user, target, status)
                    table.insert(state.effectList, clear)
                end
            end
        end
    end
end

local function undo(self, user, _)
    local text = ''..user.name..' undo debuffs on itself';
    utils.battleLogAdd(text)
    user.status['DEFDOWN'] = nil
    user.defDebuff = nil
    utils.updateStatChange(user, 'def')
    user.status['AGIDOWN'] = nil
    user.agiDebuff = nil
    utils.updateStatChange(user, 'agi')
end

local function hiddenBlades(self, user, targets)
    local text = ''..user.name..' use '..self.name..'';
    utils.battleLogAdd(text)

    for i, target in ipairs(targets) do
        if not target.isDead then
            local damage = math.random(1, 10)
            local damageEffect = effectCreator.new('damage', user, target, damage)        
            table.insert(state.effectList, damageEffect)

            local resistance = utils.checkResistance('STUN', target)
            local stunChance
            if resistance == 1 then
                stunChance = math.random(1, 20)
            elseif resistance == 0 then
                stunChance = math.random(1, 10)
            end

            if resistance ~= 2 and stunChance == 1 then
                statusEffect = effectCreator.new('addStatus', user, target, 'STUN')
                table.insert(state.effectList, statusEffect)
            end    
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
    enemyAnimation = {ref = 'enemyAtk', maxTick = 8, speed = 0.08}
}

actionData['counterAtk'] = {
    execute = counterAttack, 
    cost = 0, 
    partyAnimation = {ref = 'enemyAtk', maxTick = 8, speed = 0.08}
}

actionData['defend'] = { 
    execute = defend, 
    cost = 0, 
    priority = 2
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

actionData['confused'] = {
    execute = confused
}

actionData['sleeping'] = {
    execute = sleeping
}

actionData['flameI'] = {
    name = 'Flame I', 
    magic = true,
    cost = 2, 
    desc = 'Deals small fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castDamageMagic,
    element = 'FIRE',
    baseDamage = 10
}

actionData['flameII'] = {
    name = 'Flame II', 
    magic = true,
    cost = 4, 
    desc = 'Deals medium fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castDamageMagic,
    element = 'FIRE',
    baseDamage = 40
}

actionData['flameIII'] = {
    name = 'Flame III', 
    magic = true,
    cost = 8, 
    desc = 'Deals large fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castDamageMagic,
    element = 'FIRE',
    baseDamage = 100
}

actionData['flameX'] = {
    name = 'Flame X', 
    magic = true,
    cost = 15, 
    desc = 'Deals very large fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castDamageMagic,
    element = 'FIRE',
    baseDamage = 250
}

actionData['frostI'] = {
    name = 'Frost I', 
    magic = true,
    cost = 3, 
    desc = 'Deals small ice damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castDamageMagic,
    element = 'ICE',
    baseDamage = 15
}

actionData['frostII'] = {
    name = 'Frost II', 
    magic = true,
    cost = 5, 
    desc = 'Deals medium ice damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castDamageMagic,
    element = 'ICE',
    baseDamage = 50
}

actionData['frostIII'] = {
    name = 'Frost III', 
    magic = true,
    cost = 10, 
    desc = 'Deals large ice damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castDamageMagic,
    element = 'ICE',
    baseDamage = 120
}

actionData['luminaI'] = {
    name = 'Lumina I', 
    magic = true,
    cost = 4, 
    desc = 'Deals small light damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castDamageMagic,
    element = 'LIGHT',
    baseDamage = 20
}

actionData['luminaII'] = {
    name = 'Lumina II', 
    magic = true,
    cost = 6, 
    desc = 'Deals medium light damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castDamageMagic,
    element = 'LIGHT',
    baseDamage = 80
}

actionData['luminaIII'] = {
    name = 'Lumina III', 
    magic = true,
    cost = 12, 
    desc = 'Deals large light damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castDamageMagic,
    element = 'LIGHT',
    baseDamage = 160
}

actionData['voidI'] = {
    name = 'Void I', 
    magic = true,
    cost = 4, 
    desc = 'Deals small void damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castDamageMagic,
    element = 'VOID',
    baseDamage = 20,
    variance = 0.4
}

actionData['voidII'] = {
    name = 'Void II', 
    magic = true,
    cost = 6, 
    desc = 'Deals medium void damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castDamageMagic,
    element = 'VOID',
    baseDamage = 80,
    variance = 0.4
}

actionData['voidIII'] = {
    name = 'Void III', 
    magic = true,
    cost = 12, 
    desc = 'Deals large void damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castDamageMagic,
    element = 'VOID',
    baseDamage = 160,
    variance = 0.4
}

actionData['infernoI'] = {
    name = 'Inferno I', 
    magic = true,
    cost = 4, 
    desc = 'Deals small fire damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castDamageMagic,
    element = 'FIRE',
    baseDamage = 10
}

actionData['infernoII'] = {
    name = 'Inferno II', 
    magic = true,
    cost = 8, 
    desc = 'Deals medium fire damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castDamageMagic,
    element = 'FIRE',
    baseDamage = 30
}

actionData['infernoIII'] = {
    name = 'Inferno III', 
    magic = true,
    cost = 12, 
    desc = 'Deals large fire damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castDamageMagic,
    element = 'FIRE',
    baseDamage = 80
}

actionData['blizzardI'] = {
    name = 'Blizzard I', 
    magic = true,
    cost = 3, 
    desc = 'Deals small ice damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castDamageMagic,
    element = 'ICE',
    baseDamage = 8
}

actionData['blizzardII'] = {
    name = 'Blizzard II', 
    magic = true,
    cost = 6, 
    desc = 'Deals medium ice damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castDamageMagic,
    element = 'ICE',
    baseDamage = 20
}

actionData['blizzardIII'] = {
    name = 'Blizzard III', 
    magic = true,
    cost = 10, 
    desc = 'Deals large ice damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castDamageMagic,
    element = 'ICE',
    baseDamage = 60
}

actionData['blizzardX'] = {
    name = 'Blizzard X', 
    magic = true,
    cost = 20, 
    desc = 'Deals very large ice damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castDamageMagic,
    element = 'ICE',
    baseDamage = 150
}

actionData['typhoonI'] = {
    name = 'Typhoon I', 
    magic = true,
    cost = 5, 
    desc = 'Deals small wind damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castDamageMagic,
    element = 'WIND',
    baseDamage = 15
}

actionData['typhoonII'] = {
    name = 'Typhoon II', 
    magic = true,
    cost = 9, 
    desc = 'Deals medium wind damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castDamageMagic,
    element = 'WIND',
    baseDamage = 50
}

actionData['typhoonIII'] = {
    name = 'Typhoon III', 
    magic = true,
    cost = 14, 
    desc = 'Deals large wind damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castDamageMagic,
    element = 'WIND',
    baseDamage = 100,
}

actionData['lightningI'] = {
    name = 'Lightning I', 
    magic = true,
    cost = 5, 
    desc = 'Deals small bolt damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castDamageMagic,
    element = 'BOLT',
    baseDamage = 15,
    variance = 0.4
}

actionData['lightningII'] = {
    name = 'Lightning II', 
    magic = true,
    cost = 9, 
    desc = 'Deals medium bolt damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castDamageMagic,
    element = 'BOLT',
    baseDamage = 50,
    variance = 0.4
}

actionData['lightningIII'] = {
    name = 'Lightning III', 
    magic = true,
    cost = 14, 
    desc = 'Deals large bolt damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castDamageMagic,
    element = 'BOLT',
    baseDamage = 100,
    variance = 0.4
}

actionData['auraI'] = {
    name = 'Aura I', 
    tech = true,
    cost = 0, 
    desc = 'Deals damage to all enemies using small percentage of strength',
    aim = 'enemies',
    scope = 'all',
    execute = useAura,
    element = 'AURA',
    auraRatio = 0.1
}

actionData['auraII'] = {
    name = 'Aura II', 
    tech = true,
    cost = 0, 
    desc = 'Deals damage to all enemies using medium percentage of strength',
    aim = 'enemies',
    scope = 'all',
    execute = useAura,
    element = 'AURA',
    auraRatio = 0.2
}

actionData['auraIII'] = {
    name = 'Aura III', 
    tech = true,
    cost = 0, 
    desc = 'Deals damage to all enemies using high percentage of strength',
    aim = 'enemies',
    scope = 'all',
    execute = useAura,
    element = 'AURA',
    auraRatio = 0.4
}

actionData['auraBlastI'] = {
    name = 'Aura Blast I', 
    tech = true,
    cost = 0, 
    desc = 'Deals damage to one enemies using high percentage of strength',
    aim = 'enemies',
    scope = 'single',
    execute = useAura,
    element = 'AURA',
    auraRatio = 0.8
}

actionData['auraBlastII'] = {
    name = 'Aura Blast II', 
    tech = true,
    cost = 0, 
    desc = 'Deals damage to one enemies using very high percentage of strength',
    aim = 'enemies',
    scope = 'single',
    execute = useAura,
    element = 'AURA',
    auraRatio = 1.5
}

actionData['auraCharge'] = {
    name = 'Aura Charge', 
    tech = true,
    cost = 0, 
    desc = 'Next aura magic will deal 2.5 more damage',
    aim = 'allies',
    scope = 'self',
    execute = auraCharge,
}

actionData['drainI'] = {
    name = 'Drain I', 
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

actionData['drainII'] = {
    name = 'Drain II', 
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

actionData['manaBurnI'] = {
    name = 'Mana Burn I', 
    magic = true,
    cost = 2, 
    desc = 'Reduce small amount of all enemies MP',
    aim = 'enemies',
    scope = 'all',
    execute = castManaBurn,
    element = 'MANABURN',
    baseDamage = 10,
}

actionData['manaBurnII'] = {
    name = 'Mana Burn II', 
    magic = true,
    cost = 5, 
    desc = 'Reduce large amount of all enemies MP',
    aim = 'enemies',
    scope = 'all',
    execute = castManaBurn,
    element = 'MANABURN',
    baseDamage = 25,
}

actionData['drakebaneI'] = {
    name = 'Drakebane I', 
    magic = true,
    cost = 4, 
    desc = 'Deals large damage to dragons',
    aim = 'enemies',
    scope = 'single',
    execute = castDracoBomb,
    baseDamage = 150
}

actionData['drakebaneII'] = {
    name = 'Drakebane II', 
    magic = true,
    cost = 8, 
    desc = 'Deals very large damage to dragons',
    aim = 'enemies',
    scope = 'single',
    execute = castDracoBomb,
    baseDamage = 300
}

actionData['exorciseI'] = {
    name = 'Exorcise I', 
    magic = true,
    cost = 4, 
    desc = 'High chance to instantly kill an undead enemies',
    aim = 'enemies',
    scope = 'single',
    execute = castExorcism,
    accuracy = 80
}

actionData['exorciseII'] = {
    name = 'Exorcise II', 
    magic = true,
    cost = 8, 
    desc = 'High chance to instantly kill all undead enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castExorcism,
    accuracy = 80
}

actionData['deathI'] = {
    name = 'Death I', 
    magic = true,
    cost = 5, 
    desc = 'Chance to instantly kill one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castStatusEffect,
    element = 'DEATH',
    accuracy = 30
}

actionData['deathII'] = {
    name = 'Death II', 
    magic = true,
    cost = 10, 
    desc = 'Low chance to instantly kill all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'DEATH',
    accuracy = 15
}

actionData['deathIII'] = {
    name = 'Death III', 
    magic = true,
    cost = 15, 
    desc = 'High chance to instantly kill all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'DEATH',
    accuracy = 30
}

actionData['sandstormI'] = {
    name = 'Sandstorm I', 
    magic = true,
    cost = 3, 
    desc = 'Low chance to blind all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'BLIND',
    accuracy = 50
}

actionData['sandstormII'] = {
    name = 'Sandstorm II', 
    magic = true,
    cost = 5, 
    desc = 'High chance to blind all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'BLIND',
    accuracy = 80
}

actionData['sealI'] = {
    name = 'Seal I', 
    magic = true,
    cost = 3, 
    desc = 'Low chance to seal abilities of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'SEAL',
    accuracy = 50
}

actionData['sealII'] = {
    name = 'seal II', 
    magic = true,
    cost = 5, 
    desc = 'High chance to seal abilities of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'SEAL',
    accuracy = 80
}

actionData['tremorI'] = {
    name = 'Tremor I', 
    magic = true,
    cost = 5, 
    desc = 'Low chance to stun of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'STUN',
    accuracy = 25
}

actionData['tremorII'] = {
    name = 'Tremor II', 
    magic = true,
    cost = 8, 
    desc = 'High chance to stun of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'STUN',
    accuracy = 50
}

actionData['woundI'] = {
    name = 'Wound I', 
    magic = true,
    cost = 3, 
    desc = 'Low chance to leave all enemies wounded',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'WOUND',
    accuracy = 50
}

actionData['woundII'] = {
    name = 'Wound II', 
    magic = true,
    cost = 5, 
    desc = 'High chance to leave all enemies wounded',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'WOUND',
    accuracy = 80
}

actionData['toxinI'] = {
    name = 'Toxin I', 
    magic = true,
    cost = 2, 
    desc = 'Chance to poison one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castStatusEffect,
    element = 'POISON',
    accuracy = 80
}

actionData['toxinII'] = {
    name = 'Toxin II', 
    magic = true,
    cost = 3, 
    desc = 'Low chance to poison all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'POISON',
    accuracy = 50
}

actionData['toxinIII'] = {
    name = 'Toxin III', 
    magic = true,
    cost = 5, 
    desc = 'High chance to poison all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'POISON',
    accuracy = 80
}

actionData['hexI'] = {
    name = 'Hex I', 
    magic = true,
    cost = 3, 
    desc = 'Chance to put a curse one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castStatusEffect,
    element = 'CURSE',
    accuracy = 70
}

actionData['hexII'] = {
    name = 'Hex II', 
    magic = true,
    cost = 5, 
    desc = 'Low chance to put a curse on all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'CURSE',
    accuracy = 40
}

actionData['hexIII'] = {
    name = 'Hex III', 
    magic = true,
    cost = 8, 
    desc = 'High chance to put a curse on all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'CURSE',
    accuracy = 70
}

actionData['paralyzeI'] = {
    name = 'Paralyze I', 
    magic = true,
    cost = 3, 
    desc = 'Chance to apply paralysis to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castStatusEffect,
    element = 'PARALYSIS',
    accuracy = 70
}

actionData['paralyzeII'] = {
    name = 'Paralyze II', 
    magic = true,
    cost = 5, 
    desc = 'Low chance to apply paralysis to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'PARALYSIS',
    accuracy = 40
}

actionData['paralyzeIII'] = {
    name = 'Paralyze III', 
    magic = true,
    cost = 8, 
    desc = 'High chance to apply paralysis on all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'PARALYSIS',
    accuracy = 70
}

actionData['slumberI'] = {
    name = 'Slumber I', 
    magic = true,
    cost = 4, 
    desc = 'Chance to put one enemy to sleep',
    aim = 'enemies',
    scope = 'single',
    execute = castStatusEffect,
    element = 'SLEEP',
    accuracy = 40
}

actionData['slumberII'] = {
    name = 'Slumber II', 
    magic = true,
    cost = 7, 
    desc = 'Low chance to put one all enemies to sleep',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'SLEEP',
    accuracy = 20
}

actionData['slumberIII'] = {
    name = 'Slumber III', 
    magic = true,
    cost = 10, 
    desc = 'High chance to put one all enemies to sleep',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'SLEEP',
    accuracy = 40
}

actionData['confusionI'] = {
    name = 'Confusion I', 
    magic = true,
    cost = 4, 
    desc = 'Chance to confuse one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castStatusEffect,
    element = 'CONFUSE',
    accuracy = 40
}

actionData['confusionII'] = {
    name = 'Confusion II', 
    magic = true,
    cost = 7, 
    desc = 'Low chance to confuse all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'CONFUSE',
    accuracy = 20
}

actionData['confusionIII'] = {
    name = 'Confusion III', 
    magic = true,
    cost = 10, 
    desc = 'High chance to confuse all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'CONFUSE',
    accuracy = 40
}

actionData['healI'] = {
    name = 'Heal I', 
    magic = true,
    cost = 2, 
    desc = 'Recover small amount of HP to one ally',
    aim = 'allies',
    scope = 'single',
    execute = castHeal,
    healAmount = 40
}

actionData['healII'] = {
    name = 'Heal II', 
    magic = true,
    cost = 4, 
    desc = 'Recover medium amount of HP to one ally',
    aim = 'allies',
    scope = 'single',
    execute = castHeal,
    healAmount = 100
}

actionData['healIII'] = {
    name = 'Heal III', 
    magic = true,
    cost = 6, 
    desc = 'Recover large amount of HP to one ally',
    aim = 'allies',
    scope = 'single',
    execute = castHeal,
    healAmount = 300
}

actionData['fullHeal'] = {
    name = 'Full Heal', 
    magic = true,
    cost = 10, 
    desc = 'Recover HP of one ally to full',
    aim = 'allies',
    scope = 'single',
    execute = castHeal
}

actionData['healAllI'] = {
    name = 'Heal All I', 
    magic = true,
    cost = 12, 
    desc = 'Recover medium amount of HP to all allies',
    aim = 'allies',
    scope = 'all',
    execute = castHeal,
    healAmount = 80
}

actionData['healAllII'] = {
    name = 'Heal All II', 
    magic = true,
    cost = 20, 
    desc = 'Recover large amount of HP to all allies',
    aim = 'allies',
    scope = 'all',
    execute = castHeal,
    healAmount = 250
}

actionData['neutralize'] = {
    name = 'Neutralize', 
    magic = true,
    cost = 2, 
    desc = 'Remove poison from one ally',
    aim = 'allies',
    scope = 'single',
    execute = castRemoveStatus,
    status = 'POISON'
}

actionData['neutralizeAll'] = {
    name = 'Neutralize All', 
    magic = true,
    cost = 5, 
    desc = 'Remove poison from all allies',
    aim = 'allies',
    scope = 'all',
    execute = castRemoveStatus,
    status = 'POISON'
}

actionData['purify'] = {
    name = 'Purify', 
    magic = true,
    cost = 3, 
    desc = 'Remove curse from one ally',
    aim = 'allies',
    scope = 'single',
    execute = castRemoveStatus,
    status = 'CURSE'
}

actionData['purifyAll'] = {
    name = 'Purify All', 
    magic = true,
    cost = 6, 
    desc = 'Remove curse from all allies',
    aim = 'allies',
    scope = 'all',
    execute = castRemoveStatus,
    status = 'CURSE'
}

actionData['mendAll'] = {
    name = 'Mend All', 
    magic = true,
    cost = 8, 
    desc = 'Remove wound from all allies',
    aim = 'allies',
    scope = 'all',
    execute = castRemoveStatus,
    status = 'WOUND'
}

actionData['dispel'] = {
    name = 'Dispel', 
    magic = true,
    cost = 3, 
    desc = 'Remove paralysis from one ally',
    aim = 'allies',
    scope = 'single',
    execute = castRemoveStatus,
    status = 'PARALYSIS'
}

actionData['dispelAll'] = {
    name = 'Dispel All', 
    magic = true,
    cost = 6, 
    desc = 'Remove paralysis from all allies',
    aim = 'allies',
    scope = 'all',
    execute = castRemoveStatus,
    status = 'PARALYSIS'
}

actionData['alarm'] = {
    name = 'Alarm', 
    magic = true,
    cost = 3, 
    desc = 'Awake one ally from sleep',
    aim = 'allies',
    scope = 'single',
    execute = castRemoveStatus,
    status = 'SLEEP'
}

actionData['alarmAll'] = {
    name = 'Alarm All', 
    magic = true,
    cost = 6, 
    desc = 'Awake all allies from sleep',
    aim = 'allies',
    scope = 'all',
    execute = castRemoveStatus,
    status = 'SLEEP'
}

actionData['sooth'] = {
    name = 'Sooth', 
    magic = true,
    cost = 3, 
    desc = 'Remove confusion from one ally',
    aim = 'allies',
    scope = 'single',
    execute = castRemoveStatus,
    status = 'CONFUSE'
}

actionData['soothAll'] = {
    name = 'Sooth All', 
    magic = true,
    cost = 6, 
    desc = 'Remove confusion from all allies',
    aim = 'allies',
    scope = 'all',
    execute = castRemoveStatus,
    status = 'CONFUSE'
}

actionData['cleanse'] = {
    name = 'Cleanse', 
    magic = true,
    cost = 10, 
    desc = 'Remove poison, curse, wound, paralysis, sleep and confusion from one ally',
    aim = 'allies',
    scope = 'single',
    execute = castRemoveStatus,
}

actionData['steel'] = {
    name = 'Steel', 
    magic = true,
    cost = 2, 
    desc = 'Increase the defensive power of one ally',
    aim = 'allies',
    scope = 'single',
    execute = castStatusEffect,
    element = 'DEFUP',
    accuracy = 100
}

actionData['steelAll'] = {
    name = 'Steel All', 
    magic = true,
    cost = 5, 
    desc = 'Increase the defensive power of all allies',
    aim = 'allies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'DEFUP',
    accuracy = 100
}

actionData['fleet'] = {
    name = 'Fleet', 
    magic = true,
    cost = 2, 
    desc = 'Increase the agility of one ally',
    aim = 'allies',
    scope = 'single',
    execute = castStatusEffect,
    element = 'AGIUP',
    accuracy = 100
}

actionData['fleetAll'] = {
    name = 'Fleet All', 
    magic = true,
    cost = 5, 
    desc = 'Increase the agility of all allies',
    aim = 'allies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'AGIUP',
    accuracy = 100
}

actionData['frail'] = {
    name = 'Frail', 
    magic = true,
    cost = 2, 
    desc = 'Reduce the defensive power of one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castStatusEffect,
    element = 'DEFDOWN',
    accuracy = 100
}

actionData['frail All'] = {
    name = 'Frail All', 
    magic = true,
    cost = 5, 
    desc = 'Reduce the defensive power of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'DEFDOWN',
    accuracy = 100
}

actionData['snare'] = {
    name = 'Snare', 
    magic = true,
    cost = 2, 
    desc = 'Reduce the agility of one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castStatusEffect,
    element = 'AGIDOWN',
    accuracy = 100
}

actionData['snareAll'] = {
    name = 'Snare All', 
    magic = true,
    cost = 5, 
    desc = 'Reduce the agility of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'AGIDOWN',
    accuracy = 100
}

actionData['revive'] = {
    name = 'Revive', 
    magic = true,
    cost = 25, 
    desc = 'Revive one dead ally with some HP',
    aim = 'allies',
    scope = 'dead',
    execute = castRevive,
    reviveRatio = 25
}

actionData['fullRevive'] = {
    name = 'Full Revive', 
    magic = true,
    cost = 50, 
    desc = 'Revive one dead ally with full HP',
    aim = 'allies',
    scope = 'dead',
    execute = castRevive,
    reviveRatio = 100
}

actionData['barrier'] = {
    name = 'Barrier', 
    magic = true,
    cost = 12, 
    desc = 'Summons barrier that reduce magic damage toward allies',
    aim = 'allies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'BARRIER',
    accuracy = 100
}

actionData['might'] = {
    name = 'Might', 
    magic = true,
    cost = 8, 
    desc = 'Increases the attack power of one ally',
    aim = 'allies',
    scope = 'single',
    execute = castStatusEffect,
    element = 'MIGHT',
    accuracy = 100
}

actionData['guardian'] = {
    name = 'Guardian', 
    magic = true,
    cost = 20, 
    desc = 'Protects all allies from any attacks for one turn while also disabling them',
    aim = 'allies',
    scope = 'all',
    execute = castGuardian,
    element = 'GUARDIAN',
    accuracy = 100,
    priority = 3
}

actionData['quickStrike'] = {
    name = 'Quick Strike', 
    tech = true,
    cost = 0, 
    desc = 'A fast normal attack that deals half the damage',
    aim = 'enemies',
    scope = 'single',
    execute = quickStrike,
    priority = 1
}

actionData['hiddenBlades'] = {
    name = 'Hidden Blades', 
    tech = true,
    cost = 0, 
    desc = 'Quickly throw sharp daggers to all enemies that also might stun them',
    aim = 'enemies',
    scope = 'all',
    execute = hiddenBlades,
    priority = 1
}

actionData['cover'] = {
    name = 'Cover', 
    tech = true,
    cost = 0, 
    desc = 'Cover an ally from any attack',
    aim = 'allies',
    scope = 'single',
    execute = cover,
    priority = 2
}

actionData['flameStrike'] = {
    name = 'Flame Strike', 
    tech = true,
    cost = 4, 
    desc = 'A normal attack that are imbued with fire element',
    aim = 'enemies',
    scope = 'single',
    execute = elementalStrike,
    element = 'FIRE'
}

actionData['frostStrike'] = {
    name = 'Frost Strike', 
    tech = true,
    cost = 4, 
    desc = 'A normal attack that are imbued with ice element',
    aim = 'enemies',
    scope = 'single',
    execute = elementalStrike,
    element = 'ICE'
}

actionData['ligtningStrike'] = {
    name = 'Lightning Strike', 
    tech = true,
    cost = 4, 
    desc = 'A normal attack that are imbued with bolt element',
    aim = 'enemies',
    scope = 'single',
    execute = elementalStrike,
    element = 'BOLT'
}

actionData['typhoonStrike'] = {
    name = 'Typhoon Strike', 
    tech = true,
    cost = 4, 
    desc = 'A normal attack that are imbued with wind element',
    aim = 'enemies',
    scope = 'single',
    execute = elementalStrike,
    element = 'WIND'
}

actionData['luminaStrike'] = {
    name = 'Lumina Strike', 
    tech = true,
    cost = 6, 
    desc = 'A normal attack that are imbued with light element',
    aim = 'enemies',
    scope = 'single',
    execute = elementalStrike,
    element = 'LIGHT'
}

actionData['voidStrike'] = {
    name = 'Void Strike', 
    tech = true,
    cost = 6, 
    desc = 'A normal attack that are imbued with void element',
    aim = 'enemies',
    scope = 'single',
    execute = elementalStrike,
    element = 'VOID'
}

actionData['focus'] = {
    name = 'Focus', 
    tech = true,
    cost = 0, 
    desc = 'Ensure next normal attack to not miss',
    aim = 'allies',
    scope = 'self',
    execute = focus,
}

actionData['ram'] = {
    name = 'Ram', 
    tech = true,
    cost = 0, 
    desc = 'Charges into an enemy, and take some recoil damage',
    aim = 'enemies',
    scope = 'single',
    execute = ram,
}

actionData['desperation'] = {
    name = 'Desperation', 
    tech = true,
    cost = 0, 
    desc = 'Attack that are more likely to land critical hits at low health',
    aim = 'enemies',
    scope = 'single',
    execute = desperation,
}

actionData['undo'] = {
    name = 'Undo', 
    tech = true,
    cost = 0, 
    desc = 'Remove defense and agility debuffs from self',
    aim = 'allies',
    scope = 'self',
    execute = undo,
}

return actionData;