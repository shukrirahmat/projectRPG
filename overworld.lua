local overworld = {}
local owState = require('overworldState')

function overworld.load()

    grasstile = { r = 0.6, g = 0.9, b = 0.6 }
    fieldSize = { x = 12, y = 8 }
    playerPos = { x = 1, y = 1 }

    camera = {}
    camera.x = windowWidth/2 - (playerPos.x - 0.5) * owState.tileSize
    camera.y = windowHeight/2 - (playerPos.y - 0.5) * owState.tileSize

    currentMove = nil
    moveSpeed = 0.2
    moveTimer = moveSpeed

    function movePlayer(key)
        if key == 'up' then
            if playerPos.y > 1 then
                playerPos.y = playerPos.y - 1
                camera.y = camera.y + owState.tileSize
            end
            owState.currentSprite = player_back[1]
        elseif key == 'down' then
            if playerPos.y < fieldSize.y then
                playerPos.y = playerPos.y + 1
                camera.y = camera.y - owState.tileSize
            end
            owState.currentSprite = player_front[1]
        elseif key == 'right' then
            if playerPos.x < fieldSize.x then
                playerPos.x = playerPos.x + 1
                camera.x = camera.x - owState.tileSize
            end
            owState.currentSprite = player_right[1]
        elseif key == 'left' then
            if playerPos.x > 1 then
                playerPos.x = playerPos.x - 1
                camera.x = camera.x + owState.tileSize
            end
            owState.currentSprite = player_left[1]
        end
    end
end
    

function overworld.update(dt)
    
    if currentMove then
        moveTimer = moveTimer - dt
        if moveTimer <= 0 then
            movePlayer(currentMove)
            currentMove = nil
            moveTimer = moveSpeed
        end
    end
end

function overworld.draw()
    for y = 1, fieldSize.y do
        for x = 1, fieldSize.x do
            love.graphics.setColor(grasstile.r, grasstile.g, grasstile.b)
            love.graphics.rectangle(
                'fill',
                (x - 1) * owState.tileSize + camera.x,
                (y - 1) * owState.tileSize + camera.y,
                owState.tileSize,
                owState.tileSize
            )
        end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        player_sprites,
        owState.currentSprite,
        (playerPos.x - 1) * owState.tileSize + camera.x,
        (playerPos.y - 1) * owState.tileSize + camera.y
    )
end

function overworld.keypressed(key)   
    if currentMove == nil and (key == "up" or key == "down" or key == "left" or key == "right") then
        currentMove = key
    end
end

return overworld