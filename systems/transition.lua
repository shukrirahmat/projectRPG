local transition = {}

local state = {
    active = false,
    timer = 0
}

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

local function drawFadeIn(state)
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

function transition.start(var)
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
    end
end

return transition