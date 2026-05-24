local order = require('states.menu.order')
local stats = require('states.menu.stats')
local equip = require('states.menu.equip')
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
local member_index = nil

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

    menu.party = game.party
    list = {'Skill', 'Item', 'Equip', 'Stats', 'Order'}
    position = 1
    phase = 'main'
end

function menu.update(dt)
end

function menu.draw()
    
    local screen = {}
    screen.margin_x = menu.MARGIN_X
    screen.margin_y = menu.MARGIN_Y
    screen.height = menu.HEIGHT
    screen.width = menu.WIDTH

    local profile = {}
    profile.gap = 10
    profile.margin_x = 50
    profile.width = menu.WIDTH - menu.LEFT_WIDTH - profile.margin_x
    profile.height = (menu.HEIGHT - profile.gap * 3) / 4

    if phase == 'main' or phase == 'choose_member' or phase == 'order' then
        menu.draw_main(profile)
    elseif phase == 'stats' then
        stats.draw(screen, profile)
    elseif phase == 'equip' then
        equip.draw(screen)
    end
end

function menu.draw_main(profile)
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
        local x = menu.MARGIN_X + menu.LEFT_WIDTH + profile.margin_x
        local y = menu.MARGIN_Y + (i - 1) * (profile.height + profile.gap)
        
        if phase == 'choose_member' and member == menu.party.members[member_index] then
            menu.draw_cursor(member, x, y, profile)
        end

        if phase == 'order' then
            if order.has_moved(member) then
                x = x - 40
            end
        end

        menu.draw_profile(member, x, y, profile)
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

function menu.draw_cursor(member, x, y, profile)
    local vertical_center = y + profile.height * 0.5
    lg.polygon('fill', 
        x - 35, vertical_center - 20, 
        x - 35, vertical_center + 20, 
        x - 15, vertical_center
    )
end

function menu.draw_profile(member, x, y, profile)
    local width = profile.width
    local height = profile.height
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
    if phase == 'main' or phase == 'choose_member' then
        if key == input.back then
            menu.back()
        elseif key == input.up then
            menu.move_up()
        elseif key == input.down then
            menu.move_down()
        elseif key == input.confirm then
            menu.select()
        end
    elseif phase == 'order' then
        order.keypressed(key)
    elseif phase == 'stats' then
        stats.keypressed(key)
    elseif phase == 'equip' then
        equip.keypressed(key)
    end
end

function menu.move_up()
    if phase == 'main' and position > 1 then
        position = position - 1
    elseif phase == 'choose_member' and member_index > 1 then
        member_index = member_index - 1
    end
end

function menu.move_down()
    if phase == 'main' and position < #list then
        position = position + 1
    elseif phase == 'choose_member' and member_index < #menu.party.members then
        member_index = member_index + 1
    end
end

function menu.select()
    if phase == 'main' then
        if position == 3 then
            member_index = 1
            phase = 'choose_member'
        elseif position == 4 then
            stats.load(menu, menu.party)
            phase = 'stats'
        elseif position == 5 then
            member_index = 1
            phase = 'choose_member'
        end
    elseif phase == 'choose_member' then
        if position == 3 then
            phase = 'equip'
            equip.load(menu, menu.party, menu.party.members[member_index])
        elseif position == 5 then
            order.load(menu, menu.party, member_index)
            phase = 'order'
        end
    end
end

function menu.back()
    if phase == 'main' then
        menu.game.switch_state('field')
    elseif phase == 'choose_member' then
        phase = 'main'
    end
end

function menu.switch_phase(new_phase)
    phase = new_phase
end

function menu.set_member_index(index)
    member_index = index
end

return menu