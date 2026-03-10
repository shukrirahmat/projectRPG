local battleHandler = {}

local function setPartyAction(state)
    for _, member in ipairs(state.party) do
        if not member.isDead then
            local action
            if member.status['STUN'] or member.status['SLEEP'] or member.status['CONFUSE'] then
                local target = battleHandler.selectTargetRandomly(state.enemies)
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
            local target = battleHandler.selectTargetRandomly(state.party)
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

                    if skill.scope == 'single' then
                        action = actionCreator.new(skillRef, enemy, {target})
                    elseif skill.scope == 'all' then
                        action = actionCreator.new(skillRef, enemy, {unpack(aoeTargets)})
                    elseif skill.scope == 'self' then
                        action = actionCreator(skillRef, enemy, {enemy})
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

function battleHandler.selectTargetRandomly(group)
    local availableTargets = {}

    for _, target in ipairs(group) do
        if not target.isDead then
            table.insert(availableTargets, target)
        end
    end

    local selectedTarget
    local i = 1

    while not selectedTarget do
        if i == #availableTargets then
            selectedTarget = availableTargets[i]
        else
            local chance = math.random(1, 10)
            if chance < 5 then
                i = i + 1
            else
                selectedTarget = availableTargets[i]
            end
        end
    end

    return selectedTarget
end

function battleHandler.removeAction(state, user)
    for i = #state.actionQueue, 1, -1 do
        if state.actionQueue[i].user == user then
            table.remove(state.actionQueue, i)
        end
    end
    for i = #state.priorityQueue, 1, -1 do
        if state.priorityQueue[i].user == user then
            table.remove(state.priorityQueue, i)
        end
    end
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

return battleHandler