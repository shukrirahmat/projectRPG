local sprites = require('graphics.sprites')

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
    local gap = 10
    local initialDraw = windowWidth/2 + (index - 1) * (monsterSpriteDimension + gap)
    local reposition = (monsterSpriteDimension/2) * #state.enemies + (#state.enemies - 1) * (gap/2)
    local x =  initialDraw - reposition + shiftX
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
    local moveIndex = math.floor(progress * 10)

    local movement = enemyMovement[moveIndex]

    if movement then
        drawEnemySprite(state, enemy, index, movement.x, movement.y)
    else
        drawEnemySprite(state, enemy, index, 0, 0)
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
    if tick == 1 or tick == 3 then
        drawEnemySprite(state, enemy, index, 0, 0, 0.1)
    else
        drawEnemySprite(state, enemy, index, 0, 0)
    end

    if tick >= 1 then
        drawTextOnEnemy(state, enemy, index, state.animation.value, font_bold, color)
    end
end

local function drawImmuneAnimation(state, enemy, index)
    local progress = state.animation.timer / state.animation.speed
    local tick = math.floor(progress * 10)
    if tick == 1 or tick == 2 or tick == 3  then
        drawEnemySprite(state, enemy, index, 0, 0, 0.75)
    else
        drawEnemySprite(state, enemy, index, 0, 0)
    end
end

local function drawDodgeAnimation(state, enemy, index, color)
    local progress = state.animation.timer / state.animation.speed
    local tick = math.floor(progress * 10)
    if tick == 1 or tick == 3 then
        drawEnemySprite(state, enemy, index, 3, 0)
    elseif tick == 2 then
        drawEnemySprite(state, enemy, index, 4, 0)
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
    elseif state.animation.ref == 'enemyDamaged' then
        drawDamagedAnimation(state, enemy, index)
    elseif state.animation.ref == 'enemyResisted' then
        drawDamagedAnimation(state, enemy, index, 'grey')
    elseif state.animation.ref == 'enemyManaBurned' then
        drawDamagedAnimation(state, enemy, index, 'blue')
    elseif state.animation.ref == 'enemyImmune' then
        drawImmuneAnimation(state, enemy, index)
    elseif state.animation.ref == 'enemyDodged' then
        drawDodgeAnimation(state, enemy, index)
    elseif state.animation.ref == 'enemyDodgedResist' then
        drawDodgeAnimation(state, enemy, index, 'grey')
    end
end

local function drawEnemyStatus(state, enemy, index)
    local spritePos = getSpritePos(state, enemy, index, 0, 0)
    local i = 1
    local shift = 0
    for k, v in pairs(enemy.status) do
        if i > 8 then
            i = 1;
            shift = statusIconDimension;
        end
        local xpos = spritePos.x + (i - 1) * statusIconDimension
        local ypos = monsterSpriteDimension + spritePos.y + shift
        love.graphics.draw(
            sprites['status_Icons'],
            sprites[k],
            xpos,
            ypos
        )
        i = i + 1;
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

        drawEnemyStatus(state, enemy, index)
    end
end

return battleSprites