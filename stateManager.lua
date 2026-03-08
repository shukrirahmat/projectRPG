local gameState = require('gameState')
local memberCreator = require('entities.memberCreator')
local overworld = require('maps.overworld')
local sprites = require('graphics.sprites')

local stateManager = {}

stateManager.states = 
{
    field = require('states.field')
}

function stateManager.initiate()


    local party = {}
    party[1] = memberCreator.new(1)
    party[2] = memberCreator.new(2)
    party[3] = memberCreator.new(3)
    party[4] = memberCreator.new(4)

    gameState.party = party
    gameState.currentMap = overworld
    gameState.playerPos = overworld.startPos
    gameState.playerSprite = sprites.player_front[1]
    gameState.partyGold = 0
    gameState.partyItems = {}
end

function stateManager.switch(state, var)
    gameState.currentState = stateManager.states[state];
    gameState.currentState.load(stateManager, var)
end

function stateManager.update(dt)
    gameState.currentState.update(dt)
end

function stateManager.draw()
    gameState.currentState.draw()
end

function stateManager.keypressed(key)
    gameState.currentState.keypressed(key)
end


return stateManager