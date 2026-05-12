local action_data = require('data.action_data')
local item_data = require('data.item_data')
local fonts = require('fonts')
local renderer = require('helpers.renderer')
local input = require('input')

local item_menu = {}

local menu = nil
local prev_menu = nil
local member = nil
local member_index = nil
local is_active = false
local position = nil
local list = nil
local border_width = nil
local SIZE = 8
local lg = love.graphics

local function move_up()
    if position - 2 >= 1 then
        position = position - 2
    end
end

local function move_down()
    if position + 2 <= #list then
        position = position + 2
    elseif position % 2 == 0 and position + 1 == #list then
        position = position + 1
    end
end

local function move_left()
    if position % 2 == 0 and position - 1 >= 1 then
        position = position - 1
    end
end

local function move_right()
    if position % 2 ~= 0 and position + 1 <= #list then
        position = position + 1
    end
end

local function confirm()
    local item = list[position].item
    local skill = action_data[item]

    local group = menu.enemy_battlers
    if skill.aim == 'allies' then
        group = menu.party_battlers
    end

    if skill.scope =='single' then
        local targets = menu.get_alive_targets(group)
        if #targets == 1 and skill.aim ~= 'allies' then
            is_active = false
            menu.set_action(item, member, {targets[1]})
            member.using_item = item
            menu.remove_item(item)
            menu.next_party_member(member_index + 1)
        else
            if skill.aim == 'allies' and skill.exclude_self then
                targets = menu.get_alive_targets_exclusive(member, group)
            end
            menu.open_target_selection(item, targets, item_menu, member, member_index)
        end
    elseif skill.scope == 'all' then
        is_active = false
        menu.set_action(item, member, {unpack(group)})
        member.using_item = item
        menu.remove_item(item)
        menu.next_party_member(member_index + 1)
    elseif skill.scope =='self' then
        is_active = false
        menu.set_action(item, member, {member})
        member.using_item = item
        menu.remove_item(item)
        menu.next_party_member(member_index + 1)
    elseif skill.scope =='dead' then
        local targets = menu.get_dead_targets(group)
        menu.open_target_selection(item, targets, item_menu, member, member_index)
    end
end

local function back()
    is_active = false;
    menu.cancel(prev_menu)
end

local function draw_description_text(item, border_x, border_y)
    local x = border_x + border_width + menu.GAP
    local y = border_y
    local width = (menu.FULL_WIDTH - menu.GAP * 2) * 0.2
    
    lg.setColor(0, 0, 0)
    lg.rectangle('fill', x, y, width, menu.FULL_HEIGHT)
    lg.setColor(1, 1, 1)
    lg.rectangle('line', x, y, width, menu.FULL_HEIGHT)


    local header = 'Type : Consumables'
    lg.setFont(fonts.medium)
    lg.printf(
        header,
        x + menu.PADDING_X,
        y + menu.PADDING_Y + renderer.center_text(menu.OPTION_HEIGHT),
        width - menu.PADDING_X * 2
    )
    lg.line(
        x, y + menu.OPTION_HEIGHT + menu.PADDING_Y * 1.5, 
        x + width, y + menu.OPTION_HEIGHT + menu.PADDING_Y * 1.5)
    lg.setFont(fonts.medium)
    lg.printf(
        item.desc,
        x + menu.PADDING_X,
        y + menu.OPTION_HEIGHT + menu.PADDING_Y * 2 + renderer.center_text(menu.OPTION_HEIGHT),
        width - menu.PADDING_X * 2
    )
end


function item_menu.load(_menu, _prev_menu, _member, _member_index)
    menu = _menu
    prev_menu = _prev_menu
    member = _member
    member_index = _member_index

    is_active = true
    position = 1
    list = {}

    for k, v in pairs(menu.get_party_items()) do
        local id = item_data[k].id
        table.insert(list, {item = k, amount = v, id = id})
    end

    table.sort(list, function(a, b) return a.id < b.id end)

    border_width = (menu.FULL_WIDTH - menu.GAP * 2 ) * 0.5
end

function item_menu.draw()
    local border_height = menu.FULL_HEIGHT
    local border_x = menu.MARGIN_X + prev_menu.get_width() + menu.GAP
    local border_y = lg.getHeight() - border_height - menu.MARGIN_Y
    local option_x = border_x + menu.PADDING_X
    local option_y = border_y + menu.PADDING_Y
    local text_width = border_width - menu.PADDING_X * 2
    local option_width = (border_width / 2) - menu.PADDING_X * 2
    local option_height = menu.OPTION_HEIGHT
    local cursor_space = 20

    lg.setColor(0,0,0)
    lg.rectangle('fill', border_x, border_y, border_width, border_height)
    lg.setColor(1,1,1)
    lg.rectangle('line', border_x, border_y, border_width, border_height)

    if #list == 0 then
        local name = member.name
        local text ='The party did not have any items.'
        lg.setFont(fonts.large)
        lg.printf(
            text,
            option_x,
            option_y + renderer.center_text(option_height),
            text_width,
            'left'
        )
        return
    end

    local current_page = math.ceil(position / SIZE)
    local page_start = (current_page - 1) * SIZE + 1;
    local page_end = math.min(#list, page_start + SIZE - 1)

    for i = page_start, page_end do
        lg.setFont(fonts.large)
        lg.setColor(1, 1, 1)

        local item = item_data[list[i].item]

        local item_x = option_x
        if i % 2 == 0 then
            item_x = item_x + border_width / 2
        end
        local item_pos = math.ceil((((i - 1) % SIZE) + 1) / 2)
        local item_y = border_y + menu.PADDING_Y + (item_pos - 1) * option_height

        lg.setFont(fonts.large)
        lg.printf(
            item.name,
            item_x + cursor_space,
            item_y + renderer.center_text(option_height),
            option_width,
            'left'
        )

        local amount_text = 'x'..list[i].amount..''

        lg.setFont(fonts.medium_mono)
        lg.printf(
            amount_text,
            item_x,
            item_y + renderer.center_text(option_height),
            option_width,
            'right'
        )

        lg.setColor(1, 1, 1)
        if position == i then
            renderer.draw_option_cursor(item_x, item_y, option_height)
                draw_description_text(item, border_x, border_y)
        end

        if math.ceil(#list / SIZE) > 1 then
            if math.ceil(position / SIZE) == 1 then
                renderer.draw_downward_arrow(border_x, border_y, border_width, border_height)
            elseif math.ceil(position / SIZE) == math.ceil(#list / SIZE) then
                renderer.draw_upward_arrow(border_x, border_y, border_width, border_height)
            else
                renderer.draw_upward_arrow(border_x, border_y, border_width, border_height)
                renderer.draw_downward_arrow(border_x, border_y, border_width, border_height)
            end
        end
    end
end

function item_menu.keypressed(key)
    if #list > 0 then
        if key == input.up then
            move_up()
        elseif key == input.down then
            move_down()
        elseif key == input.left then
            move_left()
        elseif key == input.right then
            move_right()
        elseif key == input.confirm then
            confirm()
        end
    end

    if key == input.back then
        back()
    end
end

function item_menu.is_active()
    return is_active
end

function item_menu.get_width()
    return border_width + prev_menu.get_width() + menu.GAP
end

function item_menu.close()
    is_active = false
end

return item_menu