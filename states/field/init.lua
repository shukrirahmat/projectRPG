local player = require('states.field.player')
local map = require('states.field.map')

local field = {}

function field.load(game, var)
    player.load(game, var.position, map)
    map.load(var.map, player)
end

function field.update(dt)
    player.update(dt)
end

function field.draw()
    map.draw()
    player.draw()
end

function field.keypressed(key)
    if not player.is_moving() then
        player.move(key)
    end
end

return field