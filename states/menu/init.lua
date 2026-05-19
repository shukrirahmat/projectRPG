local order = require('states.menu.order')
local stats = require('states.menu.stats')
local transitions = require('systems.transitions')
local input = require('input')
local fonts = require('fonts')
local party_sprites = require('graphics.party_sprites')
local ui = require('graphics.ui')
local exp_data = require('data.exp_data')
local renderer = require('helpers.renderer')

local menu = {}

local lg = love.graphics
local list = nil
local position = nil
local phase = nil

local profile_gap = nil
local profile_padding = nil
local profile_width = nil
local profile_height = nil

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

function menu.load(game)
    menu.game = game
    menu.MARGIN_X = 20
    menu.MARGIN_Y = 20
    menu.HEIGHT = lg.getHeight() - menu.MARGIN_Y * 2
    menu.WIDTH = lg.getWidth() - menu.MARGIN_X * 2
    menu.LEFT_WIDTH = menu.WIDTH * 0.2
    menu.LIST_HEIGHT = menu.HEIGHT * 0.8
    menu.LIST_LINE_HEIGHT = menu.LIST_HEIGHT * 0.1
    menu.BOTTOM_Y = menu.LIST_HEIGHT + menu.MARGIN_Y
    menu.BOTTOM_PADDING_Y = 20
    
    profile_gap = 10
    profile_padding = 50
    profile_width = menu.WIDTH - menu.LEFT_WIDTH - profile_padding
    profile_height = (menu.HEIGHT - profile_gap * 3) / 4

    menu.party = game.party
    list = {'Skill', 'Item', 'Equip', 'Stats', 'Order'}
    position = 1
    phase = 'main'
end

function menu.update(dt)
end

function menu.draw()
    if phase == 'main' or phase == 'order' then
        menu.draw_main()
    elseif phase == 'stats' then
        stats.draw(menu.MARGIN_X, menu.MARGIN_Y, profile_width, profile_height)
    end
end

function menu.draw_main()
    lg.setColor(1, 1, 1)
    lg.rectangle('line', menu.MARGIN_X, menu.MARGIN_Y, menu.LEFT_WIDTH, menu.HEIGHT)
    lg.line(menu.MARGIN_X, menu.BOTTOM_Y, menu.MARGIN_X + menu.LEFT_WIDTH , menu.BOTTOM_Y)

    lg.setFont(fonts.large)
    lg.printf(
        'Gold : '..menu.party.gold..'',
        menu.MARGIN_X,
        menu.BOTTOM_Y + menu.BOTTOM_PADDING_Y,
        menu.LEFT_WIDTH,
        'center'
    )

    ----MEMBER STATS----

    for i, member in ipairs(menu.party.members) do
        local box_width = profile_width
        local box_height = profile_height
        local box_x = menu.MARGIN_X + menu.LEFT_WIDTH + profile_padding
        local box_y = menu.MARGIN_Y + (i - 1) * (box_height + profile_gap)

        if phase == 'order' then
            if order.has_lifted(member) then
                box_x = box_x - 40
            else
                order.draw(member, box_x, box_y, box_width, box_height)
            end
        end

        menu.draw_profile(member, box_x, box_y, box_width, box_height)
    end

    ----MENU OPTIONS----

    lg.setFont(fonts.xlarge)
    for i, option in ipairs(list) do
        local option_x = menu.MARGIN_X + 20
        local base_y = menu.MARGIN_Y + 10
        local option_y = base_y + (i - 1) * menu.LIST_LINE_HEIGHT + renderer.center_text(                         menu.LIST_LINE_HEIGHT)
        local option_width = menu.LEFT_WIDTH - 20 * 2
        local option_height = menu.LIST_LINE_HEIGHT
        lg.printf(option, option_x, option_y, option_width, 'center')

        if position == i then
            renderer.draw_option_cursor(
                option_x,
                base_y + (i - 1) * option_height,
                option_height
            )
        end
    end
end

