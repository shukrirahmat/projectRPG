local battleLog = require('states.battle.battleLog')
local battleHandler = require('states.battle.battleHandler')
local battleHelpers = require('states.battle.battleHelpers')
local animationCreator = require('entities.animationCreator')
local effectCreator = require('entities.effectCreator')
local actionCreator = require('entities.actionCreator')
local effectData = require('data.effectData')
local actionData = require('data.actionData')
local itemManager = require('systems.itemManager')

local battleLoop = {}

local function checkIfAllDead(group)
    local totalDead = 0
    for _, member in ipairs(group) do
        if member.isDead then
            totalDead = totalDead + 1
        end
    end
    return totalDead == #group;
end

local function statusApply(state, action)
    local user = action.user

    if user.status['POISON'] then
        local baseAmount = math.floor(user.maxHp * 0.1)
        local mod = math.floor(baseAmount*0.2)
        local amount = math.max(1, baseAmount + math.random(-mod, mod))
        local poisonEffect = effectCreator.new('poisonDamage', user, user, amount)
        table.insert(state.effectQueue, poisonEffect)
    end

    if user.status['CURSE'] then
        local max
        if user.isPartyMember then
            max = 20
        else
            max = 4
        end
        local roll = math.random(1, max)
        if roll == 1 then
            local curseEffect = effectCreator.new('curseEffect', user, user)
            table.insert(state.effectQueue, curseEffect)
        end
    end

    if user.passives['regenerate'] then
        local baseAmount = math.floor(user.maxHp * 0.1)
        local mod = math.floor(baseAmount*0.2)
        local amount = baseAmount + math.random(-mod, mod)
        local recoverEffect = effectCreator.new('recover', user, user, amount)
        table.insert(state.effectQueue, recoverEffect)
    end
end

local function statusClear(state, user, status, chance)
    local roll = math.random(0, 100)
    if roll <= chance then
        local clear = effectCreator.new('clearStatus', user, user, status)
        table.insert(state.effectQueue, clear)
    end
end

local function countDownStats(state, user, status)
    if user.status[status].countdown > 0 then
        user.status[status].countdown = user.status[status].countdown - 1;
    elseif user.status[status].countdown <= 0 then
        local clear = effectCreator.new('clearStatus', user, user, status)
        table.insert(state.effectQueue, clear)
    end
end

local function statusClearAll(state, action)
    local user = action.user

    local cat1 = {'BLIND', 'SEAL', 'STUN'}
    local rate = {20, 30, 60}

    for i, status in ipairs(cat1) do
        if user.status[status] then
            statusClear(state, user, status, rate[i])
        end
    end

    local cat2 = {'STEEL', 'FLEET', 'FRAIL', 'SNARE', 'BARRIER', 'MIGHT'}

    for i, status in ipairs(cat2) do
        if user.status[status] then
            countDownStats(state, user, status)
        end
    end
end

local function handleDeath(state, target)
    target.currentHp = 0
    target.isDead = true
    target.status = {}
    battleLog.addText(state, ''..target.name..' defeated.')
    battleHelpers.removeAction(state, target)

    if target.isPartyMember and checkIfAllDead(state.party) then
        state.partyDied = true
    elseif not target.isPartyMember and checkIfAllDead(state.enemies) then
        state.allEnemyDead = true
    end
end

local function handleBattleEnd(state)
    state.battleLog = {}
    if state.partyDied then
        battleLog.addText(state, 'Party has been defeated')
    elseif state.allEnemyDead then
        battleLog.addText(state, 'Battle won!')
    end
end

local function doNextKill(state)
    local toKill = state.killQueue[1]
    table.remove(state.killQueue, 1)
    handleDeath(state, toKill)
    if not toKill.isPartyMember then
        state.animation = animationCreator.new(toKill, 'enemyDied', state.actionSpeed * 0.2)
    end

    if (state.partyDied or state.allEnemyDead) then
        state.battleEnded = true
    end
    state.actionTimer = 0
end

