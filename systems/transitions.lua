local transitions = {}

local function drawFadeIn(state)
    local opacity = 1 - state.transition.timer / state.transition.max;
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
    local opacity = state.transition.timer / state.transition.max
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

    local progress = state.transition.timer / state.transition.max

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

function transitions.runFadeIn(state, dt)
    state.transition.timer = state.transition.timer + dt
    if state.transition.timer >= state.transition.max then
        state.transition = nil
        state.fadesIn = nil
    end
end

function transitions.draw(state)
    if state.transition.cat == 'fadeIn' then
        drawFadeIn(state)
    elseif state.transition.cat == 'fadeOut' then
        drawFadeOut(state)
    elseif state.transition.cat == 'enemyEncounter' then
        drawBattleTransition(state)
    end
end    

return transitions;