local overworld = {}
local owState = require('overworldState')
local owInput = require('overworldInput')
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
end

function overworld.keypressed(key)
    if key == 'c' then 
        owInput.executeMenu()
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