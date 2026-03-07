local gameState = require('gameState')
local transitionAnimation = require('states.transition.transitionAnimation')
local sprites = require('graphics.sprites')

local transition = {}

local state = {}

function transition.load(stateManager, var)
    state.manager = stateManager
    state.transitionType = var.transitionType
    state.prevState = var.prevState
    state.nextMap = var.nextMap;
    state.timerSpeed = 0.5;
    state.timer = state.timerSpeed
end

function transition.update(dt)
    state.timer = state.timer - dt
    if state.timer <= 0 then
        if state.transitionType == 'fadeIn' then
            local nextState = state.toSwitch
            state.transitionType = nil
            state,toSwitch = nil
            state.timer = state.timerSpeed
            state.manager.switch(state.nextState)
        elseif state.transitionType == 'travel' then
            gameState.currentMap = state.nextMap
            gameState.playerPos = state.nextMap.startPos
            gameState.playerSprite = sprites.player_front[1]
            state.transitionType = 'fadeIn'
            state.toSwitch = 'field'
            state.timer = state.timerSpeed
            state.nextMap = nil
        end
    end
end

function transition.draw()
    transitionAnimation.draw(state)
end

function transition.keypressed()
end

return transition