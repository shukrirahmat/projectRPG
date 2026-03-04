local overworld = {}
local owState = require('overworldState')
local owInput = require('overworldInput')
local owMenu = require('overworldMenu')
local statusScreen = require('statusScreen')
local mapHandler = require('mapHandler')
local playerHandler = require('playerHandler')
local mapData = require('mapData')

function overworld.load(party)
    owState.party = party
    owState.currentMap = mapData['worldMap']
    mapHandler.load()
end


function overworld.update(dt)
    if owState.currentMove then
        playerHandler.movePlayer(dt)
    end
end

function overworld.draw()
    mapHandler.draw()
    if owState.onMenu then
        if owState.currentScreen == 'mainMenu' then
            owMenu.drawMainMenu()
        elseif owState.currentScreen == 'statusScreen' then
            statusScreen.draw()
        end
    end
end

function overworld.keypressed(key)
    if key == 'c' then 
        owInput.executeMenu()
    elseif key == 'z' then 
        owInput.executeConfirm()
    elseif key == 'x' then 
        owInput.executeCancel()
    elseif key == 'up' then
        owInput.executeUp()
    elseif key == 'down' then
        owInput.executeDown()
    elseif key == 'right' then
        owInput.executeRight()
    elseif key == 'left' then
        owInput.executeLeft()
    end
end

return overworld