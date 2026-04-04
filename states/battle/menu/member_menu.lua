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

local function get_alive_enemy(enemies)
    local alive = {}
    for i, enemy in ipairs(enemies) do
        if enemy:is_alive() then
            table.insert(alive, enemy)
        end
    end
    
    return alive
end

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
    if position == 1 then
        local alive_enemy = get_alive_enemy(menu.enemies)
        if #alive_enemy == 1 then
            is_active = false
            menu.set_action('normal_attack', member, {alive_enemy[1]})
            menu.next_party_member(member_index + 1)
        end
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
        moveUp()
    elseif key == input.down then
        moveDown()
    elseif key == input.confirm then
        confirm()
    elseif key == input.back then
        back()
    end
end

function member_menu.is_active()
    return is_active
end

return member_menu