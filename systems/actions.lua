local battleLog = require('states.battle.battleLog')
local effectCreator = require('entities.effectCreator')
local actionCreator = require('entities.actionCreator')

local actions = {}

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

local function checkResistance(element, target)
    if target.immune[element] then return 2 end
    if target.strong[element] then return 1 end
    return 0
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
        local followUp = actionCreator.new('flameI', user, {target})
        followUp.combo = true
        table.insert(state.followUpQueue, followUp)
    end

    if user.passives['iceCombo'] then
        local followUp = actionCreator.new('frostI', user, {target})
        followUp.combo = true
        table.insert(state.followUpQueue, followUp)
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
        table.insert(state.followUpQueue, followUp)
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
        table.insert(state.followUpQueue, followUp)
    end
end

local function handleCounterAttack(state, user, target)
    if target.passives['counter'] and not user.passives['ranged'] then
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
                    local resistedEffect = effectCreator.new('resisted', user, target, damage)        
                    table.insert(state.effectQueue, resistedEffect)
                else
                    local damageEffect = effectCreator.new('damage', user, target, damage)        
                    table.insert(state.effectQueue, damageEffect)
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

function actions.stunned(self, state,user)
    local text = ''..user.name..' is stunned and could not move!';
    battleLog.addText(state, text)
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

return actions;