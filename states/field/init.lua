local player = require('states.field.player')
local mapper = require('states.field.mapper')
local transitions = require('systems.transitions')

local field = {}
local game = nil
local phase = nil

function field.load(_game, var)

    local current_map = require('maps.'..var.map..'')
    local start_position = var.position or current_map.start_position

    game = _game
    player.load(field, current_map, start_position)
    mapper.load(field, current_map, start_position)
    
    transitions.load('fade_in', 0.5, function() phase = 'player_control' end)
    phase = 'fade_in'
end

function field.update(dt)
    if phase == 'fade_in' then
        transitions.update(dt)
    elseif phase == 'player_control' then
        player.update(dt, mapper)
    elseif phase == 'changing_area' then
        transitions.update(dt)
    end
end

function field.draw()
    mapper.draw()
    player.draw(mapper.get_camera(), mapper.get_tile_size())

    if transitions.is_active() then
        transitions.draw()
    end
end

function field.keypressed(key)
    if phase == 'player_control' and not player.is_moving() then
        player.move(key)
    end
end

function field.change_area(next_map)

    local function change_area()
        game.switch_state('field', { map = next_map })
    end

    phase = 'changing_area'
    transitions.load('fade_out', 0.5, change_area)
end

return field