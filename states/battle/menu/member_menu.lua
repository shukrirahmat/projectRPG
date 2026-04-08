local fonts = require('fonts')
local input = require('input')
local renderer = require('helpers.renderer')

local member_menu = {}

local menu = nil
local member_index = nil
local member = nil
local is_active = false
local position = nil
local list = nil
local border_width = nil
local lg = love.graphics
local SPRITE_DIMENSION = 128

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

local function confirm(action)
    if position == 1 then
        local alive_enemy = menu.get_alive_targets(menu.enemies)
        if #alive_enemy == 1 then
            is_active = false
            menu.set_action('normal_attack', member, {alive_enemy[1]})
            menu.next_party_member(member_index + 1)
        else
            menu.open_target_menu('normal_attack', alive_enemy, member_menu, member, member_index)
        end
    elseif position == 2 then
        menu.open_skill_menu(member_menu, member, member_index)
    elseif position == 3 then
        is_active = false
        menu.set_action('defend', member, {member})
        menu.next_party_member(member_index + 1)
    end
end

local function back()
    is_active = false
    menu.previous_party_member(member_index - 1)
end


function member_menu.load(parent_menu, index)

    menu = parent_menu
    member_index = index
    member = parent_menu.party[member_index]
    member.current_action = nil

    is_active = true
    position = 1
    list = {'ATTACK', 'SKILL', 'DEFEND', 'ITEM'}

    border_width = (menu.FULL_WIDTH - menu.GAP * 2 ) * 0.4
end

function member_menu.draw()
    local border_height = menu.FULL_HEIGHT
    local border_x = menu.MARGIN_X
    local border_y = lg.getHeight() - border_height - menu.MARGIN_Y
    local section_width = border_width / 2
    local option_x = border_x + menu.PADDING_X + section_width
    local option_y = border_y + menu.PADDING_Y
    local option_width = section_width - menu.PADDING_X * 2
    local option_height = menu.OPTION_HEIGHT

    lg.setColor(1, 1, 1)
    lg.rectangle('line', border_x, border_y, border_width, border_height)
    lg.rectangle('line', border_x + 10, border_y + 10, section_width - 20, border_height - 20)

    lg.setColor(1, 1, 1)
    lg.line(
        border_x + section_width, 
        border_y, 
        border_x + section_width,
        border_y + border_height
    )

    local sprite_x = border_x + (section_width - SPRITE_DIMENSION) / 2
    local sprite_y = border_y + (border_height - SPRITE_DIMENSION) / 2
    member:draw(sprite_x, sprite_y)

    lg.setColor(1, 1, 1)
    lg.setFont(fonts.large)
    for i, option in ipairs(list) do

        if i == 2 and member.status['SEAL'] then
            lg.setColor(0.25, 0.25, 0.25)
        end

        lg.printf(
            option,
            option_x + 25,
            option_y + renderer.center_text(option_height) + (i - 1) * option_height,
            option_width,
            'left'
        )

        lg.setColor(1, 1, 1)
        if position == i then
            renderer.draw_option_cursor(
                option_x,
                option_y + (i - 1) * option_height,
                option_height
            )
        end
    end    
end

function member_menu.keypressed(key)
    if key == input.up then
        move_up()
    elseif key == input.down then
        move_down()
    elseif key == input.confirm then
        confirm()
    elseif key == input.back then
        back()
    end
end

function member_menu.is_active()
    return is_active
end

function member_menu.get_width()
    return border_width
end

function member_menu.close()
    is_active = false
end

return member_menu