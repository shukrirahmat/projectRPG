local state = require('state')
local hud = require('hud')

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

local function drawDamagedAnimation(enemy, index, color)
    if state.animation.tick % 2 == 0 and state.animation.tick <= 4 then
        drawEnemySprite(enemy, index, 0, 0)
    elseif state.animation.tick > 4 then
        drawEnemySprite(enemy, index, 0, 0)
    else
        drawEnemySprite(enemy, index, 0, 0, 0.1)
    end

    if state.animation.tick > 1 then
        local spritePos = getSpritePos(enemy, index, 0, 0)
        if color and color == 'grey' then
            love.graphics.setColor(0.6,0.6,0.6)
        elseif color and color == 'blue' then
            love.graphics.setColor(0.4,0.2,0.6)
        else
            love.graphics.setColor(1,1,1)
        end
        love.graphics.setFont(font_bold)
        love.graphics.printf(
            ''..state.animation.value..'',
            spritePos.x,
            spritePos.y + spritePos.height - 20 - state.animation.tick * 2,
            monsterSpriteDimension,
            'center'
        )
    end
end

local function drawImmuneAnimation(enemy, index)
    if state.animation.tick == 1 or state.animation.tick == 2 then
        drawEnemySprite(enemy, index, 0, 0, 0.8)
    else
        drawEnemySprite(enemy, index, 0, 0)
    end
end

local function drawDodgeAnimation(enemy, index)
    if state.animation.tick == 1 or state.animation.tick == 2 then
        drawEnemySprite(enemy, index, 5, 0)
    else
        drawEnemySprite(enemy, index, 0, 0)
    end
end


local function drawDeathAnimation(enemy, index)
    local tint = math.max(0, 1 - state.animation.tick/8)
    drawEnemySprite(enemy, index, 0, 0, tint)
end

local function drawEnemyAnimation(enemy, index)
    if state.animation.ref == 'enemyAtk' then
        drawAttackAnimation(enemy, index)
    elseif state.animation.ref == 'enemyDamaged' then
        drawDamagedAnimation(enemy, index)
    elseif state.animation.ref == 'enemyResisted' then
        drawDamagedAnimation(enemy, index, 'grey')
    elseif state.animation.ref == 'enemyManaBurned' then
        drawDamagedAnimation(enemy, index, 'blue')
    elseif state.animation.ref == 'enemyImmune' then
        drawImmuneAnimation(enemy, index)
    elseif state.animation.ref == 'enemyDodged' then
        drawDodgeAnimation(enemy, index)
    end
end

local function drawStatusEffect(enemy, index)
    local spritePos = getSpritePos(enemy, index, 0, 0)
    
    local borderX = spritePos.x + 15
    local borderHeight = 65
    local borderY = spritePos.y + monsterSpriteDimension - borderHeight/2
    local borderWidth = monsterSpriteDimension - 30
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle('fill', borderX, borderY, borderWidth, borderHeight)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(font_tiny)
    local i = 0
    local j = 0
    for k,v in pairs(enemy.status) do
        love.graphics.printf(
            string.sub(k, 1, 3),
            borderX + (i * (borderWidth  /3)),
            borderY + (j * 15),
            borderWidth /3,
            'center'
        )
        i = i + 1
        if i > 3 then
            i = 0
            j = j + 1
        end
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

            if state.infoMode then
                drawStatusEffect(enemy, i)
            end
            
        elseif enemy.isDead 
        and state.animation and state.animation.user == enemy then
            drawDeathAnimation(enemy,i)
        end
    end
end

return E