local battleLog = require('states.battle.battleLog')
local effectCreator = require('entities.effectCreator')
local actionCreator = require('entities.actionCreator')
local battleHelpers = require('states.battle.battleHelpers')

local actions = {}

local function dealDamage(state, user, target, damage, ref)

    if ref ~= 'immune' then
        if target.isDefending then
            damage = math.max(math.floor(damage/2), 1)
        end

        if target.passives['lastStand'] then
            if damage >= target.currentHp and target.currentHp > 1 then
                damage = target.currentHp - 1;
            end
        end
    end

    local damageEffect = effectCreator.new(ref, user, target, damage)        
    table.insert(state.effectQueue, damageEffect)
end

local function recoverHP(state, user, target, amount)
    if target.status['WOUND'] then
        amount = math.floor(amount * 0.5)
    end    
    local recoverEffect = effectCreator.new('recover', user, target, amount)
    table.insert(state.effectQueue, recoverEffect)
end

local function calculateAttackDamage(attacker, target)    

    local pierce = 1
    if target.specialType == 'ARMORED' and attacker.passives['piercer'] then
        pierce = 2
    end

    local damage = math.floor(attacker.atk/2) - math.floor(target.def/(3 * pierce))
    local mod = math.floor(damage*0.2)
    damage = damage + math.floor(math.random(-mod, mod))
    return math.max(damage, 1)
end

local function calculateCritDamage(attacker, target)

    local pierce = 1
    if target.specialType == 'ARMORED' and attacker.passives['piercer'] then
        pierce = 2
    end

    local damage = math.floor(attacker.atk/2 * 3) - math.floor(target.def/(6 * pierce))
    local mod = math.floor(damage*0.2)
    damage = damage + math.floor(math.random(-mod, mod))
    return math.max(damage, 1)
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

local function checkResistance(element, target)
    if target.immune[element] then return 2 end
    if target.strong[element] then return 1 end
    return 0
end

local function checkMiss(user, target)
    if user.status['BLIND'] then
        local roll = math.random(1, 100)
        if roll <= 70 then
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

local function handleExecutor(user, target)
    if user.passives['executor'] then
        local ref = checkResistance('DEATH', target)
        local accuracy
        if ref == 0 then 
            accuracy = 20
        elseif ref == 1 then
            accuracy = 5
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

local function handleSteal(state, user, target)

    if user.isPartyMember and target.isPartyMember then
        return
    end

    if not user.isPartyMember and not target.isPartyMember then
        return
    end

    if user.passives['pincher'] then
        local baseAmount = user.lvl * 5
        local mod = math.floor(baseAmount * 0.5)
        local amount = baseAmount + math.random(-mod, mod)
        local stealEffect = effectCreator.new('stealGold', user, target, amount)
        table.insert(state.effectQueue, stealEffect)
    end

    --PARTY EXCLUSIVES
    if user.passives['snatcher'] then
        if target.stealableItem then
            local roll = math.random(1, target.stealableItem.rate)
            if roll == 1 then
                local stealEffect = effectCreator.new('stealItem', user, target, target.stealableItem.item)
                table.insert(state.effectQueue, stealEffect)
            end
        end
    end
end

local function handleOnHitEffects(state, user, target)
    local psv = {'basher'}
    local status = {'STUN'}

    for i = 1, #psv do
        local p = psv[i]
        if user.passives[p] then
            local ref = checkResistance(status[i], target)
            local accuracy
            if ref == 0 then 
                accuracy = 25
            elseif ref == 1 then
                accuracy = 10
            elseif ref == 2 then
                accuracy = 0
            end
            local roll = math.random(1, 100)
            if roll <= accuracy then
                statusEffect = effectCreator.new('addStatus', user, target, status[i])
                table.insert(state.effectQueue, statusEffect)
            end
        end
    end
end

