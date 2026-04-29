local fonts = require('fonts')

local textbox = {}

local queue = {}
local is_active = nil
local lines = nil
local current_line = nil
local visible_char = nil
local text_timer = nil
local blink_timer = nil
local lg = love.graphics

local TEXT_SPEED = 0.02
local BLINK_SPEED = 1
local HEIGHT = 140
local MARGIN_X = 20
local MARGIN_Y = MARGIN_X
local PADDING_X = 20
local PADDING_Y = 10

function textbox.load(strings)
    is_active = true
    lines = strings
    current_line = 1
    visible_char = 0
    text_timer = 0
    blink_timer = 0
end

function textbox.queue(strings)
    table.insert(queue, strings)
end

function textbox.skip()
    visible_char = #lines[current_line]
end

function textbox.is_finished()
    return visible_char == #lines[current_line]
end

function textbox.is_busy()
    return is_active or #queue > 0
end

function textbox.is_active()
    return is_active
end

function textbox.advance()
    if current_line < #lines then
        current_line = current_line + 1
        visible_char = 0
        text_timer = 0
    else
        textbox.close()
    end
end

function textbox.close()
    is_active = false;
    lines = {}
    visible_char = 0
end

function textbox.update(dt)

    if not is_active and #queue > 0 then
        textbox.load(table.remove(queue, 1))
    end

    if not is_active then return end

    text_timer = text_timer + dt
    while text_timer >= TEXT_SPEED and visible_char < #lines[current_line] do
        visible_char = visible_char + 1
        text_timer = text_timer - TEXT_SPEED
    end

    blink_timer = blink_timer + dt
    if blink_timer >= BLINK_SPEED then
        blink_timer = blink_timer - BLINK_SPEED
    end
end

function textbox.draw()

    local border_x = MARGIN_X
    local border_height = HEIGHT
    local border_y = lg.getHeight() - border_height - MARGIN_Y
    local border_width = lg.getWidth() - MARGIN_X * 2

    local text_x = border_x + PADDING_X
    local text_y = border_y + PADDING_Y
    local line_height = (border_height - PADDING_Y * 2) / 4
    local text_width = border_width - PADDING_X * 2  

    lg.setColor(1, 1, 1)
    lg.rectangle(
        'line',
        border_x,
        border_y,
        border_width,
        border_height
    )

    lg.setFont(fonts.large)
    for i = 1, current_line do
        local line = lines[i]
        if i == current_line then
            line = line:sub(1, math.min(visible_char, #line))
        end
        lg.printf(
            line,
            text_x,
            text_y + (i - 1) * line_height,
            text_width
        )
    end

    if textbox.is_finished() and (blink_timer / BLINK_SPEED) <= 0.5 then
        lg.setColor(1, 1, 1)
        lg.polygon(
            'fill',
            border_x + border_width - 30,
            border_y + border_height - 20,
            border_x + border_width - 10,
            border_y + border_height - 20,
            border_x + border_width - 20,
            border_y + border_height - 10
        )
    end
end

return textbox