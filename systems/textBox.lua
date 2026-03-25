local gameState = require('gameState')

local textBox = {}

local text = {
    queue = {}
}

function textBox.load(strings)
    text.isActive = true
    text.lines = strings
    text.currentLine = 1
    text.visible = 0
    text.timer = 0
    text.speed = gameState.textSpeed
    text.blink = 0
    text.blinkSpeed = 1
end

function textBox.queue(strings)
    table.insert(text.queue, strings)
end

function textBox.skip()
    text.visible = #text.lines[text.currentLine]
end

function textBox.isFinished()
    return text.visible == #text.lines[text.currentLine]
end

function textBox.isBusy()
    return text.isActive or #text.queue > 0
end

function textBox.isActive()
    return text.isActive
end

function textBox.advance()
    if text.currentLine < #text.lines then
        text.currentLine = text.currentLine + 1
        text.visible = 0
        text.timer = 0
    else
        textBox.close()
    end
end

function textBox.close()
    text.isActive = false;
    text.lines = {}
    text.visible = 0
end

function textBox.update(dt)

    if not text.isActive and #text.queue > 0 then
        textBox.load(table.remove(text.queue, 1))
    end

    if not text.isActive then return end

    text.timer = text.timer + dt
    while text.timer >= text.speed and text.visible < #text.lines[text.currentLine] do
        text.visible = text.visible + 1
        text.timer = text.timer - text.speed
    end

    text.blink = text.blink + dt
    if text.blink >= text.blinkSpeed then
        text.blink = text.blink - text.blinkSpeed
    end
end

function textBox.draw()
    
    local marginX = 20
    local marginY = marginX
    local paddingX = 20
    local paddingY = 10

    local borderX = marginX
    local borderHeight = gameState.textHeight
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
    for i = 1, text.currentLine do
        local line = text.lines[i]
        if i == text.currentLine then
            line = line:sub(1, math.min(text.visible, #line))
        end
        love.graphics.printf(
            line,
            textX,
            textY + (i - 1) * lineHeight,
            textWidth
        )
    end

    if textBox.isFinished() and (text.blink / text.blinkSpeed) <= 0.5 then
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