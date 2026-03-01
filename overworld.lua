local overworld = {}
local owState = require('overworldState')
local mapHandler = require('mapHandler')
local playerHandler = require('playerHandler')
local mapData = require('mapData')

function overworld.load()

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
    if owState.currentMove == nil 
    and (key == "up" or key == "down" or key == "left" or key == "right") then
        owState.currentMove = key
    end
end

return overworld