local function handleElementalCombo(state, user, target)

    if user.passives['fireCombo'] then
        local followUp;
        local roll = math.random(1, 100)
        if roll <= 10 then
            followUp = actionCreator.new('flameII', user, {target})
        else
            followUp = actionCreator.new('flameI', user, {target})
        end
        followUp.combo = true
        table.insert(state.followUpQueue, 1, followUp)
    end

    if user.passives['iceCombo'] then
        local followUp;
        local roll = math.random(1, 100)
        if roll <= 5 then
            followUp = actionCreator.new('frostII', user, {target})
        else
            followUp = actionCreator.new('frostI', user, {target})
        end
        followUp.combo = true
        table.insert(state.followUpQueue, 1, followUp)
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
        table.insert(state.followUpQueue, 1, followUp)
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
        table.insert(state.followUpQueue, 1, followUp)
    end
end

local function handleCounterAttack(state, user, target)
    if not user.passives['ranged'] then
        local countering = false
        if target.passives['counterII'] then
            countering = true
        elseif target.passives['counterI'] then
            countering = math.random(1, 2) == 1
        end
        
        if not countering then return end
        
        if not target.status['SLEEP'] and not target.status['CONFUSE'] and not target.status['STUN'] then
            local counterAction = actionCreator.new('counterAtk', user, {target})
            table.insert(state.followUpQueue, counterAction)
        end
    end
end

local function handleSecondAttack(state, user, target)
    local secondAttackChance = math.floor((user.agi - target.agi)/2)
    local secondAttack
    if user.passives['dualWielder'] then
        secondAttack = true
    else
        secondAttack = math.random(1, 100) < secondAttackChance
    end

    if secondAttack then
        local followUp = actionCreator.new('secondAtk', user, {target})
        table.insert(state.followUpQueue, followUp)
    end
end

function actions.normalAttack(self, state, user, targets, special)

    for i, target in ipairs(targets) do
        if not target.isDead then
            local damage;
            local text;
            local miss;
            local resisted;
            local crit;

            if special then
                text = ''..user.name..' '..special.text..''
            else
                text = ''..user.name..' attacks!'
            end

            miss = checkMiss(user, target)

            if not miss or user.isFocused then
                if handleExecutor(user, target) then
                    battleLog.addText(state, text)
                    local killEffect = effectCreator.new('instakill', user, target)
                    table.insert(state.effectQueue, killEffect)
                    handleSteal(state, user, target)
                    return
                end

                if special and special.cat == 'desperation' then
                    if (user.currentHp/user.maxHp) <= 0.2 then
                        crit = math.random(1, 4) < 4
                    else
                        crit = false
                    end
                    if not crit then
                        battleLog.addText(state, text)
                        local immuneEffect = effectCreator.new('immune', user, target, damage)        
                        table.insert(state.effectQueue, immuneEffect)
                        return
                    end
                else
                    crit = math.random(1, user.critRate) == 1
                end

                if crit then
                    damage = calculateCritDamage(user, target)
                    text = ''..text..' Critical hit!';
                else
                    damage = calculateAttackDamage(user, target)
                end

                if special and special.cat == 'quickStrike' then
                    damage = math.floor(damage * 0.5)
                end

                if special and special.cat == 'elemental' then
                    local res = checkResistance(special.element, target)
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
                        battleLog.addText(state, text)
                        local immuneEffect = effectCreator.new('immune', user, target, damage)        
                        table.insert(state.effectQueue, immuneEffect)
                        return
                    end
                end

                battleLog.addText(state, text)

                if resisted then
                    dealDamage(state, user, target, damage, 'resisted')
                else
                    dealDamage(state, user, target, damage, 'damage')
                end

                handleOnHitEffects(state, user, target)
                handleSteal(state, user, target)
                handleElementalCombo(state, user, target)

                if not special then
                    handleCounterAttack(state, user, target)
                    handleSecondAttack(state, user, target)
                elseif special and special.cat ~= 'counter' then
                    handleCounterAttack(state, user, target)
                end
            else
                battleLog.addText(state, text)
                local missedEffect = effectCreator.new('missed', user, target)
                table.insert(state.effectQueue, missedEffect)

                if not special then
                    handleSecondAttack(state, user, target)
                end
            end
        end
    end