function applyEffect(state, effect)
    if effect.target and effect.target.isInvincible then
        effectData['immune'].apply(state, effect.user, effect.target, effect.value)
        return
    end

    effectData[effect.ref].apply(state, effect.user, effect.target, effect.value)

    if effect.target and effect.target.isPartyMember and effectData[effect.ref].partyAnimation then
        local data = effectData[effect.ref].partyAnimation
        local animation = animationCreator.new(
            effect.target, data.ref, state.actionSpeed * data.speed, effect.value
            )
        state.animation = animation
    elseif effect.target and not effect.target.isPartyMember and effectData[effect.ref].enemyAnimation then
        local data = effectData[effect.ref].enemyAnimation
        local animation = animationCreator.new(
            effect.target, data.ref, state.actionSpeed * data.speed, effect.value
            )
        state.animation = animation
    end
end

local function doNextEffect(state)
    local effect = state.effectQueue[1]
    table.remove(state.effectQueue, 1)

    if not effect.target.isDead 
    or effect.ref == 'revive' 
    or effect.ref == 'stealGold' 
    or effect.ref == 'stealItem' then
        applyEffect(state, effect)
        if effect.ref == 'instakill' then
            state.actionTimer = state.actionSpeed
        else
            state.actionTimer = 0
        end
    else
        state.actionTimer = state.actionSpeed
    end 
end

function executeAction(state, action, isFollowUp)
    local toAct = actionData[action.ref]
    local canAct = true

    if toAct.magic or toAct.tech then
        if action.user.status['SEAL'] then
            canAct = false
        elseif isFollowUp then
            canAct = true
        elseif action.user.currentMp >= toAct.cost then
            action.user.currentMp = action.user.currentMp - toAct.cost
        else
            canAct = false
        end
    end

    if canAct then
        if action.combo then
            toAct.execute(toAct, state, action.user, action.targets, {combo = true})
        else
            toAct.execute(toAct, state, action.user, action.targets)
        end

        if action.user.usingItem then
            action.user.usingItem = nil
        end

        if not action.user.isPartyMember and toAct.enemyAnimation then
            local data = toAct.enemyAnimation
            local animation = animationCreator.new(
                action.user, data.ref, state.actionSpeed * data.speed
                )
            state.animation = animation
        elseif action.user.isPartyMember and action.ref == 'counterAtk' then
            local data = toAct.partyAnimation
            local animation = animationCreator.new(
                action.targets[1], data.ref, state.actionSpeed * data.speed
            )
            state.animation = animation
        end

        if toAct.magic then
            if action.user.passives['echoMagic'] and not isFollowUp then
                local roll = math.random(1, 4)
                if roll == 1 then
                    table.insert(state.followUpQueue, action)
                end
            end
            if action.user.passives['manaSaver'] and not isFollowUp then
                local roll = math.random(1, 4)
                if roll == 1 then
                    local effect = effectCreator.new('mpRecover', action.user, action.user, toAct.cost)
                    table.insert(state.effectQueue, effect)
                end
            end
        end
    else
        local skillCanceled = actionData['skillCanceled']
        skillCanceled.execute(skillCanceled, state, action.user, action.targets, toAct)
    end
end

local function redirectTarget(state, action)
    if #action.targets == 1 and action.targets[1].isDead 
    and actionData[action.ref].aim ~= 'allies' then
        action.targets = {battleHandler.reselectTargetWhenDead(state, action.targets[1])}
    end

    for i, target in ipairs(action.targets) do
        if not target.isDead and target.isCovered and actionData[action.ref].aim ~= 'allies' then
            if not target.isCovered.coveredBy.isDead then
                action.targets[i] = target.isCovered.coveredBy
            end
        end
    end
    return action
end

local function doNextFollowUp(state)
    local action = state.followUpQueue[1]
    table.remove(state.followUpQueue, 1)

    local skip
    if action.ref == 'secondAtk' or action.ref == 'counterAtk' then
        if action.targets[1].isDead or battleHandler.checkCannotMove(action.targets[1]) then
            skip = true
        else
            state.battleLog = {};
            executeAction(state, action, true)
        end
    else
        state.battleLog = {};
        action = redirectTarget(state, action)
        executeAction(state, action, true)
    end

    if #state.followUpQueue == 0 then
        statusApply(state, action)
        statusClearAll(state, action)
    end

    if skip then
        state.actionTimer = state.actionSpeed
    else
        state.actionTimer = 0
    end
