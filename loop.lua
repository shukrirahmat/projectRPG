local state = require('state')
local utils = require('utils')
local animationCreator = require('animationCreator')
local actionCreator = require('actionCreator')
local actionData = require('actionData')
local effectCreator = require('effectCreator')
local effectData = require('effectData')
local input = require('input')

local loop = {}

local function nextPriorityIndex()
    local result
    local highestSpeed = -1

    for i, action in ipairs(state.priorityList) do
        local speed = actionData[action.ref].priority
        if speed > highestSpeed then
            highestSpeed = speed
            result = i
        end
    end

    return result
end

local function reselectDeadTarget(action)
    if #action.targets == 1 and action.targets[1].isDead 
    and actionData[action.ref].scope ~= 'dead' then
        action.targets = {utils.reselectTargetWhenDead(action.targets[1])}
    end
    
    return action
end

local function statusPass(action)
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

local function statusApply(action)
    local user = action.user

    if user.status['POISON'] then
        local rand = math.random(5, 20)
        local ratio = rand * 0.01
        local amount = math.floor(user.maxHp * ratio)
        local poisonEffect = effectCreator.new('poisonDamage', user, user, amount)
        table.insert(state.effectList, poisonEffect)
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
            table.insert(state.effectList, curseEffect)
        end
    end
end

local function statusClear(user, status, chance)
    local roll = math.random(0, 100)
    if roll <= chance then
        local clear = effectCreator.new('clearStatus', user, user, status)
        table.insert(state.effectList, clear)
    end
end

local function countDownStats(user, status)
    if user.status[status].countdown > 0 then
        user.status[status].countdown = user.status[status].countdown - 1;
    elseif user.status[status].countdown <= 0 then
        local clear = effectCreator.new('clearStatus', user, user, status)
        table.insert(state.effectList, clear)
    end
end

local function statusClearAll(action)
    local user = action.user

    if user.status['BLIND'] then
        statusClear(user,'BLIND', 10)
    end

    if user.status['SEAL'] then
        statusClear(user,'SEAL', 25)
    end

    if user.status['STUN'] then
        statusClear(user,'STUN', 50)
    end

    if user.status['DEFUP'] then
        countDownStats(user, 'DEFUP')
    end

    if user.status['AGIUP'] then
        countDownStats(user, 'AGIUP')
    end

    if user.status['DEFDOWN'] then
        countDownStats(user, 'DEFDOWN')
    end

    if user.status['AGIDOWN'] then
        countDownStats(user, 'AGIDOWN')
    end

    if user.status['BARRIER'] then
        countDownStats(user, 'BARRIER')
    end

    if user.status['MIGHT'] then
        countDownStats(user, 'MIGHT')
    end
end

function executeAction(action)
    local toAct = actionData[action.ref]
    local canAct = true

    if toAct.magic or toAct.tech then
        if action.user.currentMp >= toAct.cost and not action.user.status['SEAL'] then
            action.user.currentMp = action.user.currentMp - toAct.cost
        else
            canAct = false
        end
    end

    if canAct then
        toAct.execute(toAct, action.user, action.targets)
        if not action.user.isPartyMember and toAct.enemyAnimation then
            local aniData = toAct.enemyAnimation
            local animation = animationCreator.new(
                action.user, aniData.ref, aniData.maxTick, aniData.speed
            )
            state.animation = animation
        end
    else
        local skillCanceled = actionData['skillCanceled']
        skillCanceled.execute(skillCanceled, action.user, action.targets, toAct)
    end
end

function applyEffect(effect)

    if effect.target.status and effect.target.status['GUARDIAN'] then
        effectData['immune'].apply(effect.user, effect.target, effect.value)
        return
    end

    effectData[effect.ref].apply(effect.user, effect.target, effect.value)

    if effect.target and effect.target.isPartyMember and effectData[effect.ref].partyAnimation then
        local data = effectData[effect.ref].partyAnimation
        local animation = animationCreator.new(
            effect.target, data.ref, data.maxTick, data.speed, effect.value
        )
        state.animation = animation
    elseif effect.target 
    and not effect.target.isPartyMember and effectData[effect.ref].enemyAnimation then
        local data = effectData[effect.ref].enemyAnimation
        local animation = animationCreator.new(
            effect.target, data.ref, data.maxTick, data.speed, effect.value
        )
        state.animation = animation
    end
end

--------------------------------------------

function loop.run()

    if state.battleEnded then
        state.battleLog = {}
        if state.partyDied then
            utils.battleLogAdd('Party has been defeated')
        elseif state.allEnemyDead then
            utils.battleLogAdd('All enemy has been defeated')
        end
        state.textTimer = 0
    elseif #state.killList > 0 then
        local toKill = state.killList[1]
        table.remove(state.killList, 1)
        utils.handleDeath(toKill)

        if not toKill.isPartyMember then
            state.animation = animationCreator.new(toKill, 'enemyDied', 8, 0.05)
        end

        if state.partyDied or state.allEnemyDead then
            state.battleEnded = true
        end

    elseif #state.effectList > 0 then
        local effect = state.effectList[1]
        table.remove(state.effectList, 1)
        applyEffect(effect)

    elseif state.followUp then
        local action = state.followUp
        state.battleLog = {};

        executeAction(action)
        statusApply(action)
        statusClearAll(action)
        state.followUp = nil

    elseif #state.priorityList > 0 then
        state.battleLog = {};

        local actionIndex = nextPriorityIndex()
        local action = state.priorityList[actionIndex]
        table.remove(state.priorityList, actionIndex)

        action = reselectDeadTarget(action)
        action = statusPass(action)
        executeAction(action)

        if not state.followUp then
            statusApply(action)
            statusClearAll(action)
        end

    elseif #state.actionList > 0 then
        state.battleLog = {};
        local nextActionIndex = utils.chooseNextActionIndex()
        local action = state.actionList[nextActionIndex]
        table.remove(state.actionList, nextActionIndex)

        action = reselectDeadTarget(action)
        action = statusPass(action)
        executeAction(action)

        if not state.followUp then
            statusApply(action)
            statusClearAll(action)
        end

    else
        utils.clearTemporaryStatus()
        state.battleRunning = false
        state.textTimer = 0
        state.battleLog = {}
        state.currentMenu = state.mainMenu
        state.mainMenu.position = 1
    end
end

return loop