end

function actions.secondAttack(self, state, user, targets)
    local special = {cat ='secondAttack', text = 'attacks again!'}
    actions.normalAttack(self, state, user, targets, special)
end

function actions.counterAttack(self, state, user, targets)
    local special = {cat ='counter', text = 'counters!'}
    actions.normalAttack(self, state, targets[1], {user}, special)
end

function actions.quickStrike(self, state, user, targets)
    local special = {cat ='quickStrike', text = 'attacks swiftly!'}
    actions.normalAttack(self, state, user, targets, special)
end

function actions.elementalStrike(self, state, user, targets)
    local special = {cat = 'elemental', element = self.element, text = 'used '..self.name..''}
    actions.normalAttack(self, state, user, targets, special)
end

function actions.desperation(self, state, user, targets)
    local special = {cat = 'desperation', text = 'tries a desperation attack!'}
    actions.normalAttack(self, state, user, targets, special)
end

function actions.stunned(self, state, user)
    local text = ''..user.name..' is stunned and could not move!';
    battleLog.addText(state, text)
end

function actions.paralyzed(self, state, user)
    local text = "Paralysis disrupted "..user.name.."'s action!";
    battleLog.addText(state, text)
end

function actions.sleeping(self, state, user)
    local text = ''..user.name..' is sleeping soundly!';
    battleLog.addText(state, text)
end

