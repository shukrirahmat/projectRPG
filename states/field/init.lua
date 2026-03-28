local player = require('states.field.player')
local map = require('states.field.map')

local field = {}

function field.load(game, var)
    local current_map = require('maps.'..var.map..'')
    local start_position = var.position or current_map.start_position
    
    player.load(game, start_position, map)
    map.load(current_map, player)
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