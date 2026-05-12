local transitions = require('systems.transitions')
local input = require('input')
local fonts = require('fonts')
local party_sprites = require('graphics.party_sprites')

local menu = {}

local lg = love.graphics

function menu.load(game)
    menu.game = game
    menu.MARGIN_X = 20
    menu.MARGIN_Y = 20
    menu.HEIGHT = lg.getHeight() - menu.MARGIN_Y * 2
    menu.WIDTH = lg.getWidth() - menu.MARGIN_X * 2
    menu.RIGHT_X = menu.WIDTH * 0.8 + menu.MARGIN_X
    menu.RIGHT_WIDTH = menu.WIDTH * 0.2
    menu.LIST_HEIGHT = menu.HEIGHT * 0.75
    menu.BOTTOM_Y = menu.LIST_HEIGHT + menu.MARGIN_Y
    menu.BOTTOM_PADDING_X = 20
    menu.BOTTOM_PADDING_Y = 20
    
    menu.party = game.party
end

function menu.update(dt)
end

function menu.draw()

    lg.setColor(1, 1, 1)
    lg.rectangle('line', menu.RIGHT_X, menu.MARGIN_Y, menu.RIGHT_WIDTH, menu.HEIGHT)
    lg.line(menu.RIGHT_X, menu.BOTTOM_Y, menu.MARGIN_X + menu.WIDTH , menu.BOTTOM_Y)
    
    lg.setFont(fonts.large)
    lg.printf(
        'Gold : '..menu.party.gold..'',
        menu.RIGHT_X + menu.BOTTOM_PADDING_X,
        menu.BOTTOM_Y + menu.BOTTOM_PADDING_Y,
        menu.RIGHT_WIDTH,
        'left'
    )
    
    for i, member in ipairs(menu.party.members) do
        
        local gap = 10
        local left_pad = 40
        local box_width = menu.WIDTH - menu.RIGHT_WIDTH - gap - left_pad
        local box_height = (menu.HEIGHT - gap * 3) / 4
        local box_x = menu.MARGIN_X + left_pad
        local box_y = menu.MARGIN_Y + (i - 1) * (box_height + gap)
        
        local sprite_x = box_x
        local sprite_y = box_y
        local sprite_width = 128
        local sprite = member.sprite
        if member.is_dead then sprite = party_sprites.get_sprite('coffin') end
        
        if member.is_dead then
            lg.setColor(0.5, 0.5, 0.5)
        else
            lg.setColor(1, 1, 1)
        end
        lg.draw(sprite, sprite_x, sprite_y)
        lg.line(sprite_x + sprite_width, box_y, sprite_x + sprite_width, box_y + box_height)
        lg.rectangle('line', box_x, box_y, box_width, box_height)
        
        local status_padding_x = 20
        local status_padding_y = 10
        local status_left_x = sprite_width + box_x + status_padding_x
        local status_left_y = box_y + status_padding_y
        local status_left_width = (box_width - sprite_width) * 0.4 - status_padding_x * 2
        local status_left_lh = (box_height - status_padding_y * 2) / 4
        
        lg.setFont(fonts.large)
        lg.printf(member.name, status_left_x, status_left_y, status_left_width, 'left')
        lg.printf('LVL '..member.lvl..'', status_left_x, status_left_y, status_left_width, 'right')
        
        lg.setFont(fonts.large_mono)
        
        local hp_text = ''..member.current_hp..' / '..member.max_hp..''
        lg.printf('HP', status_left_x, status_left_y + status_left_lh, status_left_width, 'left')
        lg.printf(hp_text, status_left_x, status_left_y + status_left_lh, status_left_width, 'right')
        local mp_text = ''..member.current_mp..' / '..member.max_mp..''
        lg.printf('MP', status_left_x, status_left_y + status_left_lh * 2, status_left_width, 'left')
        lg.printf(mp_text, status_left_x, status_left_y + status_left_lh * 2, status_left_width, 'right')
        
        lg.setFont(fonts.large_mono)
        local status_text = ''
        if member.is_dead then
            status_text = 'KO'
        elseif next(member.status) == nil then 
            status_text = 'Normal' 
        end 
        lg.printf('STATUS:', status_left_x, status_left_y + status_left_lh * 3, status_left_width, 'left')
        lg.printf(status_text, status_left_x, status_left_y + status_left_lh * 3, status_left_width, 'right')
    end

end

function menu.keypressed(key)
    if key == input.back then
        menu.close()
    end
end

function menu.close()
    menu.game.switch_state('field')
end

return menu