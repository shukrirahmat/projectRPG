local battleMenu = require('states.battle.battleMenu')
local battleHandler = require('states.battle.battleHandler')
local actionCreator = require('entities.actionCreator')
local actionData = require('data.actionData')
local itemManager = require('systems.itemManager')

local battleInput = {}

local function nextCharacter(state, currentID)
    local nextID = battleHandler.getAbleCharID(state, currentID, 'next')
    if nextID then
        state.currentMenu = state.characterMenu
        state.characterMenu.charID = nextID
        battleMenu.menuReset(state.characterMenu)
    else
        battleHandler.runBattle(state)
    end
end

local function characterMenuProceed(state)
    local charID = state.characterMenu.charID
    local char = state.party[charID]
    if state.characterMenu.position == 1 then
        battleMenu.updateTargetMenu(state, state.characterMenu, state.enemies)
        if #state.targetMenu.list == 1 then
            local target = state.enemies[1]
            char.currentAction = actionCreator.new('normalAtk', char, {target})
            nextCharacter(state, charID)
        elseif #state.targetMenu.list > 1 then
            state.currentMenu = state.targetMenu
            battleMenu.menuReset(state.targetMenu)
        end
    elseif state.characterMenu.position == 2 and not char.status['SEAL'] then
        battleMenu.updateSkillMenu(state, char)
        state.currentMenu = state.skillMenu
        battleMenu.menuReset(state.skillMenu)
    elseif state.characterMenu.position == 3 then
        char.currentAction = actionCreator.new('defend', char)
        nextCharacter(state, charID)
    elseif state.characterMenu.position == 4 then
        battleMenu.updateItemMenu(state, char)
        state.currentMenu = state.itemMenu
        battleMenu.menuReset(state.itemMenu)
    end
end

local function skillMenuProceed(state)
    local user = state.skillMenu.user
    local userID = state.characterMenu.charID
    local ref = state.skillMenu.list[state.skillMenu.position]
    local data = actionData[ref]
    if user.currentMp >= data.cost then
        local group
        if data.aim == 'enemies' then
            group = state.enemies
        elseif data.aim == 'allies' then
            group = state.party
        end
        if data.scope == 'single' then
            battleMenu.updateTargetMenu(state, state.skillMenu, group)
            if #state.targetMenu.list == 1 then
                local target = group[1]
                user.currentAction = actionCreator.new(ref, user, {target})
                nextCharacter(state, userID)
            elseif #state.targetMenu.list > 1 then
                state.currentMenu = state.targetMenu
                battleMenu.menuReset(state.targetMenu)
            end
        elseif data.scope == 'dead' then
            battleMenu.updateDeadTargetMenu(state, state.skillMenu, group)
            state.currentMenu = state.targetMenu
            battleMenu.menuReset(state.targetMenu)
        elseif data.scope == 'all' then
            user.currentAction = actionCreator.new(ref, user, {unpack(group)})
            nextCharacter(state, userID)
        elseif data.scope == 'self' then
            user.currentAction = actionCreator.new(ref, user, {user})
            nextCharacter(state, userID)
        end
    end
end

local function itemMenuProceed(state)
    local item = state.itemMenu.list[state.itemMenu.position].item
    local ref = item.ref
    local data = actionData[ref]
    local user = state.party[state.characterMenu.charID]
    local userID = state.characterMenu.charID
    local group
    if data.aim == 'enemies' then
        group = state.enemies
    elseif data.aim == 'allies' then
        group = state.party
    end
    if data.scope == 'single' then
        battleMenu.updateTargetMenu(state, state.itemMenu, group)
        if #state.targetMenu.list == 1 then
            local target = group[1]
            user.currentAction = actionCreator.new(ref, user, {target})
            user.usingItem = item
            itemManager.manageItems(item, -1)
            nextCharacter(state, userID)
        elseif #state.targetMenu.list > 1 then
            state.currentMenu = state.targetMenu
            battleMenu.menuReset(state.targetMenu)
        end
    elseif data.scope == 'dead' then
        battleMenu.updateDeadTargetMenu(state, state.itemMenu, group)
        state.currentMenu = state.targetMenu
        battleMenu.menuReset(state.targetMenu)
    elseif data.scope == 'all' then
        user.currentAction = actionCreator.new(ref, user, {unpack(group)})
        user.usingItem = item
        itemManager.manageItems(item, -1)
        nextCharacter(state, userID)
    elseif data.scope == 'self' then
        user.currentAction = actionCreator.new(ref, user, {user})
        user.usingItem = item
        itemManager.manageItems(item, -1)
        nextCharacter(userID)
    end
