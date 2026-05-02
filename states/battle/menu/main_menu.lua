local fonts = require('fonts')
local input = require('input')
local renderer = require('helpers.renderer')

local main_menu = {}

local menu = nil
local position = nil
local list = nil
local is_active = false
local lg = love.graphics

local function move_up()
    if position > 1 then
        position = position - 1
    end
end

local function move_down()
    if position < #list then
        position = position + 1
    end
end

local function confirm()
    if position == 1 then
        is_active = false
        menu.next_party_member(1)
    elseif position == 2 then
        is_active = false
        menu.flee_battle()
    end
end


function main_menu.load(parent_menu)
    menu = parent_menu
    position = 1
    list = {'Fight', 'Flee'}
    is_active = true
    
end

function main_menu.draw()
    local border_height = menu.FULL_HEIGHT
    local border_x = menu.MARGIN_X
    local border_y = lg.getHeight() - border_height - menu.MARGIN_Y
    local border_width = (menu.FULL_WIDTH - menu.GAP * 2) * 0.2
    local option_x = border_x + menu.PADDING_X
    local option_y = border_y + menu.PADDING_Y
    local option_width = border_width - menu.PADDING_X * 2
    local option_height = menu.OPTION_HEIGHT

    lg.setColor(0,0,0)
    lg.rectangle('fill', border_x, border_y, border_width, border_height)
    lg.setColor(1, 1, 1)
    lg.rectangle('line', border_x, border_y, border_width, border_height)

    lg.setColor(1, 1, 1)
    lg.setFont(fonts.large)
    for i, option in ipairs(list) do
        lg.printf(
            option,
            option_x,
            option_y + renderer.center_text(option_height) + (i - 1) * option_height,
            option_width,
            'center'
        )
        if position == i then
            renderer.draw_option_cursor(
                option_x,
                option_y + (i - 1) * option_height,
                option_height
            )
        end
    end
end

function main_menu.keypressed(key)
    if key == input.up then
        move_up()
    elseif key == input.down then
        move_down()
    elseif key == input.confirm then
        confirm()
    end
    
end

function main_menu.is_active()
    return is_active
end

return main_menu