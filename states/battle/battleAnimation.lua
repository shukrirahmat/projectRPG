local battleAnimation = {}

function battleAnimation.run(state, dt)
    state.animation.timer = state.animation.timer + dt
    if state.animation.timer >= state.animation.speed then
        state.animation = nil
    end
end

return battleAnimation