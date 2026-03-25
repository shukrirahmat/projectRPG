local actionData = require('data.actionData')
local actionCreator = require('entities.actionCreator')
local actionHandler = require('states.battle2.runner.actionHandler')
local effectHandler = require('states.battle2.runner.effectHandler')
local killHandler = require('states.battle2.runner.killHandler')
local turnEndHandler = require('states.battle2.runner.turnEndHandler')
local animation = require('states.battle2.runner.animation')
local helpers = require('states.battle2.runner.helpers')
local logger = require('states.battle2.logger')


local runner = {}

local state = {}

local function setPartyAction(actionQueue, priorityQueue)
    for i, member in ipairs(state.party) do
        if not member.isDead then
            if member.currentAction then
                if actionData[member.currentAction.ref].priority then
                    table.insert(priorityQueue, member.currentAction)
                else
                    table.insert(actionQueue, member.currentAction)
                end
                member.currentAction = nil
            else
                local noAction = actionCreator.new('noAction', member, {member})
                table.insert(actionQueue, noAction)
            end
        end
    end
end

local function setEnemyAction(actionQueue, priorityQueue)
    for i, enemy in ipairs(state.enemies) do
        if not enemy.isDead then
            local actionRef = enemy:getEnemyAction()
            local data = actionData[actionRef]

            local group = state.party
            if data.aim == 'allies' then
                group = state.enemies
            end

            local action;
            if data.scope == 'all' then
                action = actionCreator.new(actionRef, enemy, {unpack(group)})
            elseif data.scope == 'self' then
                action = actionCreator.new(actionRef, enemy, enemy)
            elseif data.scope == 'single' then
                local target = helpers.selectTargetRandomly(group)
                action = actionCreator.new(actionRef, enemy, {target})
            elseif data.scope == 'dead' then
                local target = helpers.getDeadTarget(group)
                if target then
                    action = actionCreator.new(actionRef, enemy, {target})
                else
                    action = actionCreator.new('noAction', enemy, {enemy})
                end
            end

            if data.priority then
                table.insert(priorityQueue, action)
            else
                table.insert(actionQueue, action)
            end
        end
    end
end

local function isAllEnemyDead()
    local total = 0
    
    for i, enemy in ipairs(state.enemies) do
        if enemy.isDead then
            total = total + 1
        end
    end
    
    return total >= #state.enemies 
end

-----------------------------------------
----------------PUBLIC-------------------
-----------------------------------------

function runner.load(party, enemies)
    state.isActive = true
    state.enemyDefeated = false
    
    state.party = party
    state.enemies = enemies

    local actionQueue = {}
    local priorityQueue = {}

    setPartyAction(actionQueue, priorityQueue)
    setEnemyAction(actionQueue, priorityQueue)

    actionHandler.load(actionQueue, priorityQueue, party, enemies)
    effectHandler.load()
    killHandler.load()
    
    state.phase = 'action'
end

function runner.isActive()
    return state.isActive
end

function runner.isEnemyDefeated()
    return state.enemyDefeated
end

function runner.update(dt)

    if state.phase == 'action' then
        actionHandler.runNext()
        if actionHandler.isFinished() then
            state.isActive = false
        else
            local result = actionHandler.getResult()
            
            turnEndHandler.load(result.user)
            
            if result.text then
                logger.load(result.text)
            end

            if result.animation then
                animation.load(result.animation)
            end

            if result.effects then
                effectHandler.add(result.effects)
            end
            
            if result.followUps then
                actionHandler.addFollowUp(result.followUps)
            end
            
            state.phase = 'actionDisplay'
        end
    end

    if state.phase == 'actionDisplay' then
        logger.update(dt)
        animation.update(dt)
        if not logger.isActive() and not animation.isActive() then
            state.phase = 'effect'
        end
    end

    if state.phase == 'effect' then
        effectHandler.runNext()
        if effectHandler.isFinished() then
            if isAllEnemyDead() then
                state.isActive = false
                state.enemyDefeated = true
            elseif actionHandler.checkedFollowUps() then
                state.phase = 'action'
            else
                state.phase = 'followUp'
            end
        else
            local result = effectHandler.getResult()
            if result.text then
                logger.add(result.text)
            end

            if result.animation then
                animation.load(result.animation)
            end

            if result.effects then
                effectHandler.add(result.effects)
            end

            if result.kill then
                killHandler.add(result.kill)
            end

            state.phase = 'effectDisplay'
        end
    end

    if state.phase == 'effectDisplay' then
        logger.update(dt)
        animation.update(dt)
        if not logger.isActive() and not animation.isActive() then
            state.phase = 'kill'
        end
    end

    if state.phase == 'kill' then
        killHandler.killNext()
        if killHandler.isFinished() then
            state.phase = 'effect'
        else
            local result = killHandler.getResult()
            logger.add(result.text)
            animation.load(result.animation)
            actionHandler.removeAction(result.target)
            state.phase = 'killDisplay'
        end
    end

    if state.phase == 'killDisplay' then
        logger.update(dt)
        animation.update(dt)
        if not logger.isActive() and not animation.isActive() then
            state.phase = 'effect'
        end
    end
    
    if state.phase == 'followUp' then
        actionHandler.runNextFollowUp()
        if actionHandler.checkedFollowUps() then
            state.phase = 'turnEnd'
        else
            local result = actionHandler.getResult()
            if result.text then
                logger.load(result.text)
            end

            if result.animation then
                animation.load(result.animation)
            end

            if result.effects then
                effectHandler.add(result.effects)
            end
            
            if result.followUps then
                actionHandler.addFollowUp(result.followUps)
            end
            
            state.phase = 'followUpDisplay'
        end
    end
    
    if state.phase == 'followUpDisplay' then
        logger.update(dt)
        animation.update(dt)
        if not logger.isActive() and not animation.isActive() then
            state.phase = 'effect'
        end
    end
    
    if state.phase == 'turnEnd' then
        turnEndHandler.run()
        if turnEndHandler.isFinished() then
            local result = turnEndHandler.getResult()
            if result.effects then
                effectHandler.add(result.effects)
            end
            state.phase = 'effect'
        end
    end

end

return runner