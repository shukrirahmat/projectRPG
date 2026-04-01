local player = require('states.field.player')
local mapper = require('states.field.mapper')
local encounter = require('states.field.encounter')
local transitions = require('systems.transitions')
local input = require('input')

local field = {}
local game = nil
local phase = nil

function field.load(_game)

    game = _game
    player.load(game.current_map, game.player_position, game.player_facing)
    mapper.load(game.current_map, game.player_position)
    encounter.load(game.current_map)

    transitions.load('fade_in', 0.5, function() phase = 'player_control' end)
    phase = 'fade_in'
end

function field.update(dt)
    if phase == 'fade_in' then
        transitions.update(dt)
    elseif phase == 'player_control' then
        player.update(dt, field, mapper, encounter)
    elseif phase == 'changing_area' then
        transitions.update(dt)
    elseif phase == 'entering_battle' then
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
        if key == input.up or key == input.down or key == input.right or key == input.left then
            player.move(key)
        end
    end
end

function field.change_area(next_map)

    local function change_area()

        game.current_map = require('maps.'..next_map..'')
        game.player_position = game.current_map.start_position
        game.player_facing = 'front'

        game.switch_state('field')
    end

    phase = 'changing_area'
    transitions.load('fade_out', 0.5, change_area)
end

function field.enter_battle(enemies)

    local function enter_battle()
        game.switch_state('battle', {enemies = enemies})
    end

    phase = 'entering_battle'
    transitions.load('battle', 1, enter_battle)
end

return field