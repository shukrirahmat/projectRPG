local gameState = require('gameState')
local transitionAnimation = {}

local function handleFadeIn(state)
    gameState.currentState.draw()
    
    local opacity = state.timer / state.timerSpeed;
    love.graphics.setColor(0, 0, 0, opacity)
    love.graphics.rectangle(
        'fill',
        0,
        0,
        windowWidth,
        windowHeight
    )
end

local function handleTravelTransition(state)
    
    state.prevState.draw()
    
    local opacity = 1 - state.timer / state.timerSpeed;
    love.graphics.setColor(0, 0, 0, opacity)
    love.graphics.rectangle(
        'fill',
        0,
        0,
        windowWidth,
        windowHeight
    )
end


function transitionAnimation.draw(state)
    if state.transitionType == 'fadeIn' then
        handleFadeIn(state)
    elseif state.transitionType == 'travel' then
        handleTravelTransition(state)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return transitionAnimation