end

local function nextPriorityIndex(state)
    local result
    local highestSpeed = -1

    for i, action in ipairs(state.priorityQueue) do
        local speed = actionData[action.ref].priority
        if speed > highestSpeed then
            highestSpeed = speed
            result = i
        end
    end

    return result
end

local function statusPass(state, action)
    local result = action
    if action.user.status['SLEEP'] then
        result = actionCreator.new('sleeping', action.user)
    elseif action.user.status['STUN'] then
        result = actionCreator.new('stunned', action.user)
    elseif action.user.status['PARALYSIS'] then
        local roll = math.random(1, 4)
        if roll == 1 then 
            result = actionCreator.new('paralyzed', action.user)
        else
            if action.user.status['CONFUSE'] then
                result = actionCreator.new('confused', action.user)
            end
        end
    elseif action.user.status['CONFUSE'] then
        result = actionCreator.new('confused', action.user)
    end
    return result
end

local function doNextPriorityAction(state)
    state.battleLog = {};

    local actionIndex = nextPriorityIndex(state)
    local action = state.priorityQueue[actionIndex]
    table.remove(state.priorityQueue, actionIndex)

    action = redirectTarget(state, action)
    action = statusPass(state, action)
    executeAction(state, action)

    if #state.followUpQueue == 0 then
        statusApply(state, action)
        statusClearAll(state, action)
    end
    state.actionTimer = 0
end

local function chooseNextActionIndex(state)
    local actionIndex
    local highestSpeed = -1
    for index, action in ipairs(state.actionQueue) do
        local agi = action.user.agi
        local mod = math.floor(agi*0.5)
        local speed = agi + (math.random(-mod, mod))
        if speed > highestSpeed then
            highestSpeed = speed
            actionIndex = index
        end
    end
    return actionIndex
end

local function doNextAction(state)
    state.battleLog = {};
    local nextActionIndex = chooseNextActionIndex(state)
    local action = state.actionQueue[nextActionIndex]
    table.remove(state.actionQueue, nextActionIndex)

    action = redirectTarget(state, action)
    action = statusPass(state, action)
    executeAction(state, action)

    if #state.followUpQueue == 0 then
        statusApply(state,action)
        statusClearAll(state, action)
    end
    state.actionTimer = 0
end

local function clearTemporaryStatus(state)

    state.followUpQueue = {}

    for _, group in ipairs({state.party, state.enemies}) do
        for _, character in ipairs(group) do

            if character.isDefending then
                character.isDefending = false
            end

            if character.isAuraCharged then
                character.isAuraCharged.counter = character.isAuraCharged.counter - 1
                if character.isAuraCharged.counter <= 0 then
                    character.isAuraCharged = nil
                end
            end

            if character.isFocused then
                character.isFocused.counter = character.isFocused.counter - 1
                if character.isFocused.counter <= 0 then
                    character.isFocused = nil
                end
            end

            if character.isInvincible then
                character.isInvincible = nil
            end

            if character.isCovered then
                character.isCovered = nil
            end

            if character.usingItem then
                itemManager.manageItems(character.usingItem, 1)
                character.usingItem = nil
            end
        end
    end
end

local function finishUpRound(state)
    clearTemporaryStatus(state)
    state.battleRunning = false
    state.battleLog = {}
    state.currentMenu = state.mainMenu
    state.mainMenu.position = 1
    state.actionTimer = 0
end


function battleLoop.run(state, dt)
    state.actionTimer = state.actionTimer + dt
    if state.actionTimer >= state.actionSpeed then
        if state.battleEnded and #state.effectQueue == 0 then
            handleBattleEnd(state)
        elseif #state.killQueue > 0 then
            doNextKill(state)
        elseif #state.effectQueue > 0 then
            doNextEffect(state)        
        elseif #state.followUpQueue > 0 then
            doNextFollowUp(state)
        elseif #state.priorityQueue > 0 then
            doNextPriorityAction(state)
        elseif #state.actionQueue > 0 then
            doNextAction(state)
        else
            finishUpRound(state)
        end
    end
end

return battleLoop;