local player = require('systems.player')
local mapper = require('systems.mapper')
local encounter = require('states.field.encounter')
local transitions = require('systems.transitions')
local input = require('input')

local field = {}
local game = nil
local phase = nil

function field.load(_game, var)

    game = _game

    if var and var.checkpoint then 
        local current_map = game.checkpoint.map
        local start_position = game.checkpoint.position
        local facing = game.checkpoint.facing
        mapper.load(current_map, start_position)
        player.load(start_position, facing)
    end

    if var and var.reset_encounter then
        encounter.load(mapper.get_current_map())
    end

    transitions.load('fade_in', 0.25, function() phase = 'player_control' end)
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
    elseif phase == 'menu_transition' then
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
    if phase == 'player_control' then
        if key == input.menu then
            field.opening_menu = true
        elseif key == input.up or key == input.down or key == input.right or key == input.left then
            player.move(key)
        end
    end
end

function field.change_area(next_map, start_position)

    local function change_area()
        local current_map = require('maps.'..next_map..'')

        mapper.load(current_map, start_position)
        player.load(start_position, 'front')
        game.switch_state('field', {reset_encounter = true})
    end

    phase = 'changing_area'
    transitions.load('fade_out', 0.5, change_area)

    field.opening_menu = false
end

function field.enter_battle(enemies)

    local function enter_battle()
        game.switch_state('battle', {enemies = enemies})
    end

    phase = 'entering_battle'
    transitions.load('battle', 1, enter_battle)

    field.opening_menu = false
end

function field.open_menu()
    local function open_menu()
        game.switch_state('menu')
    end

    phase = 'menu_transition'
    transitions.load('fade_out', 0.2, open_menu)

    field.opening_menu = false
end

return field