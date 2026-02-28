local overworld = {}
local owState = require('overworldState')

function overworld.load()

    grasstile = { r = 0.6, g = 0.9, b = 0.6 }
    fieldSize = { x = 12, y = 8 }
    playerPos = { x = 5, y = 5}
    camera = {}
    camera.x = windowWidth/2 - (playerPos.x - 0.5) * owState.tileSize
    camera.y = windowHeight/2 - (playerPos.y - 0.5) * owState.tileSize

    currentMove = nil
    moveSpeed = 0.5
    moveTimer = moveSpeed
    moveShift = { x = 0, y = 0}

    function movePlayer(key, dt)
        moveTimer = moveTimer - dt 
        if key == 'up' then
            owState.currentSprite = player_back[1]
            if playerPos.y > 1 then
                if moveTimer > 0 then
                    moveShift.y = -1 * (1 - (moveTimer/moveSpeed) ) * owState.tileSize
                    if math.abs(moveShift.y) / owState.tileSize <= 0.25 then
                        owState.currentSprite = player_back[2]
                    elseif math.abs(moveShift.y) / owState.tileSize <= 0.5 then
                        owState.currentSprite = player_back[1]
                    elseif math.abs(moveShift.y) / owState.tileSize <= 0.75 then
                        owState.currentSprite = player_back[3]
                    end
                elseif moveTimer <= 0 then
                    moveShift.y = 0 
                    owState.currentSprite = player_back[1]
                    playerPos.y = playerPos.y - 1
                    camera.y = camera.y + owState.tileSize
                    currentMove = nil
                    moveTimer = moveSpeed
                end
            else
                currentMove = nil
                moveTimer = moveSpeed
            end
        elseif key == 'down' then
            owState.currentSprite = player_front[1]
            if playerPos.y < fieldSize.y then
                if moveTimer > 0 then
                    moveShift.y = (1 - (moveTimer/moveSpeed) ) * owState.tileSize
                    if math.abs(moveShift.y) / owState.tileSize <= 0.25 then
                        owState.currentSprite = player_front[2]
                    elseif math.abs(moveShift.y) / owState.tileSize <= 0.5 then
                        owState.currentSprite = player_front[1]
                    elseif math.abs(moveShift.y) / owState.tileSize <= 0.75 then
                        owState.currentSprite = player_front[3]
                    end
                elseif moveTimer <= 0 then
                    moveShift.y = 0                
                    playerPos.y = playerPos.y + 1
                    camera.y = camera.y - owState.tileSize
                    currentMove = nil
                    moveTimer = moveSpeed
                end
            else
                currentMove = nil
                moveTimer = moveSpeed
            end
        elseif key == 'left' then
            owState.currentSprite = player_left[1]
            if playerPos.x > 1 then
                if moveTimer > 0 then
                    moveShift.x = -1 * (1 - (moveTimer/moveSpeed) ) * owState.tileSize
                    if math.abs(moveShift.x) / owState.tileSize <= 0.25 then
                        owState.currentSprite = player_left[2]
                    elseif math.abs(moveShift.x) / owState.tileSize <= 0.5 then
                        owState.currentSprite = player_left[1]
                    elseif math.abs(moveShift.x) / owState.tileSize <= 0.75 then
                        owState.currentSprite = player_left[3]
                    end
                elseif moveTimer <= 0 then
                    moveShift.x = 0                
                    playerPos.x = playerPos.x - 1
                    camera.x = camera.x + owState.tileSize
                    currentMove = nil
                    moveTimer = moveSpeed
                end
            else
                currentMove = nil
                moveTimer = moveSpeed
            end
        elseif key == 'right' then
            owState.currentSprite = player_right[1]
            if playerPos.x < fieldSize.x then
                if moveTimer > 0 then
                    moveShift.x = (1 - (moveTimer/moveSpeed) ) * owState.tileSize
                    if math.abs(moveShift.x) / owState.tileSize <= 0.25 then
                        owState.currentSprite = player_right[2]
                    elseif math.abs(moveShift.x) / owState.tileSize <= 0.5 then
                        owState.currentSprite = player_right[1]
                    elseif math.abs(moveShift.x) / owState.tileSize <= 0.75 then
                        owState.currentSprite = player_right[3]
                    end
                elseif moveTimer <= 0 then
                    moveShift.x = 0                
                    playerPos.x = playerPos.x + 1
                    camera.x = camera.x - owState.tileSize
                    currentMove = nil
                    moveTimer = moveSpeed
                end
            else
                currentMove = nil
                moveTimer = moveSpeed
            end
        end
    end
end
    

function overworld.update(dt)
    
    if currentMove then
        movePlayer(currentMove, dt)
    end
end

function overworld.draw()
    for y = 1, fieldSize.y do
        for x = 1, fieldSize.x do
            love.graphics.setColor(grasstile.r, grasstile.g, grasstile.b)
            love.graphics.rectangle(
                'fill',
                (x - 1) * owState.tileSize + camera.x - moveShift.x,
                (y - 1) * owState.tileSize + camera.y - moveShift.y,
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