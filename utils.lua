local state = require('state')
local action = require('action')

U = {}

utils = U

-----MENU RELATED HELPERS-----

function U.updateTargetMenu(prevMenu, group)
    local targetList = {}
    for index, target in ipairs(group) do
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

function U.selectTargetRandomly(group)
    local availableTargets = {}

    for index, target in ipairs(group) do
        if not target.dead then
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

local function setPartyAction()
    for index, member in ipairs(state.party) do
        if not member.dead and member.currentAction then
            local action = member.currentAction
            table.insert(state.actionList, action)
            member.currentAction = nil
        end
    end
end

local function setEnemyAction()
    --For now just attack
    for index, enemy in ipairs(state.enemies) do
        if not enemy.dead then
            local target = U.selectTargetRandomly(party)
            local action = action.new('normalatk', enemy, target)
            table.insert(state.actionList, action)
        end
    end
end

function U.runBattle()
    setPartyAction()
    setEnemyAction()
    state.battleRunning = true
    state.textTimer = 0.5
    
    ---TEMPORARY---
    for i, action in ipairs(state.actionList) do
        print(action.user.name)
        print('attacks')
        print(action.target.name)
        print('....')
    end
end

return U