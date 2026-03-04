local trState = require('transitionState')
local trAnimation = require('transitionAnimation')
local gameState = require('gameState')
local battle = require('battle')

local transition = {}

function transition.load()
    trState.timer = trState.speed;
end

function transition.update(dt)
    if trState.timer > 0 then
        trState.timer = trState.timer - dt
    elseif trState.timer < 0 then
        if trState.transitionType == 'battleTransition' then
            trState.transitionType = 'battleFadeIn'
            trState.timer = trState.fadeSpeed
        elseif trState.transitionType == 'battleFadeIn' then
            trState.transitionType = nil
            trState.timer = trState.speed
            gameState.currentState = battle
        end
    end
end

function transition.draw()
    if trState.transitionType == 'battleTransition' then
        trAnimation.drawBattleTransition()
    elseif trState.transitionType == 'battleFadeIn' then
        trAnimation.battleFadeIn()
    end
end

function transition.keypressed(key)
end


return transition