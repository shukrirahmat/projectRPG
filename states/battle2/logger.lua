local gameState = require('gameState')

local logger = {}

local state = {}

function logger.load(text)
    state.text = {text}
    state.isActive = true
    state.timer = 0
    state.speed = gameState.battleSpeed
    state.height = gameState.textHeight
end

function logger.add(text)
    
    if #state.text > 4 then
        table.remove(state.text, 1)
    end
    
    table.insert(state.text, text)
    state.isActive = true
    state.timer = 0
end


function logger.isActive()
    return state.isActive
end

function logger.update(dt)
    if not state.isActive then return end

    state.timer = state.timer + dt
    if state.timer >= state.speed then
        state.timer = 0
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

    for i, text in ipairs(state.text) do
        love.graphics.setFont(font_large)
        love.graphics.printf(
            text,
            textX,
            textY + (i - 1) * lineHeight,
            textWidth
        )
    end
end

return logger