local transitionAnimation = require('states.transition.transitionAnimation')

local transition = {}

local state = {}

function transition.load(transitionType, prevState, nextMap)
    state.transitionType = transitionType
    state.prevState = prevState
    state.timer = 0;
    state.timerMax = 0.5;
    state.nextMap = nextMap;
end

function transition.update(dt)
    state.timer = state.timer + dt
    if state.timer >= state.timerMax then
        state.timer = 0
    end
end

function transition.draw()
    state.prevState.draw()
    transitionAnimation.draw(state)
end

function transition.keypressed()
end

return transition