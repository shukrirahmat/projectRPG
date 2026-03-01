local owState = require('overworldState')

local mapHandler = {}

function mapHandler.load()
    owState.playerPos = owState.currentMap.startPos;
    owState.currentSprite = player_front[1]
    owState.camera.x = windowWidth/2 - (owState.playerPos.x - 0.5) * owState.tileSize
    owState.camera.y = windowHeight/2 - (owState.playerPos.y - 0.5) * owState.tileSize
end

function mapHandler.draw()
    for y = 1, owState.currentMap.size.y do
        for x = 1, owState.currentMap.size.x do
            local floor = owState.currentMap.floor
            love.graphics.setColor(floor.r, floor.g, floor.b)
            love.graphics.rectangle(
                'fill',
                (x - 1) * owState.tileSize + owState.camera.x - owState.moveShift.x,
                (y - 1) * owState.tileSize + owState.camera.y - owState.moveShift.y,
                owState.tileSize,
                owState.tileSize
            )
        end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        player_sprites,
        owState.currentSprite,
        (owState.playerPos.x - 1) * owState.tileSize + owState.camera.x,
        (owState.playerPos.y - 1) * owState.tileSize + owState.camera.y
    )
end

return mapHandler