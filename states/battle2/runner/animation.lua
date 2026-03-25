local hud = require('states.battle2.hud')
local enemySprites = require('states.battle2.enemySprites')

local animation = {}

local state = {}

function animation.load(animation)
    state.isActive = true
    enemySprites.animate(animation)
    hud.animate(animation)
end

function animation.update(dt)
    if not state.isActive then return end
    
    enemySprites.update(dt)
    hud.update(dt)
    
    if not hud.isAnimating() and not enemySprites.isAnimating() then
        state.isActive = false
    end
end

function animation.isActive()
    return state.isActive
end


return animation