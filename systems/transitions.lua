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

local function drawBattleTransition(state)
    
    local progress = state.transitionTimer / state.transitionSpeed
    
    love.graphics.setColor(0, 0, 0)
    love.graphics.polygon(
        'fill',
        0,
        0,
        0,
        ( 1 - progress ) * windowWidth,
        ( 1 - progress ) * windowWidth,
        0
    )
    
    love.graphics.polygon(
        'fill',
        windowWidth,
        0,
        windowWidth - ( 1 - progress ) * windowWidth,
        0,
        windowWidth,
        ( 1 - progress ) * windowWidth
    )
    
    love.graphics.polygon(
        'fill',
        0,
        windowHeight,
        0,
        windowHeight - ( 1 - progress ) * windowWidth,
        ( 1 - progress ) * windowWidth,
        windowHeight
    )
    
    love.graphics.polygon(
        'fill',
        windowWidth,
        windowHeight,
        windowWidth - ( 1 - progress ) * windowWidth,
        windowHeight,
        windowWidth,
        windowHeight - ( 1 - progress ) * windowWidth
    )
end

function transitions.draw(state)
    if state.transition == 'fadeIn' then
        drawFadeIn(state)
    elseif state.transition == 'fadeOut' then
        drawFadeOut(state)
    elseif state.transition == 'enemyEncounter' then
        drawBattleTransition(state)
    end
end    

return transitions;