local gameState = require('gameState')
local fieldMapper = require('states.field.fieldMapper')
local fieldMovement = require('states.field.fieldMovement')

local field = {}

local state = {
    tileSize = 64
}

function field.load()
    state.camera = {}
    state.camera.x = windowWidth/2 - (gameState.playerPos.x - 0.5) * state.tileSize
    state.camera.y = windowHeight/2 - (gameState.playerPos.y - 0.5) * state.tileSize
    state.currentMove = nil
    state.moveSpeed = 0.3
    state.moveTimer = state.moveSpeed
    state.mapShift = { x = 0, y = 0 }
end

function field.update(dt)
    if state.currentMove then
        fieldMovement.movePlayer(dt, state)
    end
end

function field.draw()
    fieldMapper.drawTiles(state)
    fieldMapper.drawSpots(state)
    fieldMapper.drawPlayer(state)
end

function field.keypressed(key)
    if key == 'up' or key == 'down' or key == 'left' or key == 'right' then
        if state.currentMove == nil then
            state.currentMove = key
        end
    end
end

return field