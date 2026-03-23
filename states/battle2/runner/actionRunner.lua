local actionData = require('data.actionData')
local helpers = require('states.battle2.runner.helpers')
local actionCreator = require('entities.actionCreator')
local effectCreator = require('entities.effectCreator')
local animationCreator = require('entities.animationCreator')
local gameState = require('gameState')

local actionRunner = {}

local state = {}

local function getNextActionIndex()
    local index
    local highestSpeed = -1
    for i, action in ipairs(state.actionQueue) do
        local agi = action.user:getAgi()
        local mod = math.floor(agi * 0.5)
        local speed = agi + (math.random(-mod, mod))
        if speed > highestSpeed then
            highestSpeed = speed
            index = i
        end
    end
    return index
end

local function getNextPriorityIndex()
    local index
    local highestSpeed = -1

    for i, action in ipairs(state.priorityQueue) do
        local speed = actionData[action.ref].priority
        if speed > highestSpeed then
            highestSpeed = speed
            index = i
        end
    end

    return index
end

local function reselectTargetWhenDead(selectedTarget)
    local target
    if selectedTarget.isPartyMember then
        target = helpers.selectTargetRandomly(state.party)
    else
        target = helpers.selectTargetRandomly(state.enemies)
    end
    return target
end

local function redirectTarget(action)
    if #action.targets == 1 and action.targets[1].isDead 
    and actionData[action.ref].aim ~= 'allies' then
        action.targets = reselectTargetWhenDead(action.targets[1])
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

local function statusCheck(action)
    if action.user.status['SLEEP'] then
        action = actionCreator.new('sleeping', action.user)
    elseif action.user.status['STUN'] then
        action = actionCreator.new('stunned', action.user)
    elseif action.user.status['PARALYSIS'] then
        local roll = math.random(1, 4)
        if roll == 1 then 
            action = actionCreator.new('paralyzed', action.user)
        else
            if action.user.status['CONFUSE'] then
                action = actionCreator.new('confused', action.user)
            end
        end
    elseif action.user.status['CONFUSE'] then
        action = actionCreator.new('confused', action.user)
    end
    return action
end

local function runAction(action, isFollowUp)
    action = redirectTarget(action)
    action = statusCheck(action)
    local data = actionData[action.ref]
    local canAct = true
    local result = {}

    if data.magic or data.tech then
        if action.user.status['SEAL'] then
            canAct = false
        elseif isFollowUp then
            canAct = true
        elseif action.user.currentMp >= data.cost then
            action.user.currentMp = action.user.currentMp - data.cost
        else
            canAct = false
        end
    end

    if canAct then
        if action.combo then
            result = action:execute(action.user, action.targets, {combo = true})
        else
            result = action:execute(action.user, action.targets)
        end

        if action.user.usingItem then
            action.user.usingItem = nil
        end

        if not action.user.isPartyMember and data.enemyAnimation then
            local aniData = data.enemyAnimation
            local animation = animationCreator.new(
                action.user, aniData.ref, gameState.battleSpeed * aniData.speed
            )
            result.animation = animation
        elseif action.user.isPartyMember and action.ref == 'counterAtk' then
            local aniData = data.partyAnimation
            local animation = animationCreator.new(
                action.targets[1], aniData.ref, gameState.battleSpeed * aniData.speed
            )
            result.animation = animation
        end

        if data.magic then
            if action.user.passives['echoMagic'] and not isFollowUp then
                local roll = math.random(1, 4)
                if roll == 1 then
                    if result.followUp then
                        table.insert(result.followUp, action)
                    else
                        result.followUp = {table.insert(result.followUp, action)}
                    end
                end
            end
            if action.user.passives['manaSaver'] and not isFollowUp then
                local roll = math.random(1, 4)
                if roll == 1 then
                    local effect = effectCreator.new('mpRecover', action.user, action.user, data.cost)
                    table.insert(result.effect, effect)
                end
            end
        end
    else
        local skillCanceled = actionData['skillCanceled']
        local result = skillCanceled:execute(action.user, action.targets, data)
    end
    
    state.result = result
end



-----------------------------------------
----------------PUBLIC-------------------
-----------------------------------------

function actionRunner.load(actionQueue, priorityQueue)
    state.actionQueue = actionQueue
    state.priorityQueue = priorityQueue
    state.isFinished = false
end

function actionRunner.runNext()
    if #state.actionQueue == 0 and #state.priorityQueue == 0 then
        state.isFinished = true
        return
    end

    local action;
    if #state.priorityQueue > 0 then
        local index = getNextPriorityIndex()
        action = state.priorityQueue[index]
        table.remove(state.priorityQueue, index)
    elseif #state.actionQueue > 0 then
        local index = getNextActionIndex()
        action = state.actionQueue[index]
        table.remove(state.actionQueue, index)
    end

    runAction(action)
end

return actionRunner

