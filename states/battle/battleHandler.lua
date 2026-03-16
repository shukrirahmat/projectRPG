local actionData = require('data.actionData')
local actionCreator = require('entities.actionCreator')
local battleHelpers = require('states.battle.battleHelpers')
local gameState = require('gameState')

local battleHandler = {}

local function setPartyAction(state)
    for _, member in ipairs(state.party) do
        if not member.isDead then
            local action
            if member.status['STUN'] or member.status['SLEEP'] or member.status['CONFUSE'] then
                local target = battleHelpers.selectTargetRandomly(state.enemies)
                action = actionCreator.new('normalAtk', member, {target})
            elseif member.currentAction then
                action = member.currentAction
            end
            battleHandler.sendActionIntoQueue(state, action)
            member.currentAction = nil
        end
    end
end

local function setEnemyAction(state)
    for _, enemy in ipairs(state.enemies) do
        if not enemy.isDead then
            local action
            local target = battleHelpers.selectTargetRandomly(state.party)
            if enemy.status['STUN'] or enemy.status['SLEEP'] or enemy.status['CONFUSE'] then
                action = actionCreator.new('normalAtk', enemy, {target})
            else
                local choices = {unpack(enemy.skills)}
                local rand = math.random(0, #choices or 0)
                if rand == 0 then
                    action = actionCreator.new('normalAtk', enemy, {target})
                else
                    local skillRef = choices[rand]
                    local skill = actionData[skillRef]

                    local aoeTargets;
                    if skill.aim == 'allies' then 
                        aoeTargets = state.enemies
                    elseif skill.aim == 'enemies' then
                        aoeTargets = state.party
                    end

                    if enemy.currentMp < skill.cost then
                        action = actionCreator.new('normalAtk', enemy, {target})
                    elseif skill.scope == 'single' then
                        action = actionCreator.new(skillRef, enemy, {target})
                    elseif skill.scope == 'all' then
                        action = actionCreator.new(skillRef, enemy, {unpack(aoeTargets)})
                    elseif skill.scope == 'self' then
                        action = actionCreator.new(skillRef, enemy, {enemy})
                    end
                end
            end
            battleHandler.sendActionIntoQueue(state, action)
        end
    end
end

function battleHandler.sendActionIntoQueue(state, action)
    local actionDetails = actionData[action.ref]    
    if actionDetails.priority then
        table.insert(state.priorityQueue, action)
    else
        table.insert(state.actionQueue, action)
    end
end

function battleHandler.reselectTargetWhenDead(state, selectedTarget)
    local target
    if selectedTarget.isPartyMember then
        target = battleHelpers.selectTargetRandomly(state.party)
    else
        target = battleHelpers.selectTargetRandomly(state.enemies)
    end
    return target
end

function battleHandler.checkCannotMove(target)
    if target.status['STUN'] then return true end
    if target.status['SLEEP'] then return true end
    if target.status['CONFUSE'] then return true end
    return false
end

function battleHandler.getAbleCharID(state, currentID, where)
    local nextID
    local found = false
    local outOfBound

    if where == 'next' then
        nextID = currentID + 1
        outOfBound = nextID > #state.party 
    elseif where == 'prev' then
        nextID = currentID - 1
        outOfBound = nextID < 1
    end

    while not found and not outOfBound do
        local char = state.party[nextID]
        if not char.isDead 
        and not char.status['STUN']
        and not char.status['SLEEP']
        and not char.status['CONFUSE'] then
            found = true
        else
            if where == 'next' then
                nextID = nextID + 1
                outOfBound = nextID > #state.party 
            elseif where == 'prev' then
                nextID = nextID - 1
                outOfBound = nextID < 1
            end
        end
    end

    if found then
        return nextID
    else
        return nil
    end
end

function battleHandler.runBattle(state)
    setPartyAction(state)
    setEnemyAction(state)
    state.battleRunning = true
    state.actionTimer = state.actionSpeed - 0.5
end

function battleHandler.exitBattle(state, dt)
    state.actionTimer = state.actionTimer + dt
    if state.actionTimer >= state.actionSpeed then
        for i, member in ipairs(state.party) do
            gameState.party[i].isDead = member.isDead;
            gameState.party[i].currentHp = member.currentHp
            gameState.party[i].currentMp = member.currentMp
            gameState.party[i].status['POISON'] = member.status['POISON']
            gameState.party[i].status['CURSE'] = member.status['CURSE']
            gameState.party[i].status['WOUND'] = member.status['WOUND']
            gameState.party[i].status['PARALYSIS'] = member.status['PARALYSIS']
        end

        local expGained = 0
        local goldGained = 0
        local itemDropped = {}
        for i, enemy in ipairs(state.enemies) do
            expGained = expGained + enemy.exp
            goldGained = goldGained + enemy.goldDrop

            if enemy.itemDrop then
                for k,v in pairs(enemy.itemDrop) do
                    local success = math.random(1, v) == 1
                    if success then
                        table.insert(itemDropped, {ref = k, dropper = enemy.name})
                    end
                end
            end
        end

        state.manager.switch('reward', {exp = expGained, gold = goldGained, items = itemDropped})
    end
end


return battleHandler