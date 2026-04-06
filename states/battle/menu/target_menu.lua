local fonts = require('fonts')
local input = require('input')
local renderer = require('helpers.renderer')

local target_menu = {}

local menu = nil
local list = nil
local prev_menu = nil
local member = nil
local member_index = nil
local position = nil
local is_active = nil
local lg = love.graphics

local function moveUp()
    if position > 1 then
        position = position - 1
    end
end

local function moveDown()
    if position < #list then
        position = position + 1
    end
end

local function confirm(action)
    local target = list[position]
    is_active = false
    menu.set_action('normal_attack', member, {target})
    menu.next_party_member(member_index + 1)
end

local function back()
    is_active = false
    menu.cancel(prev_menu)
end

function target_menu.load(parent_menu, targets, _prev_menu, _member, _member_index)
    menu = parent_menu
    list = targets
    prev_menu = _prev_menu
    member = _member
    member_index = _member_index
    
    position = 1
    is_active = true
end

function target_menu.draw()
    local border_height = menu.FULL_HEIGHT
    local border_x = menu.MARGIN_X + menu.GAP + prev_menu.get_width()
    local border_y = lg.getHeight() - border_height - menu.MARGIN_Y
    local border_width = (menu.FULL_WIDTH - menu.GAP * 2 ) * 0.2
    local option_x = border_x + menu.PADDING_X
    local option_y = border_y + menu.PADDING_Y
    local cursor_space = 20
    local option_width = border_width - menu.PADDING_X * 2
    local option_height = menu.OPTION_HEIGHT
    
    lg.setColor(1, 1, 1)
    lg.rectangle('line', border_x, border_y, border_width, border_height)
    
    if #list < 1 then
        lg.setFont(fonts.large)
        lg.setColor(1, 1, 1)
        lg.printf(
            'There is no available target.',
            option_x,
            option_y + renderer.center_text(option_height),
            option_width
        )
        return
    end
    
    local first_page = {}
    local second_page = {}
    local current_page

    for i = 1, #list  do
        if i < 5 then
            table.insert(first_page, list[i])
        else
            table.insert(second_page, list[i])
        end
    end

    if position < 5 then
        current_page = first_page
    else
        current_page = second_page
    end
    
    lg.setFont(fonts.large)
    lg.setColor(1, 1, 1)
    for i, target in ipairs(current_page) do
        lg.printf(
            target.name,
            option_x + cursor_space,
            option_y + renderer.center_text(option_height) + (i - 1) * option_height,
            option_width
        )
        local pointer = i
        if current_page == second_page then
            pointer = i + 4
        end
        if position == pointer then
            renderer.draw_option_cursor(
                option_x,
                option_y + (i - 1) * option_height,
                option_height
            )
        end
    end

    if #second_page > 0 then
        if current_page == first_page then
            renderer.draw_downward_arrow(border_x, border_y, border_width, border_height)
        else
            renderer.draw_upward_arrow(border_x, border_y, border_width, border_height)
        end
    end
end

function target_menu.keypressed(key)
    if key == input.up then
        moveUp()
    elseif key == input.down then
        moveDown()
    elseif key == input.confirm then
        confirm()
    elseif key == input.back then
        back()
    end
end

function target_menu.is_active()
    return is_active
end

return target_menu