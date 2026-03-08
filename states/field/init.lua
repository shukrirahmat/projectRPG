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
    state.moveSpeed = 0.25
    state.moveTimer = state.moveSpeed
    state.mapShift = { x = 0, y = 0 }
    state.transitionSpeed = 1
    state.transitionTimer = state.transitionSpeed
    state.transition = 'fadeIn'
    state.isEntering = nil
    state.isEncountering = nil
    state.currentMove = nil
    state.encounterChance = gameState.currentMap.encounterRate
end

function field.update(dt)
    if state.transition == 'fadeIn' then
        fieldMovement.doFadeIn(dt, state)
    elseif state.isEntering then
        fieldMovement.changeLocation(dt, state)
    elseif state.isEncountering then
        fieldMovement.encounterEnemies(dt, state)
    elseif state.currentMove then
        fieldMovement.movePlayer(dt, state)
    elseif not state.currentMove then
        fieldMovement.handleHoldMovement(dt, state)
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
    if key == 'up' or key == 'down' or key == 'left' or key == 'right' then
        if state.currentMove == nil then
            state.currentMove = key
        end
    end
end

return field