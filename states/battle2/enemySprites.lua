local sprites = require('graphics.sprites')

local enemySprites = {}

local state = {}

local function getSpritePos(enemy, index, shiftX, shiftY)
    local gap = 10
    local initialDraw = windowWidth/2 + (index - 1) * (monsterSpriteDimension + gap)
    local reposition = (monsterSpriteDimension/2) * #state.enemies + (#state.enemies - 1) * (gap/2)
    local x =  initialDraw - reposition + shiftX
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

local function drawEnemyStatus(enemy, index)
    local spritePos = getSpritePos(enemy, index, 0, 0)
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

local function drawAttackAnimation(enemy, index)
    local enemyMovement = { 
        {x=-5, y=0},
        {x=-5, y=-5},
        {x= 0, y=-5},
        {x=5, y=-5},
        {x=5, y=0},
        {x=5, y=5},
        {x= 0, y=5},
    }

    local progress = state.timer / state.animation.speed
    local moveIndex = math.floor(progress * 7)
    local movement = enemyMovement[moveIndex]

    if movement then
        drawEnemySprite(enemy, index, movement.x, movement.y)
    else
        drawEnemySprite(enemy, index, 0, 0)
    end
end

local function drawTextOnEnemy(enemy, index, text, font, color)
    local spritePos = getSpritePos(enemy, index, 0, 0)
    if color and color == 'grey' then
        love.graphics.setColor(0.6,0.6,0.6)
    elseif color and color == 'blue' then
        love.graphics.setColor(0.4,0.2,0.6)
    else
        love.graphics.setColor(1,1,1)
    end
    local progress = state.timer / state.animation.speed
    love.graphics.setFont(font)
    love.graphics.printf(
        text,
        spritePos.x,
        spritePos.y + spritePos.height - 20 - (20 * progress),
        monsterSpriteDimension,
        'center'
    )
end

local function drawDamagedAnimation(enemy, index, color)
    local progress = state.timer / state.animation.speed
    local tick = math.floor(progress * 10)
    if tick == 1 or tick == 3 then
        drawEnemySprite(enemy, index, 0, 0, 0.1)
    else
        drawEnemySprite(enemy, index, 0, 0)
    end

    if tick >= 1 then
        drawTextOnEnemy(enemy, index, state.animation.value, font_boldMono, color)
    end
end

local function drawImmuneAnimation(enemy, index)
    local progress = state.timer / state.animation.speed
    local tick = math.floor(progress * 10)
    if tick == 1 or tick == 2 or tick == 3  then
        drawEnemySprite(enemy, index, 0, 0, 0.75)
    else
        drawEnemySprite(enemy, index, 0, 0)
    end
end

local function drawDodgeAnimation(enemy, index, color)
    local progress = state.timer / state.animation.speed
    local tick = math.floor(progress * 10)
    if tick == 1 or tick == 3 then
        drawEnemySprite(enemy, index, 3, 0)
    elseif tick == 2 then
        drawEnemySprite(enemy, index, 4, 0)
    else
        drawEnemySprite(enemy, index, 0, 0)
    end

    if tick >= 1 then
        drawTextOnEnemy(enemy, index, 'MISS', font_mediumMono, color)
    end
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
    elseif state.animation.ref == 'enemyDodgedResist' then
        drawDodgeAnimation(enemy, index, 'grey')
    end
end

local function drawDeathAnimation(enemy, index)
    if state.animation.ref == 'enemyDied' then
        local tint = math.max(0, 1 - state.timer / state.animation.speed)
        drawEnemySprite(enemy, index, 0, 0, tint)
    end
end

function enemySprites.load(enemies)
    state.enemies = enemies
    state.isAnimating = false
    state.animation = nil
    state.timer = 0
end

function enemySprites.isAnimating()
    return state.isAnimating
end

function enemySprites.animate(animation)
    state.animation = animation
    state.isAnimating = true
end

function enemySprites.update(dt)
    if not state.isAnimating then return end

    state.timer = state.timer + dt
    if state.timer >=  state.animation.speed then
        state.timer = 0
        state.isAnimating = false
        state.animation = nil
    end
end

function enemySprites.draw()
    for index, enemy in ipairs(state.enemies) do
        if not enemy.isDead then
            if state.animation and state.animation.user == enemy then
                drawEnemyAnimation(enemy, index)
            else
                drawEnemySprite(enemy, index, 0, 0)
            end
        elseif enemy.isDead and state.animation and state.animation.user == enemy then
            drawDeathAnimation(enemy, index)
        end
        drawEnemyStatus(enemy, index)
    end
end

return enemySprites