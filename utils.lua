local state = require('state')

local U = {}

-----MENU RELATED HELPERS-----

function U.updateTargetMenu(prevMenu, group)
    local targetList = {}
    for _, target in ipairs(group) do
        if not target.isDead then
            table.insert(targetList, target)
        end
    end
    state.targetMenu.list = targetList
    state.targetMenu.prevMenu = prevMenu
end

function U.menuReset(menu)
    menu.position = 1
end

function U.menuUp(menu)
    if menu.position > 1 then
        menu.position = menu.position - 1
    end
end

function U.menuDown(menu)
    if menu.position < #menu.list then
        menu.position = menu.position + 1
    end
end

function U.getAbleCharID(currentID, where)
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
        if not state.party[nextID].isDead then
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

------------HANDLING BATTLES----------------

function U.battleLogAdd(text)
    if #state.battleLog >= 8 then
        table.remove(state.battleLog, 1)
    end

    table.insert(state.battleLog, text)
end

function U.selectTargetRandomly(group)
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

function U.chooseNextActionIndex()
    local actionIndex
    local highestSpeed = 0
    for index, action in ipairs(state.actionList) do
        local agi = action.user.agi
        local speed = agi + math.floor(math.random(-agi*0.5, agi*0.5))
        if speed > highestSpeed then
            highestSpeed = speed
            actionIndex = index
        end
    end
    return actionIndex
end

function U.reselectTargetWhenDead(selectedTarget)
    local target
    if selectedTarget.isPartyMember then
        target = U.selectTargetRandomly(state.party)
    else
        target = U.selectTargetRandomly(state.enemies)
    end
    return target
end

local function checkIfAllDead(group)
    local totalDead = 0
    for _, member in ipairs(group) do
        if member.isDead then
            totalDead = totalDead + 1
        end
    end
    return totalDead == #group;
end

local function removeAction(user)
    for index, action in ipairs(state.actionList) do
        if action.user == user then
            table.remove(state.actionList, index)
        end
    end
end

function U.handleDeath(target)
    target.currentHp = 0
    target.isDead = true
    U.battleLogAdd(''..target.name..' defeated.')
    removeAction(target)
    
    if state.priorityList[1] and state.priorityList[1].ref == 'secondAtk' then
        table.remove(state.priorityList, 1)
    end

    if target.isPartyMember and checkIfAllDead(state.party) then
        state.partyDied = true
    elseif not target.isPartyMember and checkIfAllDead(state.enemies) then
        state.allEnemyDead = true
    end
end

function U.clearTemporaryStatus()
    for _, group in ipairs({state.party, state.enemies}) do
        for _, character in ipairs(group) do
            if character.isDefending then
                character.isDefending = false
            end
        end
    end
end

function U.sentActionIntoQueue(action)
    if action.checkPriority() then
        table.insert(state.priorityList, action)
    else
        table.insert(state.actionList, action)
    end
end

local function setPartyAction()
    for _, member in ipairs(state.party) do
        if not member.isDead and member.currentAction then
            local action = member.currentAction
            U.sentActionIntoQueue(action)
            member.currentAction = nil
        end
    end
end

local function setEnemyAction()
    for _, enemy in ipairs(state.enemies) do
        if not enemy.isDead then
            local action = enemy.chooseAction(enemy)
            U.sentActionIntoQueue(action)
        end
    end
end

function U.runBattle()
    setPartyAction()
    setEnemyAction()
    state.battleRunning = true
    state.textTimer = 0.5
end

---------------CALCULATOR----------------

function U.calculateAttackDamage(attacker, target)
    local damage = math.floor(attacker.atk/2) - math.floor(target.def/3)
    damage = damage + math.floor(math.random(-damage*.2, damage*.2))
    return math.max(damage, 1)
end

function U.calculateCritDamage(attacker, target)
    local damage = math.floor(attacker.atk/2 * 3) - math.floor(target.def/6)
    damage = damage + math.floor(math.random(-damage*.2, damage*.2))
    return math.max(damage, 1)
end

return U