local battleSprites = {}

local enemyMovement = { 
    {x=-5, y=0},
    {x=-5, y=-5},
    {x= 0, y=-5},
    {x=5, y=-5},
    {x=5, y=0},
    {x=5, y=5},
    {x= 0, y=5},
}

local function getSpritePos(state, enemy, index, shiftX, shiftY)
    local x = windowWidth/2 + (index - 1) * monsterSpriteDimension + shiftX 
    - (monsterSpriteDimension/2) * #state.enemies;
    local y = windowHeight/2 + shiftY  - monsterSpriteDimension/1.5
    local height = enemy.spriteHeight
    return {x = x, y = y, height = height}
end

local function drawEnemySprite(state, enemy, index, shiftX, shiftY, tint)
    local spritePos = getSpritePos(state, enemy, index, shiftX, shiftY)
    if not tint then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(tint, tint, tint)
    end
    local x = spritePos.x
    local y = spritePos.y
    love.graphics.draw(enemy.sprite, x, y)
end

local function drawAttackAnimation(state, enemy, index)
    local progress = state.animation.timer / state.animation.speed
    for moveIndex, movement in ipairs(enemyMovement) do
        if math.floor(progress * 10) == moveIndex then
            drawEnemySprite(state, enemy, index, movement.x, movement.y)
        else
            drawEnemySprite(state, enemy, index, 0, 0)
        end
    end
end

local function drawTextOnEnemy(state, enemy, index, text, font, color)
    local spritePos = getSpritePos(state, enemy, index, 0, 0)
    if color and color == 'grey' then
        love.graphics.setColor(0.6,0.6,0.6)
    elseif color and color == 'blue' then
        love.graphics.setColor(0.4,0.2,0.6)
    else
        love.graphics.setColor(1,1,1)
    end
    local progress = state.animation.timer / state.animation.speed
    love.graphics.setFont(font)
    love.graphics.printf(
        text,
        spritePos.x,
        spritePos.y + spritePos.height - 20 - (20 * progress),
        monsterSpriteDimension,
        'center'
    )
end

local function drawDamagedAnimation(state, enemy, index, color)
    local progress = state.animation.timer / state.animation.speed
    local tick = math.floor(progress * 10)
    if tick % 2 == 0 and tick <= 4 then
        drawEnemySprite(state, enemy, index, 0, 0)
    elseif tick > 4 then
        drawEnemySprite(state, enemy, index, 0, 0)
    else
        drawEnemySprite(state, enemy, index, 0, 0, 0.1)
    end

    if tick >= 1 then
        drawTextOnEnemy(state, enemy, index, state.animation.value, font_bold, color)
    end
end

local function drawImmuneAnimation(state, enemy, index)
    local progress = state.animation.timer / state.animation.speed
    local tick = math.floor(progress * 10)
    if tick == 1 or tick == 2 then
        drawEnemySprite(state, enemy, index, 0, 0, 0.75)
    else
        drawEnemySprite(state, enemy, index, 0, 0)
    end
end

local function drawDodgeAnimation(state, enemy, index, color)
    local progress = state.animation.timer / state.animation.speed
    local tick = math.floor(progress * 10)
    if tick == 1 or tick == 2 then
        drawEnemySprite(state, enemy, index, 5, 0)
    else
        drawEnemySprite(state, enemy, index, 0, 0)
    end

    if tick >= 1 then
        drawTextOnEnemy(state, enemy, index, 'MISS', font_small, color)
    end
end


local function drawDeathAnimation(state, enemy, index)
    if state.animation.ref == 'enemyDied' then
        local tint = math.max(0, 1 - state.animation.timer / state.animation.speed)
        drawEnemySprite(state, enemy, index, 0, 0, tint)
    end
end

local function drawEnemyAnimation(state, enemy, index)
    if state.animation.ref == 'enemyAtk' then
        drawAttackAnimation(state, enemy, index)
    elseif battleState.animation.ref == 'enemyDamaged' then
        drawDamagedAnimation(state, enemy, index)
    elseif battleState.animation.ref == 'enemyResisted' then
        drawDamagedAnimation(state, enemy, index, 'grey')
    elseif battleState.animation.ref == 'enemyManaBurned' then
        drawDamagedAnimation(state, enemy, index, 'blue')
    elseif battleState.animation.ref == 'enemyImmune' then
        drawImmuneAnimation(state, enemy, index)
    elseif battleState.animation.ref == 'enemyDodged' then
        drawDodgeAnimation(state, enemy, index)
    elseif battleState.animation.ref == 'enemyDodgedResist' then
        drawDodgeAnimation(state, enemy, index, 'grey')
    end
end

function battleSprites.draw(state)
    for index, enemy in ipairs(state.enemies) do
        if not enemy.isDead then
            if state.animation and state.animation.user == enemy then
                drawEnemyAnimation(state, enemy, index)
            else
                drawEnemySprite(state, enemy, index, 0, 0)
            end
        elseif enemy.isDead 
        and state.animation and state.animation.user == enemy then
            drawDeathAnimation(state, enemy, index)
        end
    end
end

return battleSprites