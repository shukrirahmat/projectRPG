local transitions = {}

local function drawFadeIn(state)
    local opacity = state.transitionTimer / state.transitionSpeed;
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

local function drawFadeOut(state)
    local opacity = 1 - state.transitionTimer / state.transitionSpeed
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

function transitions.draw(state)
    if state.transition == 'fadeIn' then
        drawFadeIn(state)
    elseif state.transition == 'fadeOut' then
        drawFadeOut(state)
    end
end    

return transitions;