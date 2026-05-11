local transitions = require('systems.transitions')
local input = require('input')
local fonts = require('fonts')

local menu = {}

local lg = love.graphics

function menu.load(game)
    menu.game = game
    menu.MARGIN_X = 20
    menu.MARGIN_Y = 20
    menu.HEIGHT = lg.getHeight() - menu.MARGIN_Y * 2
    menu.WIDTH = lg.getWidth() - menu.MARGIN_X * 2
    menu.LEFT_X = menu.WIDTH * 0.8
    menu.LEFT_WIDTH = menu.WIDTH * 0.2
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
    lg.rectangle('line', menu.MARGIN_X, menu.MARGIN_Y, menu.WIDTH, menu.HEIGHT)
    lg.line(menu.LEFT_X, menu.MARGIN_Y, menu.LEFT_X, menu.MARGIN_Y + menu.HEIGHT)
    lg.line(menu.LEFT_X, menu.BOTTOM_Y, menu.MARGIN_X + menu.WIDTH , menu.BOTTOM_Y)
    
    lg.setFont(fonts.large)
    lg.printf(
        'Gold : '..menu.party.gold..'',
        menu.LEFT_X + menu.BOTTOM_PADDING_X,
        menu.BOTTOM_Y + menu.BOTTOM_PADDING_Y,
        menu.LEFT_WIDTH,
        'left'
    )

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