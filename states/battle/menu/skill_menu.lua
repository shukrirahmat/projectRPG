local action_data = require('data.action_data')
local fonts = require('fonts')
local renderer = require('helpers.renderer')
local input = require('input')


local skill_menu = {}

local menu = nil
local prev_menu = nil
local member = nil
local member_index = nil
local is_active = nil
local SIZE = 8
local position = nil
local list = nil
local is_targeting = nil
local border_width = nil
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
    local skill_ref = list[position]
    local skill = action_data[skill_ref]

    if member.current_mp < skill.cost then
        return
    end

    local group = menu.enemies
    if skill.aim == 'allies' then
        group = menu.party
    end

    if skill.scope =='single' then
        local targets = menu.get_alive_targets(group)
        if #targets == 1 then
            is_active = false
            menu.set_action(skill_ref, member, {targets[1]})
            menu.next_party_member(member_index + 1)
        else
            is_targeting = true
            menu.open_target_menu(skill_ref, targets, skill_menu, member, member_index)
        end
    elseif skill.scope == 'all' then
        is_active = false
        menu.set_action(skill_ref, member, {unpack(group)})
        menu.next_party_member(member_index + 1)
    elseif skill.scope =='self' then
        is_active = false
        menu.set_action(skill_ref, member, {member})
        menu.next_party_member(member_index + 1)
    elseif skill.scope =='dead' then
        is_targeting = true
        local targets = menu.get_dead_targets(group)
        menu.open_target_menu(targets, skill_menu, member, member_index)
    end
end

local function back()
    is_active = false;
    menu.cancel(prev_menu)
end

local function draw_description_text(skill, border_x, border_y)
    local x = border_x + border_width + menu.GAP
    local y = border_y
    local width = (menu.FULL_WIDTH - menu.GAP * 2) * 0.2
    lg.setColor(1, 1, 1)
    lg.rectangle(
        'line',
        x,
        y,
        width,
        menu.FULL_HEIGHT
    )

    
    local header = 'Type : '..skill.type..''
    lg.setFont(fonts.large)
    lg.printf(
        header,
        x + menu.PADDING_X,
        y + menu.PADDING_Y + renderer.center_text(menu.OPTION_HEIGHT),
        width - menu.PADDING_X * 2
    )
    lg.line(
        x, y + menu.OPTION_HEIGHT + menu.PADDING_Y * 1.5, 
        x + width, y + menu.OPTION_HEIGHT + menu.PADDING_Y * 1.5)
    lg.setFont(fonts.large)
    lg.printf(
        skill.desc,
        x + menu.PADDING_X,
        y + menu.OPTION_HEIGHT + menu.PADDING_Y * 2 + renderer.center_text(menu.OPTION_HEIGHT),
        width - menu.PADDING_X * 2
    )
end


---PUBLIC


function skill_menu.load(_menu, _prev_menu, _member, _member_index)
    menu = _menu
    prev_menu = _prev_menu
    member = _member
    member_index = _member_index

    is_active = true
    position = 1
    list = {}
    is_targeting = false

    if member.skills and #member.skills > 0 then
        for i, skill in ipairs(member.skills) do
            table.insert(list, skill)
        end
    end

    border_width = (menu.FULL_WIDTH - menu.GAP * 2 ) * 0.5
end

function skill_menu.draw()
    local border_height = menu.FULL_HEIGHT
    local border_x = menu.MARGIN_X + prev_menu.get_width() + menu.GAP
    local border_y = lg.getHeight() - border_height - menu.MARGIN_Y
    local option_x = border_x + menu.PADDING_X
    local option_y = border_y + menu.PADDING_Y
    local text_width = border_width - menu.PADDING_X * 2
    local option_width = (border_width / 2) - menu.PADDING_X * 2
    local option_height = menu.OPTION_HEIGHT
    local cursor_space = 20

    lg.setColor(1,1,1)
    lg.rectangle('line', border_x, border_y, border_width, border_height)

    if #list == 0 then
        local name = member.name
        local text =''..name..' have not learned any skills.'
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

        local skill = action_data[list[i]]
        if member.current_mp < skill.cost then
            lg.setColor(0.25, 0.25, 0.25)
        end

        local skill_x = option_x
        if i % 2 == 0 then
            skill_x = skill_x + border_width / 2
        end
        local skill_pos = math.ceil((((i - 1) % SIZE) + 1) / 2)
        local skill_y = border_y + menu.PADDING_Y + (skill_pos - 1) * option_height

        lg.setFont(fonts.large)
        lg.printf(
            skill.name,
            skill_x + cursor_space,
            skill_y + renderer.center_text(option_height),
            option_width,
            'left'
        )
        
        lg.setFont(fonts.large_mono)
        lg.printf(
            ''..skill.cost..'',
            skill_x,
            skill_y + renderer.center_text(option_height),
            option_width,
            'right'
        )

        lg.setColor(1, 1, 1)
        if position == i then
            renderer.draw_option_cursor(skill_x, skill_y, option_height)
            if not is_targeting then
                draw_description_text(skill, border_x, border_y)
            end
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

function skill_menu.keypressed(key)
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

function skill_menu.is_active()
    return is_active
end

function skill_menu.get_width()
    return border_width + prev_menu.get_width() + menu.GAP
end

function skill_menu.close()
    is_active = false
end

function skill_menu.stop_targeting()
    is_targeting = false
end

return skill_menu