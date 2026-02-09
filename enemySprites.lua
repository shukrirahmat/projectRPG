local state = require('state')

local E = {}
enemySprites = E

local enemyMovement = { 
    {x=-5, y=0},
    {x=-5, y=-5},
    {x= 0, y=-5},
    {x=5, y=-5},
    {x=5, y=0},
    {x=5, y=5},
    {x= 0, y=5},
}

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

local function drawAttackAnimation(enemy, index)
    for moveIndex, movement in ipairs(enemyMovement) do
        if state.animation.tick == moveIndex then
            drawEnemySprite(enemy, index, movement.x, movement.y)
        elseif state.animation.tick == 0 or state.animation.tick > #enemyMovement then
            drawEnemySprite(enemy, index, 0, 0)
        end
    end
end

local function drawEnemyAnimation(enemy, index)
    if state.animation.ref == 'enemyAtk' then
        drawAttackAnimation(enemy, index)
    end
end

function E.draw()
    for i, enemy in ipairs(state.enemies) do
        if not enemy.isDead then
            if state.animation and state.animation.user == enemy then
                drawEnemyAnimation(enemy, i)
            else
                drawEnemySprite(enemy, i, 0, 0)
            end
        end
    end
end

return E