local fonts = require('fonts')

local logger = {}

local SPEED = 1
local HEIGHT = 140
local MARGIN_X = 20
local MARGIN_Y = MARGIN_X
local PADDING_X = 20
local PADDING_Y = 10

local texts = nil
local is_active = false
local timer = 0
local callback = nil
local lg = love.graphics

function logger.load(text, callback_function)
    texts = {text}
    is_active = true
    timer = 0
    callback = callback_function or function() end
end

function logger.is_active()
    return is_active
end

function logger.update(dt)
    if not is_active then return end

    timer = timer + dt
    if timer >= SPEED then
        timer = 0
        is_active = false
        callback()
    end
end

function logger.draw()

    local borderX = MARGIN_X
    local borderHeight = HEIGHT
    local borderY = lg.getHeight() - borderHeight - MARGIN_Y
    local borderWidth = lg.getWidth() - MARGIN_X * 2

    local textX = borderX + PADDING_X
    local textY = borderY + PADDING_Y
    local lineHeight = (borderHeight - PADDING_Y * 2) / 4
    local textWidth = borderWidth - PADDING_X * 2 

    lg.setColor(1, 1, 1)
    lg.rectangle(
        'line',
        borderX,
        borderY,
        borderWidth,
        borderHeight
    )
        
    lg.setFont(fonts.large)
    for i, text in ipairs(texts) do
        lg.printf(
            text,
            textX,
            textY + (i - 1) * lineHeight,
            textWidth
        )
    end
end

return logger