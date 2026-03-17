local transition = {}

local state = {
    active = false,
    timer = 0
}

local function drawBattleTransition()

    local progress = state.timer / state.speed

    love.graphics.setColor(0, 0, 0)
    love.graphics.polygon(
        'fill',
        0,
        0,
        0,
        progress  * windowWidth,
        progress * windowWidth,
        0
    )

    love.graphics.polygon(
        'fill',
        windowWidth,
        0,
        windowWidth - progress  * windowWidth,
        0,
        windowWidth,
        progress * windowWidth
    )

    love.graphics.polygon(
        'fill',
        0,
        windowHeight,
        0,
        windowHeight - progress * windowWidth,
        progress * windowWidth,
        windowHeight
    )

    love.graphics.polygon(
        'fill',
        windowWidth,
        windowHeight,
        windowWidth - progress * windowWidth,
        windowHeight,
        windowWidth,
        windowHeight - progress * windowWidth
    )
end

local function drawFadeOut()
    local opacity = state.timer / state.speed
    love.graphics.setColor(0, 0, 0, opacity)
    love.graphics.rectangle(
        'fill',
        0,
        0,
        windowWidth,
        windowHeight
    )
    love.graphics.setColor(1, 1, 1, 1)
end

local function drawFadeIn()
    local opacity = 1 - state.timer / state.speed;
    love.graphics.setColor(0, 0, 0, opacity)
    love.graphics.rectangle(
        'fill',
        0,
        0,
        windowWidth,
        windowHeight
    )
    love.graphics.setColor(1, 1, 1, 1)
end

function transition.load(var)
    state.active = true;
    state.ref = var.ref
    state.timer = 0
    state.speed = var.speed
end

function transition.isActive()
    return state.active
end

function transition.update(dt)
    if not state.active then return end
    
    state.timer = state.timer + dt
    if state.timer >= state.speed then
        state.active = false
    end
end

function transition.draw()
    if not state.active then return end
    
    if state.ref == 'fadeOut' then
        drawFadeOut()
    elseif state.ref == 'fadeIn' then
        drawFadeIn()
    elseif state.ref == 'battle' then
        drawBattleTransition()
    end
end

return transition