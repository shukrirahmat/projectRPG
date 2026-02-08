local state = require('state')

local E = {}
enemySprites = E

local function getSpritePos(enemy,index, shiftX, shiftY)
    local x = windowWidth/2 + (index - 1) * monsterSpriteDimension + shiftX 
    - (monsterSpriteDimension/2) * #state.enemies;
    local y = windowHeight/2 + shiftY  - monsterSpriteDimension/1.5
    local height = enemy.spriteHeight
    return {x = x, y = y, height = height}
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
    love.graphics.draw(enemy.sprite, x, y)
end

function E.draw()
    for i, enemy in ipairs(state.enemies) do
        if not enemy.isDead then
            drawEnemySprite(enemy, i, 0, 0)
        end
    end
end

return E