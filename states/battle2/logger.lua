local gameState = require('gameState')

local logger = {}

local state = {}

function logger.load(text)
    state.text = text
    state.isActive = true
    state.timer = 0
    state.speed = gameState.battleSpeed
    state.height = gameState.textHeight
end

function logger.isActive()
    return state.isActive
end

function logger.update(dt)
    if not state.isActive then return end

    state.timer = state.timer + dt
    if state.timer >= state.speed then
        state.timer = 0
        state.text = nil
        state.isActive = false
    end
end

function logger.draw()

    local marginX = 20
    local marginY = marginX
    local paddingX = 20
    local paddingY = 10

    local borderX = marginX
    local borderHeight = state.height
    local borderY = windowHeight - borderHeight - marginY
    local borderWidth = windowWidth - marginX * 2

    local textX = borderX + paddingX
    local textY = borderY + paddingY
    local lineHeight = (borderHeight - paddingY * 2) / 4
    local textWidth = borderWidth - paddingX * 2 

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
        'line',
        borderX,
        borderY,
        borderWidth,
        borderHeight
    )

    love.graphics.setFont(font_large)
    love.graphics.printf(
        state.text,
        textX,
        textY,
        textWidth
    )
end

return logger