end

local function targetMenuProceed(state)
    local target = state.targetMenu.list[state.targetMenu.position]
    local user = state.party[state.characterMenu.charID]
    if state.targetMenu.prevMenu == state.characterMenu then
        user.currentAction = actionCreator.new('normalAtk', user, {target})
    elseif state.targetMenu.prevMenu == state.skillMenu then
        local ref = state.skillMenu.list[state.skillMenu.position]
        user.currentAction = actionCreator.new(ref, user, {target})
    elseif state.targetMenu.prevMenu == state.itemMenu then
        local item = state.itemMenu.list[state.itemMenu.position].item
        local ref = item.ref
        user.currentAction = actionCreator.new(ref, user, {target})
        user.usingItem = item
        itemManager.manageItems(item, -1)
    end
    local userID = state.characterMenu.charID
    nextCharacter(state, userID)
end


function battleInput.executeUp(state)
    if state.currentMenu == state.skillMenu or state.currentMenu == state.itemMenu then
        if state.currentMenu.position - 2 >= 1 then
            battleMenu.menuUp(state.currentMenu)
            battleMenu.menuUp(state.currentMenu)
        end
    else
        if state.currentMenu.position > 1 then
            battleMenu.menuUp(state.currentMenu)
        end
    end
end

function battleInput.executeDown(state)
    if state.currentMenu == state.skillMenu or state.currentMenu == state.itemMenu then
        if state.currentMenu.position + 2 <= #state.currentMenu.list then
            battleMenu.menuDown(state.currentMenu)
            battleMenu.menuDown(state.currentMenu)
        elseif state.currentMenu.position + 1 == #state.currentMenu.list then
            battleMenu.menuDown(state.currentMenu)
        end
    else
        if state.currentMenu.position < #state.currentMenu.list then
            battleMenu.menuDown(state.currentMenu)
        end
    end
end

function battleInput.executeLeft(state)
    if state.currentMenu == state.skillMenu or state.currentMenu == state.itemMenu then
        if state.currentMenu.position % 2 == 0
        and state.currentMenu.position - 1 >= 1 then
            battleMenu.menuUp(state.currentMenu)
        end
    end
end

function battleInput.executeRight(state)
    if state.currentMenu == state.skillMenu or state.currentMenu == state.itemMenu then
        if state.currentMenu.position % 2 ~= 0
        and state.currentMenu.position + 1 <= #state.currentMenu.list then
            battleMenu.menuDown(state.currentMenu)
        end
    end
end

function battleInput.executeConfirm(state)
    if state.currentMenu == state.mainMenu then
        nextCharacter(state, 0)
    elseif state.currentMenu == state.characterMenu then
        characterMenuProceed(state)
    elseif state.currentMenu == state.skillMenu and #state.skillMenu.list > 0 then
        skillMenuProceed(state)
    elseif state.currentMenu == state.itemMenu and #state.itemMenu.list > 0 then
        itemMenuProceed(state)
    elseif state.currentMenu == state.targetMenu and #state.targetMenu.list > 0 then
        targetMenuProceed(state)
    end
end

function battleInput.executeCancel(state)
    if state.currentMenu == state.characterMenu then
        local userID = state.characterMenu.charID
        local prevID = battleHandler.getAbleCharID(state, userID, 'prev')
        if prevID then
            state.characterMenu.charID = prevID
            battleMenu.menuReset(state.characterMenu)
            local user = state.party[state.characterMenu.charID]
            if user.usingItem then
                itemManager.manageItems(user.usingItem, 1)
                user.usingItem = nil
            end
        else
            state.currentMenu = state.mainMenu
            battleMenu.menuReset(state.mainMenu)
        end
    elseif state.currentMenu == state.targetMenu then
        state.currentMenu  = state.targetMenu.prevMenu
    elseif state.currentMenu == state.skillMenu then
        state.currentMenu = state.characterMenu
        state.characterMenu.position = 2
    elseif state.currentMenu == state.itemMenu then
        state.currentMenu = state.characterMenu
        state.characterMenu.position = 4
    end
end

return battleInput