function menu.draw_profile(member, x, y)
    local width = profile_width
    local height = profile_height
    local sprite_x = x
    local sprite_y = y
    local sprite_width = 128
    local sprite = member.sprite
    if member.is_dead then sprite = party_sprites.get_sprite('coffin') end

    if member.is_dead then
        lg.setColor(0.5, 0.5, 0.5)
    else
        lg.setColor(1, 1, 1)
    end

    lg.draw(sprite, sprite_x, sprite_y)
    lg.line(sprite_x + sprite_width, y, sprite_x + sprite_width, y + height)        
    lg.rectangle('line', x, y, width, height)

    local status_padding_x = 20
    local status_padding_y = 10
    local status_left_x = sprite_width + x + status_padding_x
    local status_left_y = y + status_padding_y
    local status_left_width = (width - sprite_width) * 0.4 - status_padding_x * 2
    local status_left_lh = (height - status_padding_y * 2) / 3

    lg.setFont(fonts.large)
    lg.printf(member.name, status_left_x, status_left_y, status_left_width, 'left')

    local se_count = 1
    local STATUS_ICON_SIZE = 16
    for k, v in pairs(member.status) do
        local xpos = status_left_x + status_left_width - STATUS_ICON_SIZE * se_count 
        local ypos = status_left_y + 3

        lg.draw(
            ui.get_sprite('status_icons'),
            ui.get_sprite(k),
            xpos,
            ypos
        )
        se_count = se_count + 1
    end

    lg.setFont(fonts.large_mono)

    lg.printf('HP', status_left_x, status_left_y + status_left_lh, status_left_width, 'left')

    local hp_color = {1, 1, 1}
    if member:is_alive() and member.current_hp/member.max_hp <= 0.2 then
        hp_color = {0.97, 0.28, 0.11}
    end
    local hp_text = { 
        hp_color, 
        ''..member.current_hp..'',
        { 1, 1, 1},
        ' / '..member.max_hp..''
    }
    lg.printf(hp_text, status_left_x, status_left_y + status_left_lh, status_left_width, 'right')

    local mp_text = ''..member.current_mp..' / '..member.max_mp..''
    lg.printf('MP', status_left_x, status_left_y + status_left_lh * 2, status_left_width, 'left')
    lg.printf(mp_text, status_left_x, status_left_y + status_left_lh * 2, status_left_width, 'right')

    lg.setColor(0.25, 0.25, 0.25)
    lg.rectangle('line', status_left_x, status_left_y + status_left_lh + 25, status_left_width, 4)
    lg.rectangle('line', status_left_x, status_left_y + status_left_lh * 2 + 25, status_left_width, 4)

    if member.is_dead then lg.setColor(0.5, 0.5, 0.5) else lg.setColor(0.75, 0.75, 0.75) end
    local hp_bar = (math.max(0, member.current_hp) / member.max_hp) * status_left_width
    local mp_bar = member.current_mp / member.max_mp * status_left_width
    lg.rectangle('fill', status_left_x, status_left_y + status_left_lh + 25, hp_bar, 4)
    lg.rectangle('fill', status_left_x, status_left_y + status_left_lh * 2 + 25, mp_bar, 4)

    if member.is_dead then lg.setColor(0.5, 0.5, 0.5) else lg.setColor(1, 1, 1) end

    local status_right_y = y + status_padding_y
    local status_right_width = (width - sprite_width) * 0.6 - status_padding_x * 4
    local status_right_x = x + width - status_right_width - status_padding_x * 2
    local status_right_lh = (height - status_padding_y * 2) / 4

    local bar_width = 206
    local bar_x = status_right_x + status_right_width - bar_width

    lg.setFont(fonts.large)
    lg.printf('LVL '..member.lvl..'', status_right_x, status_right_y, status_right_width, 'left')

    lg.rectangle('line', bar_x, status_right_y + 4, bar_width, 15)

    local current_exp = member.total_exp - exp_data[member.lvl]
    local diff_exp = exp_data[member.lvl + 1] - exp_data[member.lvl]
    local filled = bar_width * (current_exp / diff_exp)

    lg.rectangle('fill', bar_x, status_right_y + 4, filled, 15)

    local next_x = status_right_x
    local next_y = status_right_y + 25
    local next_width = status_right_width
    local next_exp = exp_data[member.lvl + 1]
    local remaining_exp = math.ceil(next_exp - member.total_exp)

    lg.setFont(fonts.medium)
    lg.printf('Next: '..remaining_exp..'', next_x, next_y, next_width, 'right')
end

function menu.keypressed(key)
    if phase == 'main' then
        if key == input.back then
            menu.close()
        elseif key == input.up then
            move_up()
        elseif key == input.down then
            move_down()
        elseif key == input.confirm then
            menu.select()
        end
    elseif phase == 'order' then
        order.keypressed(key)
    elseif phase == 'stats' then
        stats.keypressed(key)
    end
end

function menu.select()
    if position == 4 then
        stats.load(menu, menu.party)
        phase = 'stats'
    elseif position == 5 then
        order.load(menu, menu.party)
        phase = 'order'
    end
end

function menu.close()
    menu.game.switch_state('field')
end

function menu.switch_phase(new_phase)
    phase = new_phase
end

return menu