local owState = require('overworldState')
local utils = require('utils')

local overworldInput = {}

function overworldInput.executeMenu()
    if not owState.onMenu then
        utils.menuReset(owState.mainMenu)
        owState.onMenu = true
        owState.currentScreen = 'mainMenu'
    end
end

function overworldInput.executeConfirm()
    if owState.onMenu then
        if owState.currentScreen == 'mainMenu' and owState.mainMenu.position == 2 then
            owState.currentScreen = 'statusScreen'; 
            owState.statusScreen.list = owState.party;
            owState.statusScreen.position = 1
        end
    end
end

function overworldInput.executeCancel()
    if owState.onMenu then
        if owState.currentScreen == 'mainMenu' then
            owState.onMenu = false
        elseif owState.currentScreen == 'statusScreen' then
            owState.currentScreen = 'mainMenu';
        end
    end
end

function overworldInput.executeUp()
    if owState.currentMove == nil and not owState.onMenu then
        owState.currentMove = 'up'
    elseif owState.onMenu then
        if owState.currentScreen == 'mainMenu' and owState.mainMenu.position > 1 then
            utils.menuUp(owState.mainMenu)
        elseif owState.currentScreen == 'statusScreen' 
        and owState.statusScreen.position > 1 then
            owState.statusScreen.position = owState.statusScreen.position - 1
        end
    end
end

function overworldInput.executeDown()
    if owState.currentMove == nil and not owState.onMenu then
        owState.currentMove = 'down'
    elseif owState.onMenu then
        if owState.currentScreen == 'mainMenu' and owState.mainMenu.position < #owState.mainMenu.list then
            utils.menuDown(owState.mainMenu)
        elseif owState.currentScreen == 'statusScreen' 
        and owState.statusScreen.position < #owState.party then
            owState.statusScreen.position = owState.statusScreen.position + 1
        end
    end
end

function overworldInput.executeRight()
    if owState.currentMove == nil and not owState.onMenu then
        owState.currentMove = 'right'
    end
end

function overworldInput.executeLeft()
    if owState.currentMove == nil and not owState.onMenu then
        owState.currentMove = 'left'
    end
end

return overworldInput