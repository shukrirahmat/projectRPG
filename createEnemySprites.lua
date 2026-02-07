local function createEnemySprites(_enemies)

    local enemies = _enemies

    local function getSpritePos(enemy, index)
        local x = windowWidth/2 + (index - 1) * monsterSpriteDimension 
        - (monsterSpriteDimension/2) * #enemies;
        local y = windowHeight/2 + - monsterSpriteDimension/1.5
        return { x = x, y = y }
    end

    local function drawSprite(enemy, index)
        local spritePos = getSpritePos(enemy, index)
        love.graphics.setColor(1, 1, 1)
        local x = spritePos.x
        local y = spritePos.y
        love.graphics.draw(enemy.sprite, x, y)
    end
    
    local function draw()
        for index, enemy in ipairs(enemies) do
            drawSprite(enemy, index)
        end
    end
    
    return {
        draw = draw
    }
end

return createEnemySprites;