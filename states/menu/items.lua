local input = require('input')
local fonts = require('fonts')
local item_data = require('data.item_data')
local renderer = require('helpers.renderer')

local Items = {}

local Menu = nil
local Party = nil
local lg = love.graphics
local position = nil
local list = {}

function Items.load(menu, party)
    Menu = menu
    Party = party
    position = 1
    list = {}
    
    for k, v in pairs(party.items) do
        local id = item_data[k].id
        table.insert(list, {item = k, amount = v, id = id})
    end

    table.sort(list, function(a, b) return a.id < b.id end)
end

function Items.draw(screen)
    local page = {}
    page.width = screen.width * 0.6
    page.height = screen.height - 140 - 20
    page.items_per_page = 20
    page.padding_x = 20
    page.padding_y = 20
    page.line_height = (page.height - page.padding_y * 2) / (page.items_per_page * 0.5)
    page.current = math.floor((position - 1) / page.items_per_page) + 1
    page.start_index = (page.current - 1) * page.items_per_page + 1
    page.end_index = math.min(#list, page.current * page.items_per_page)
    page.cursor_space = 20
    page.half_width = page.width * 0.5 - page.padding_x * 2 - page.cursor_space
    page.total = math.max(1, math.ceil(#list / page.items_per_page))
    
    lg.rectangle('line', screen.margin_x, screen.margin_y, page.width, page.height)
    
    if page.current < page.total then
        renderer.draw_downward_arrow(screen.margin_x, screen.margin_y, page.width, page.height, 1.5)
    end
    
    if page.current > 1 then
        renderer.draw_upward_arrow(screen.margin_x, screen.margin_y, page.width, page.height, 1.5)
    end
    
    for i = page.start_index, page.end_index do
        local data = item_data[list[i].item]
        local amount = list[i].amount
        
        local x;
        local y;
        
        local item_on_page = ((i - 1) % page.items_per_page) + 1
        if item_on_page % 2 ~= 0 then
            x = screen.margin_x + page.padding_x + page.cursor_space
        else
            x = screen.margin_x + (page.width * 0.5) + page.padding_x + page.cursor_space
        end
        
        local line = math.floor((item_on_page - 1) / 2) + 1
        y = screen.margin_y + page.padding_y + (line - 1) * page.line_height
        
        lg.setFont(fonts.large)
        lg.printf(data.name, x, y + renderer.center_text(page.line_height), page.half_width, 'left')
        lg.printf('x'..amount..'', x, y + renderer.center_text(page.line_height), page.half_width, 'right')
        
        if position == i then
            renderer.draw_option_cursor(x - page.cursor_space, y, page.line_height)
        end
    end

end

function Items.keypressed(key)
    if key == input.back then
        Items.back()
    elseif key == input.up then
        Items.move_up()
    elseif key == input.down then
        Items.move_down()
    elseif key == input.left then
        Items.move_left()
    elseif key == input.right then
        Items.move_right()
    end
end

function Items.back()
    Menu.switch_phase('main')
end

function Items.move_up()
    if position - 2 >= 1 then
        position = position - 2
    end
end

function Items.move_down()
    if position + 2 <= #list then
        position = position + 2
    elseif position % 2 == 0 and position + 1 == #list then
        position = position + 1
    end
end

function Items.move_left()
    if position % 2 == 0 and position - 1 >= 1 then
        position = position - 1
    end
end

function Items.move_right()
    if position % 2 ~= 0 and position + 1 <= #list then
        position = position + 1
    end
end

return Items
    