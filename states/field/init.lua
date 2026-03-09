local gameState = require('gameState')
local fieldMapper = require('states.field.fieldMapper')
local fieldMovement = require('states.field.fieldMovement')
local transitions = require('systems.transitions')

local field = {}

local state = {
    tileSize = 64
}

function field.load(stateManager, var)
    state.manager = stateManager;
    state.camera = {}
    state.camera.x = windowWidth/2 - (gameState.playerPos.x - 0.5) * state.tileSize
    state.camera.y = windowHeight/2 - (gameState.playerPos.y - 0.5) * state.tileSize
    state.moveSpeed = 0.4
    state.moveTimer = 0
    state.mapShift = { x = 0, y = 0 }
    state.isEntering = nil
    state.isEncountering = nil
    state.currentMove = nil
    state.encounterChance = gameState.currentMap.encounterRate
    
    if var and var.fadesIn then
        state.fadesIn = true;
        state.transition = { cat = 'fadeIn', timer = 0, max = 0.5 }
    end
end

function field.update(dt)
    if state.fadesIn then
        transitions.runFadeIn(state, dt)
    elseif state.isEntering then
        fieldMovement.changeLocation(state, dt)
    elseif state.isEncountering then
        fieldMovement.encounterEnemies(state, dt)
    elseif state.currentMove then
        fieldMovement.movePlayer(state, dt)
    elseif not state.currentMove then
        fieldMovement.handleHoldMovement(state, dt)
    end
end

function field.draw()
    fieldMapper.drawTiles(state)
    fieldMapper.drawSpots(state)
    fieldMapper.drawPlayer(state)

    if state.transition then
        transitions.draw(state)
    end
end

function field.keypressed(key) 
    if state.currentMove == nil
    and (key == 'up' or key == 'down' or key == 'left' or key == 'right')  then
        state.currentMove = key
    end
end

return field