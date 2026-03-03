local owState = require('overworldState')
local utils = require('utils')

local overworldInput = {}

function overworldInput.executeMenu()
    if not owState.mainMenuOpen then
        utils.menuReset(owState.mainMenu)
        owState.mainMenuOpen = true
    end
end

function overworldInput.executeCancel()
    if owState.mainMenuOpen then
        owState.mainMenuOpen = false
    end
end

function overworldInput.executeUp()
    if owState.currentMove == nil and not owState.mainMenuOpen then
        owState.currentMove = 'up'
    elseif owState.mainMenuOpen then
        if owState.mainMenu.position > 1 then
            utils.menuUp(owState.mainMenu)
        end
    end
end

function overworldInput.executeDown()
    if owState.currentMove == nil and not owState.mainMenuOpen then
        owState.currentMove = 'down'
    elseif owState.mainMenuOpen then
        if owState.mainMenu.position < #owState.mainMenu.list then
            utils.menuDown(owState.mainMenu)
        end
    end
end

function overworldInput.executeRight()
    if owState.currentMove == nil and not owState.mainMenuOpen then
        owState.currentMove = 'right'
    end
end

function overworldInput.executeLeft()
    if owState.currentMove == nil and not owState.mainMenuOpen then
        owState.currentMove = 'left'
    end
end

return overworldInput