function actions.confused(self, state, user)

    local textList = {
        'is rolling on the ground laughing.',
        'is dancing happily.',
        'is crying for no apparent reason.',
        'pretends to be dead.',
        "picks at it's nose",
    }

    local target
    local roll = math.random(1,5)
    if roll == 1 then
        local textRoll = math.random(1, #textList)
        local text = ''..user.name..' '..textList[textRoll]..'';
        battleLog.addText(state, text)
    elseif roll == 2 then
        target = battleHelpers.selectTargetRandomly(battleHelpers.getOppositeGroup(state, user))
        actions.normalAttack(self, state, user, {target}, 
            {cat = 'confused', text = 'attacks while being confused!'})
    elseif roll >= 3 then
        target = battleHelpers.selectTargetRandomly(battleHelpers.getOwnGroup(state, user))
        actions.normalAttack(self, state, user, {target}, 
            {cat = 'confused', text = 'attacks while being confused!'})
    end
end

function actions.noAction(self, state, user)
end

function actions.skillCanceled(self, state, user, targets, skill)
    local text
    if skill.magic then
        text = ''..user.name..' casts '..skill.name..'';
    else
        text = ''..user.name..' tried to used '..skill.name..'';
    end
    battleLog.addText(state, text)
    local noSkilleffect = effectCreator.new('skillCanceled', user, user)
    table.insert(state.effectQueue, noSkilleffect)
end

function actions.defend(self, state, user)
    user.isDefending = true
    battleLog.addText(state, ''..user.name..' defends!')
end

function actions.focus(self, state, user)
    local text = ''..user.name..' increases their focus';
    battleLog.addText(state, text)
    user.isFocused = { counter = 2 }
end

function actions.castDamageMagic(self, state, user, targets, special)

    local text = ''..user.name..' casts '..self.name..'';
    if special and special.combo then
        text = 'Unleashed '..self.name..'';
    end
    battleLog.addText(state, text)

    for i, target in ipairs(targets) do
        if not target.isDead then
            local var = self.variance or 0.2
            local mod = math.floor(self.baseDamage * var)
            local damage = self.baseDamage + math.random(-mod, mod)
            local resistance = checkResistance(self.element, target)
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
            dealDamage(state, user, target, damage, ref)
        end
    end
end

function actions.useAura(self, state, user, targets)

    local text = ''..user.name..' uses '..self.name..'';
    battleLog.addText(state, text)

    for i, target in ipairs(targets) do
        if not target.isDead then

            local baseDamage = math.floor(user.str * self.auraRatio)
            local mod = math.floor(baseDamage * 0.2)
            local damage = baseDamage + math.random(-mod, mod)

            if user.isAuraCharged then
                damage = math.floor(damage * 2.5)
            end

            local resistance = checkResistance(self.element, target)
            local ref
            if resistance == 2 then 
                ref = 'immune'
            elseif resistance == 1 then
                ref = 'resisted'
                damage = math.floor(damage/2)
            else
                ref = 'damage'
            end

            dealDamage(state, user, target, damage, ref)
        end
    end
end

function actions.auraCharge(self, state, user)
    local text = ''..user.name..' charged itself';
    battleLog.addText(state, text)
    user.isAuraCharged = { counter = 2 }
end

function actions.castDrain(self, state, user, targets)
    local text = ''..user.name..' casts '..self.name..'';
    battleLog.addText(state, text)

    for i, target in ipairs(targets) do
        if not target.isDead then

            local hpBonus = math.floor(user.maxHp * self.drainBonus)
            local baseDamage = self.baseDamage + hpBonus
            local mod = math.floor(baseDamage * 0.2)

            local damage = baseDamage + math.random(-mod, mod)
            local resistance = checkResistance(self.element, target)
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
            dealDamage(state, user, target, damage, ref)

            if ref ~= 'immune' then
                local amount = math.min(damage, target.currentHp)
                recoverHP(state, user, user, amount)
            end
        end
    end
end

function actions.castManaBurn(self, state, user, targets)
    local text = ''..user.name..' casts '..self.name..'';
    battleLog.addText(state, text)

    for i, target in ipairs(targets) do
        if not target.isDead then

            local mod = math.floor(self.baseDamage * 0.2)
            local burnAmount = self.baseDamage + math.random(-mod, mod)
            local resistance = checkResistance(self.element, target)
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
            table.insert(state.effectQueue, damageEffect)
        end
    end
end

function actions.castDrakebane(self, state, user, targets)
    local text = ''..user.name..' casts '..self.name..'';
    battleLog.addText(state, text)

    for i, target in ipairs(targets) do 
        if not target.isDead then

            local damage;
            if target.specialType and target.specialType == 'DRAGON' then
                local mod = math.floor(self.baseDamage * 0.2)
                damage = self.baseDamage + math.random(-mod, mod)
            else
                damage = 1
            end

            dealDamage(state, user, target, damage, 'damage')
        end
    end
end

function actions.castExorcise(self, state, user, targets)

    local text = ''..user.name..' casts '..self.name..'';
    battleLog.addText(state, text)

    for i, target in ipairs(targets) do
        if not target.isDead then

            if target.specialType and target.specialType == 'UNDEAD' then
                local chance = math.random(1, 100)
                if chance <= self.accuracy then
                    local killEffect = effectCreator.new('instakill', user, target)
                    table.insert(state.effectQueue, killEffect)
                else
                    local missEffect = effectCreator.new('missed', user, target)
                    table.insert(state.effectQueue, missEffect)
                end
            else
                local immuneEffect = effectCreator.new('immune', user, target)
                table.insert(state.effectQueue, immuneEffect)
            end
        end
    end
end

function actions.castStatusEffect(self, state, user, targets)

    local text = ''..user.name..' casts '..self.name..'';
    battleLog.addText(state, text)

    if self.scope == 'single' and self.aim == 'allies' and targets[1].isDead then
        local effect = effectCreator.new('nothing', user, user)
        table.insert(state.effectQueue, effect)
        return
    end

    for i, target in ipairs(targets) do
        if not target.isDead then

            local accuracy = self.accuracy
            local resistance = checkResistance(self.element, target)
            if resistance == 2 then 
                local immuneEffect = effectCreator.new('immune', user, target)
                table.insert(state.effectQueue, immuneEffect)
            else
                if resistance == 1 then
                    accuracy = math.floor(accuracy / 2)
                end

                local chance = math.random(1, 100)
                if chance <= accuracy then
                    if self.element == 'DEATH' then
                        local killEffect = effectCreator.new('instakill', user, target)
                        table.insert(state.effectQueue, killEffect)
                    else
                        local statusEffect;
                        if self.element == 'STEEL'
                        or self.element == 'FLEET'
                        or self.element == 'FRAIL'
                        or self.element == 'SNARE'
                        or self.element == 'MIGHT' then
                            statusEffect = effectCreator.new('addStatChange', 
                                user, target, self.element)
                        else
                            statusEffect = effectCreator.new('addStatus', 
                                user, target, self.element)
                        end
                        table.insert(state.effectQueue, statusEffect)
                    end
                else
                    local missEffect
                    if resistance == 1 then
                        missEffect = effectCreator.new('missedResist', user, target)
                    else
                        missEffect = effectCreator.new('missed', user, target)
                    end
                    table.insert(state.effectQueue, missEffect)
                end
            end
        end
    end
end

function actions.castHeal(self, state, user, targets)
    local text = ''..user.name..' casts '..self.name..'';
    battleLog.addText(state, text)

    if self.scope == 'single' and targets[1].isDead then
        local effect = effectCreator.new('nothing', user, user)
        table.insert(state.effectQueue, effect)
        return
    end

    for i, target in ipairs(targets) do
        if not target.isDead then
            local amount
            if self.healAmount == 999 then
                amount = target.maxHp - target.currentHp
            else
                amount = self.healAmount
                local mod = math.floor(amount * 0.2)
                amount = amount + math.random(-mod, mod)
            end

            recoverHP(state, user, target, amount)
        end
    end
end

function actions.castRemoveStatus(self, state, user, targets)
    local text = ''..user.name..' casts '..self.name..'';
    battleLog.addText(state, text)

    if self.scope == 'single' and targets[1].isDead then
        local effect = effectCreator.new('nothing', user, user)
        table.insert(state.effectQueue, effect)
        return
    end

    for i, target in ipairs(targets) do
        if not target.isDead then
            if target.status[self.status] then
                local clear = effectCreator.new('clearStatus', user, target, self.status)
                table.insert(state.effectQueue, clear)
            else
                local immuneEffect = effectCreator.new('immune', user, target)
                table.insert(state.effectQueue, immuneEffect)
            end
        end
    end
end

function actions.castCleanse(self, state, user, targets)
    local text = ''..user.name..' casts '..self.name..'';
    battleLog.addText(state, text)

    if self.scope == 'single' and targets[1].isDead then
        local effect = effectCreator.new('nothing', user, user)
        table.insert(state.effectQueue, effect)
        return
    end

    for i, target in ipairs(targets) do
        if not target.isDead then
            for i, status in ipairs({'POISON', 'CURSE', 'WOUND', 'SLEEP', 'CONFUSE', 'PARALYSIS'}) do
                if target.status[status] then
                    local clear = effectCreator.new('clearStatus', user, target, status)
                    table.insert(state.effectQueue, clear)
                end
            end
        end
    end
end

function actions.castRevive(self, state, user, targets)
    local text = ''..user.name..' casts '..self.name..'';
    battleLog.addText(state, text)

    for i, target in ipairs(targets) do
        if not target.isDead then 
            local immuneEffect = effectCreator.new('immune', user, target)
            table.insert(state.effectQueue, immuneEffect)
        else
            local percentage = 100
            if self.reviveRatio < 100 then
                percentage = math.random(1, self.reviveRatio)
            end

            local amount = math.floor(target.maxHp * percentage * 0.01)
            local reviveEffect = effectCreator.new('revive', user, target, amount)
            table.insert(state.effectQueue, reviveEffect)
        end
    end
end

function actions.castGuardian(self, state, user, targets)
    local text = ''..user.name..' casts '..self.name..'';
    battleLog.addText(state, text)

    if user.isPartyMember then
        for i, member in ipairs(state.party) do
            member.isInvincible = true
            battleHelpers.removeAction(state, member)
        end
    elseif not user.isPartyMember then
        for i, enemy in ipairs(state.enemies) do
            enemy.isInvincible = true
            battleHelpers.removeAction(state, enemy)
        end
    end
end

function actions.cover(self, state, user, targets)
    for i, target in ipairs(targets) do
        if not target.isDead then
            if target == user then
                battleLog.addText(state,''..user.name..' covers itself from attacks!')
            else
                target.isCovered = { coveredBy = user }
                battleLog.addText(state,''..user.name..' covers '..target.name..' from attacks!')
            end
        end
    end
end

function actions.ram(self, state, user, targets)
    for i, target in ipairs(targets) do
        if not target.isDead then
            battleLog.addText(state,''..user.name..' rams into '..target.name..'!')
            local baseDamage = math.floor(user.currentHp*0.6) - math.floor(target.def/3)
            local mod = math.floor(baseDamage*0.2)
            local damage = math.max(1, baseDamage + math.random(-mod, mod))
            dealDamage(state, user, target, damage, 'damage')

            local ownDamage = math.floor(user.currentHp*0.2)
            local ownMod = math.floor(ownDamage*0.2)
            local recoil = math.max(1, ownDamage + math.random(-ownMod, ownMod))
            dealDamage(state, user, user, recoil, 'damage')
        end
    end
end

function actions.undo(self, state, user, target)
    local text = ''..user.name..' undo debuffs on itself';
    battleLog.addText(state, text)
    user.status['FRAIL'] = nil
    user.defDebuff = nil
    battleHelpers.updateStatChange(user, 'def')
    user.status['SNARE'] = nil
    user.agiDebuff = nil
    battleHelpers.updateStatChange(user, 'agi')
end

function actions.useTonic(self, state, user, targets)
    local text = ''..user.name..' used '..self.name..'';
    battleLog.addText(state, text)
    
    if self.scope == 'single' and targets[1].isDead then
        local effect = effectCreator.new('nothing', user, user)
        table.insert(state.effectQueue, effect)
        return
    end

    for i, target in ipairs(targets) do
        if not target.isDead then
            local amount
            if self.healAmount == 999 then
                amount = target.maxHp - target.currentHp
            else
                amount = self.healAmount
            end

            recoverHP(state, user, target, amount)
        end
    end
end

function actions.useNectar(self, state, user, targets)
    local text = ''..user.name..' used '..self.name..'';
    battleLog.addText(state, text)
    
    if self.scope == 'single' and targets[1].isDead then
        local effect = effectCreator.new('nothing', user, user)
        table.insert(state.effectQueue, effect)
        return
    end

    for i, target in ipairs(targets) do
        if not target.isDead then
            local amount
            amount = self.mpHealAmount

            local recoverEffect = effectCreator.new('mpRecover', user, target, amount)
            table.insert(state.effectQueue, recoverEffect)
        end
    end
end

function actions.useStatusRecovery(self, state, user, targets)
    local text = ''..user.name..' used '..self.name..'';
    battleLog.addText(state, text)
    
    if self.scope == 'single' and targets[1].isDead then
        local effect = effectCreator.new('nothing', user, user)
        table.insert(state.effectQueue, effect)
        return
    end

    for i, target in ipairs(targets) do
        if not target.isDead then
            if target.status[self.status] then
                local clear = effectCreator.new('clearStatus', user, target, self.status)
                table.insert(state.effectQueue, clear)
            else
                local immuneEffect = effectCreator.new('immune', user, target)
                table.insert(state.effectQueue, immuneEffect)
            end
        end
    end
end

return actions;