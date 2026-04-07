local action_data = require('data.action_data')
local fonts = require('fonts')
local renderer = require('helpers.renderer')


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

local function draw_description_text(skill, border_x, border_y)
    local x = border_x + border_width + menu.GAP
    local y = border_x
    local width = (menu.FULL_WIDTH - menu.GAP * 2) * 0.2
    lg.setColor(1, 1, 1)
    lg.rectangle(
        'line',
        x,
        y,
        width,
        menu.FULL_HEIGHT
    )

    local header = 'MP cost: '..skill.cost..''
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
    member_index = member_index

    is_active = true
    position = 1
    list = {}
    is_targeting = false

    if member.skills and #member.skills > 0 then
        for i, skill in ipairs(member.skills) do
            table.insert(list, skill)
        end
    end

    border_width = (menu.FULL_WIDTH - menu.GAP * 2 ) * 0.4
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
    local page_end = math.min(list, page_start + SIZE - 1)
    
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

        lg.printf(
            skill.name,
            skill_x + cursor_space,
            skill_y + renderer.center_text(option_height),
            option_width
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