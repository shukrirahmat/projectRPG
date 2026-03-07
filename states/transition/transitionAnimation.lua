local transitionAnimation = {}

local function handleTravelTransition(state)
    local opacity = state.timer / state.timerMax;
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
    if state.transitionType == 'travel' then
        handleTravelTransition(state)
    end
end

return transitionAnimation