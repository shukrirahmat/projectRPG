local mapHandler = require('mapHandler')
local trState = require('transitionState')
local battle = require('battle')

local transitionAnimation = {}

function transitionAnimation.battleFadeIn()
    
    battle.draw()
    
    local opacity = trState.timer / trState.fadeSpeed
    love.graphics.setColor(0, 0, 0, opacity)
    love.graphics.rectangle(
        'fill',
        0,
        0,
        windowWidth,
        windowHeight
    )
end
    

function transitionAnimation.drawBattleTransition()

    mapHandler.draw()  
    
    love.graphics.setColor(0, 0, 0)
    love.graphics.polygon(
        'fill',
        0,
        0,
        0,
        ( 1 - trState.timer / trState.speed ) * windowWidth,
        ( 1 - trState.timer / trState.speed ) * windowWidth,
        0
    )
    
    love.graphics.polygon(
        'fill',
        windowWidth,
        0,
        windowWidth - ( 1 - trState.timer / trState.speed ) * windowWidth,
        0,
        windowWidth,
        ( 1 - trState.timer / trState.speed ) * windowWidth
    )
    
    love.graphics.polygon(
        'fill',
        0,
        windowHeight,
        0,
        windowHeight - ( 1 - trState.timer / trState.speed ) * windowWidth,
        ( 1 - trState.timer / trState.speed ) * windowWidth,
        windowHeight
    )
    
    love.graphics.polygon(
        'fill',
        windowWidth,
        windowHeight,
        windowWidth - ( 1 - trState.timer / trState.speed ) * windowWidth,
        windowHeight,
        windowWidth,
        windowHeight - ( 1 - trState.timer / trState.speed ) * windowWidth
    )
end

return transitionAnimation