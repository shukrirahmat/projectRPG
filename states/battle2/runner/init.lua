local actionData = require('data.actionData')
local actionCreator = require('entities.actionCreator')
local actionRunner = require('states.battle2.runner.actionRunner')
local helpers = require('states.battle2.runner.helpers')

local runner = {}

local state = {}

local function setPartyAction(actionQueue, priorityQueue)
    for i, member in ipairs(state.party) do
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

local function setEnemyAction(actionQueue, priorityQueue)
    for i, enemy in ipairs(state.enemies) do
        local actionRef = enemy:getEnemyAction()
        local data = actionData[actionRef]
        
        local group = state.party
        if data.aim == 'allies' then
            group = state.enemies
        end
        
        local action;
        if data.scope == 'all' then
            action = actionCreator.new(actionRef, enemy, {{unpack(group)}
        elseif data.scope == 'self' then
            action = actionCreator.new(actionRef, enemy, enemy}
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

-----------------------------------------
----------------PUBLIC-------------------
-----------------------------------------

function runner.load(party, enemies)
    state.isActive = true
    state.party = party
    state.enemies = enemies

    local actionQueue = {}
    local priorityQueue = {}

    setPartyAction(actionQueue, priorityQueue)
    setEnemyAction(actionQueue, priorityQueue)
    
    actionRunner.load(actionQueue, priorityQueue)
    state.phase = 'action'
end

function runner.isActive()
    return state.isActive
end

function runner.update(dt)
    
    if state.phase = 'action' then
        actionRunner.update(dt)
        if not actionRunner.isActive() then
            state.isActive = false
        end
    end
end

return runner