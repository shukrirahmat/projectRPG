local gameState = require('gameState')
local sprites = require('graphics.sprites')

local field = {}

field.tileSize = 64;
field.camera = { x = 0, y = 0 }

function field.load()
    field.camera.x = windowWidth/2 - (gameState.playerPos.x - 0.5) * field.tileSize
    field.camera.y = windowHeight/2 - (gameState.playerPos.y - 0.5) * field.tileSize
end

function field.update(dt)
end

function field.draw()
    for y = 1, gameState.currentMap.size.y do
        for x = 1, gameState.currentMap.size.x do
            local floor = gameState.currentMap.floor
            love.graphics.setColor(floor.r, floor.g, floor.b)
            love.graphics.rectangle(
                'fill',
                (x - 1) * field.tileSize + field.camera.x,
                (y - 1) * field.tileSize + field.camera.y,
                field.tileSize,
                field.tileSize
            )
        end
    end

    love.graphics.setColor(1, 1, 1)
    for k, v in pairs(gameState.currentMap.spots) do
        local sprite
        if v.category == 'gates' then
            sprite = sprites['gate']
        end
        love.graphics.draw(
            sprite,
            (v.x - 1) * field.tileSize + field.camera.x,
            (v.y - 1) * field.tileSize + field.camera.y
        )
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        sprites['player'],
        gameState.playerSprite,
        (gameState.playerPos.x - 1) * field.tileSize + field.camera.x,
        (gameState.playerPos.y - 1) * field.tileSize + field.camera.y
    )
end

function field.keypressed(key)
end

return field