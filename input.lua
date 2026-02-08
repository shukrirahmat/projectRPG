local state = require('state')
local utils = require('utils')
local action = require('action')

local input = {}

function input.executeUp()
    utils.menuUp(state.currentMenu)
end

function input.executeDown()
    utils.menuDown(state.currentMenu)
end

function input.executeConfirm()
    if state.currentMenu == state.mainMenu then
        local nextID = utils.getAbleCharID(0, 'next')
        state.currentMenu = state.characterMenu
        state.characterMenu.charID = nextID
        utils.menuReset(state.characterMenu)
    elseif state.currentMenu == state.characterMenu then
        if state.characterMenu.position == 1 then
            utils.updateTargetMenu(state.characterMenu, state.enemies)
            state.currentMenu = state.targetMenu
            utils.menuReset(state.targetMenu)
        end
    elseif state.currentMenu == state.targetMenu then
        if state.targetMenu.prevMenu == state.characterMenu then
            local target = state.targetMenu.list[state.targetMenu.position]
            local user = state.party[state.characterMenu.charID]
            local action = action.new('normalatk', user, target)
            user.currentAction = action
        end
        
        local currentID = state.characterMenu.charID
        local nextID = utils.getAbleCharID(currentID, 'next')
        if nextID then
            state.currentMenu = state.characterMenu
            state.characterMenu.charID = nextID
            utils.menuReset(state.characterMenu)
        else
            utils.runBattle()
        end
            
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
    end
end

return input