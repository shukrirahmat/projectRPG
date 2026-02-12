local state = require('state')
local utils = require('utils')
local action = require('action')
local actionData = require('actionData')

local input = {}

local function nextCharacter(currentID)
    local nextID = utils.getAbleCharID(currentID, 'next')
    if nextID then
        state.currentMenu = state.characterMenu
        state.characterMenu.charID = nextID
        utils.menuReset(state.characterMenu)
    else
        utils.runBattle()
    end
end

local function addAttackAction(target)
    local user = state.party[state.characterMenu.charID]
    local action = action.new('normalAtk', user, target)
    user.currentAction = action
end

function input.executeLeft()
    if state.currentMenu == state.skillMenu then
        if state.skillMenu.position % 2 == 0
        and state.skillMenu.position - 1 >= 1 then
            utils.menuUp(state.skillMenu)
        end
    end
end

function input.executeRight()
    if state.currentMenu == state.skillMenu then
        if state.skillMenu.position % 2 ~= 0
        and state.skillMenu.position + 1 <= #state.skillMenu.list then
            utils.menuDown(state.skillMenu)
        end
    end
end

function input.executeDown()
    if state.currentMenu == state.skillMenu then
        if state.skillMenu.position + 2 <= #state.skillMenu.list then
            utils.menuDown(state.skillMenu)
            utils.menuDown(state.skillMenu)
        end
    else
        if state.currentMenu.position < #state.currentMenu.list then
            utils.menuDown(state.currentMenu)
        end
    end
end

function input.executeUp()
    if state.currentMenu == state.skillMenu then
        if state.skillMenu.position - 2 >= 1 then
            utils.menuUp(state.skillMenu)
            utils.menuUp(state.skillMenu)
        end
    else
        if state.currentMenu.position > 1 then
            utils.menuUp(state.currentMenu)
        end
    end
end

function input.executeConfirm()
    if state.currentMenu == state.mainMenu then
        nextCharacter(0)
    elseif state.currentMenu == state.characterMenu then
        local char = state.party[state.characterMenu.charID]
        if state.characterMenu.position == 1 then
            utils.updateTargetMenu(state.characterMenu, state.enemies)
            if #state.targetMenu.list == 1 then
                local target = state.enemies[1]
                addAttackAction(target)
                local currentID = state.characterMenu.charID
                nextCharacter(currentID)
            elseif #state.targetMenu.list > 1 then
                state.currentMenu = state.targetMenu
                utils.menuReset(state.targetMenu)
            end
        elseif state.characterMenu.position == 2 and not char.status['SEAL'] then
            utils.updateSkillMenu(char)
            state.currentMenu = state.skillMenu
            utils.menuReset(state.skillMenu)
        elseif state.characterMenu.position == 3 then
            local user = char
            user.currentAction = action.new('defend', user)
            local currentID = state.characterMenu.charID
            nextCharacter(currentID)
        end
    elseif state.currentMenu == state.skillMenu
    and #state.skillMenu.list > 0 then
        local ref = state.skillMenu.list[state.skillMenu.position]
        local data = actionData[ref]
        if state.skillMenu.user.currentMp >= data.cost then
            local group
            if data.aim == 'enemies' then
                group = state.enemies
            elseif data.aim == 'allies' then
                group = state.party
            end
            if data.scope == 'single' then
                utils.updateTargetMenu(state.skillMenu, group)
                if #state.targetMenu.list == 1 then
                    local target = group[1]
                    local user = state.party[state.characterMenu.charID]
                    local ref = state.skillMenu.list[state.skillMenu.position]
                    local action = action.new(ref, user, target)
                    user.currentAction = action
                    local currentID = state.characterMenu.charID
                    nextCharacter(currentID)
                elseif #state.targetMenu.list > 1 then
                    state.currentMenu = state.targetMenu
                    utils.menuReset(state.targetMenu)
                end
            elseif data.scope == 'all' then
                local user = state.party[state.characterMenu.charID]
                local ref = state.skillMenu.list[state.skillMenu.position]
                local action = action.new(ref, user, group)
                user.currentAction = action
                local currentID = state.characterMenu.charID
                nextCharacter(currentID)
            elseif data.scope == 'self' then
                local user = state.party[state.characterMenu.charID]
                local ref = state.skillMenu.list[state.skillMenu.position]
                local action = action.new(ref, user)
                user.currentAction = action
                local currentID = state.characterMenu.charID
                nextCharacter(currentID)
            end
        end
    elseif state.currentMenu == state.targetMenu then
        if state.targetMenu.prevMenu == state.characterMenu then
            local target = state.targetMenu.list[state.targetMenu.position]
            addAttackAction(target)
        elseif state.targetMenu.prevMenu == state.skillMenu then
            local target = state.targetMenu.list[state.targetMenu.position]
            local user = state.party[state.characterMenu.charID]
            local ref = state.skillMenu.list[state.skillMenu.position]
            local action = action.new(ref, user, target)
            user.currentAction = action
        end
        local currentID = state.characterMenu.charID
        nextCharacter(currentID)
    end
end

function input.executeCancel()
    if state.currentMenu == state.characterMenu then
        local currentID = state.characterMenu.charID
        local prevID = utils.getAbleCharID(currentID, 'prev')
        if prevID then
            state.characterMenu.charID = prevID
            utils.menuReset(state.characterMenu)
        else
            state.currentMenu = state.mainMenu
            utils.menuReset(state.mainMenu)
        end
    elseif state.currentMenu == state.targetMenu then
        state.currentMenu  = state.targetMenu.prevMenu
    elseif state.currentMenu == state.skillMenu then
        state.currentMenu = state.characterMenu
        state.characterMenu.position = 2
    end
end

return input