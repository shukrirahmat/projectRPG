local gameState = require('gameState')
local sprites = require('graphics.sprites')

local fieldMapper = {}

function fieldMapper.drawTiles(state)
    for y = 1, gameState.currentMap.size.y do
        for x = 1, gameState.currentMap.size.x do
            local floor = gameState.currentMap.floor
            love.graphics.setColor(floor.r, floor.g, floor.b)
            love.graphics.rectangle(
                'fill',
                (x - 1) * state.tileSize + state.camera.x - state.mapShift.x,
                (y - 1) * state.tileSize + state.camera.y - state.mapShift.y,
                state.tileSize,
                state.tileSize
            )
        end
    end
end

function fieldMapper.drawSpots(state)
    love.graphics.setColor(1, 1, 1)
    for k, v in pairs(gameState.currentMap.spots) do
        local sprite
        if v.category == 'gates' then
            sprite = sprites['gate']
        end
        love.graphics.draw(
            sprite,
            (v.x - 1) * state.tileSize + state.camera.x - state.mapShift.x,
            (v.y - 1) * state.tileSize + state.camera.y - state.mapShift.y
        )
    end
end

function fieldMapper.drawPlayer(state)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        sprites['player'],
        gameState.playerSprite,
        (gameState.playerPos.x - 1) * state.tileSize + state.camera.x,
        (gameState.playerPos.y - 1) * state.tileSize + state.camera.y
    )
end

return fieldMapper