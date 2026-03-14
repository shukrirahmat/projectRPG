local gameState = require('gameState')

local textBox = {}

local text = {}

function textBox.start(string)
    text.open = true
    text.string = string
    text.visible = 0
    text.timer = 0
    text.speed = gameState.textSpeed
    text.blink = 0
    text.blinkSpeed = 1
end

function textBox.skip()
    text.visible = #text.string
end

function textBox.isFinished()
    return text.visible == #text.string
end

function textBox.isOpen()
    return text.open
end

function textBox.close()
    text.open = false;
    text.string = '';
    text.visible = 0
end

function textBox.update(dt)
    text.timer = text.timer + dt
    while text.timer >= text.speed and text.visible < #text.string do
        text.visible = text.visible + 1
        text.timer = text.timer - text.speed
    end
    
    text.blink = text.blink + dt
    if text.blink >= text.blinkSpeed then
        text.blink = text.blink - text.blinkSpeed
    end
end

function textBox.draw()
    local borderX = 10
    local borderHeight = gameState.textHeight
    local borderY = windowHeight - borderHeight - 10
    local borderWidth = windowWidth - borderX * 2

    local textX = borderX + 20
    local textY = borderY + 10
    local textLineHeight = 20
    local textWidth = borderWidth - textX * 2 

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
        'line',
        borderX,
        borderY,
        borderWidth,
        borderHeight
    )

    if text.visible > 0 then
        love.graphics.setFont(font_text)
        love.graphics.printf(
            text.string:sub(1, text.visible),
            textX,
            textY,
            textWidth
        )
    end
    
    if textBox.isFinished and (text.blink / text.blinkSpeed) <= 0.5 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.polygon(
            'fill',
            borderX + borderWidth - 30,
            borderY + borderHeight - 20,
            borderX + borderWidth - 10,
            borderY + borderHeight - 20,
            borderX + borderWidth - 20,
            borderY + borderHeight - 10
        )
    end
end

return textBox