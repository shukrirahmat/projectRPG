local transitions = require('systems.transitions')
local input = require('input')

local menu = {}

local lg = love.graphics

function menu.load(game)
    menu.game = game
    menu.MARGIN_X = 20
    menu.MARGIN_Y = 20
    menu.HEIGHT = lg.getHeight() - menu.MARGIN_Y * 2
    menu.WIDTH = lg.getWidth() - menu.MARGIN_X * 2
end

function menu.update(dt)
end

function menu.draw()

    lg.setColor(1, 1, 1)
    lg.rectangle('line', menu.MARGIN_X, menu.MARGIN_Y, menu.WIDTH, menu.HEIGHT)

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