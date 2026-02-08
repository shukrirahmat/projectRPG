local state = require('state')
local helpers = require('helpers')

local input = {}

local function menuReset(menu)
    menu.position = 1
end

local function menuUp(menu)
    if menu.position > 1 then
        menu.position = menu.position - 1
    end
end

local function menuDown(menu)
    if menu.position < #menu.list then
        menu.position = menu.position + 1
    end
end

function input.executeUp()
    menuUp(state.currentMenu)
end

function input.executeDown()
    menuDown(state.currentMenu)
end

function input.executeConfirm()
    if state.currentMenu == state.mainMenu then
        local nextID = helpers.getAbleCharID(0, 'next')
        state.currentMenu = state.characterMenu
        state.characterMenu.charID = nextID
        menuReset(state.characterMenu)
    elseif state.currentMenu == state.characterMenu then
        local currentID = state.characterMenu.charID
        local nextID = helpers.getAbleCharID(currentID, 'next')
        if nextID then
            state.characterMenu.charID = nextID
            menuReset(state.characterMenu)
        else
            state.battleRunning = true
        end
    end
end

function input.executeCancel()
    if state.currentMenu == state.characterMenu then
        local currentID = state.characterMenu.charID
        local prevID = helpers.getAbleCharID(currentID, 'prev')
        if prevID then
            state.characterMenu.charID = prevID
            menuReset(state.characterMenu)
        else
            state.currentMenu = state.mainMenu
            menuReset(state.mainMenu)
        end
    end
end

return input