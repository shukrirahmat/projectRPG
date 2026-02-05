local function createEnemySprites(_enemies)
    
    local enemies = _enemies
    
    local function getSpritePos(enemy,index, shiftX, shiftY)
        local x = windowWidth/2 + (index - 1) * monsterSpriteDimension + shiftX 
        - (monsterSpriteDimension/2) * #enemies;
        local y = windowHeight/2 + shiftY  - monsterSpriteDimension/1.5
        local height = enemy.getStat('spriteHeight')
        local sprite = {x = x, y = y, height = height}
        return sprite
    end

    local function drawEnemySprite(enemy, index, shiftX, shiftY, tint)
        local spritePos = getSpritePos(enemy, index, shiftX, shiftY)
        if not tint then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(tint, tint, tint)
        end
        local x = spritePos.x
        local y = spritePos.y
        love.graphics.draw(enemy.getStat('sprite'), x, y)
        love.graphics.setColor(1, 1, 1)
    end
    
    local function draw()
        for i, enemy in ipairs(enemies) do
            drawEnemySprite(enemy, i, 0, 0)
        end
    end
        
    return {
        draw = draw
    }

end

return createEnemySprites