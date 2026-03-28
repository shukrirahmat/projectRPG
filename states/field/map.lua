local tiles = require('graphics.tiles')
local gates = require('graphics.gates')

local map = {}

local tile_size = 64
local camera = {}
local shift = { x = 0, y = 0}
local current_map
local player

function map.load(_current_map, _player)
    current_map = _current_map
    player = _player
    camera.x = love.graphics.getWidth()/2 - (player.get_position().x - 0.5) * tile_size
    camera.y = love.graphics.getHeight()/2 - (player.get_position().y - 0.5) * tile_size
end

function map.draw()
    for y = 1, current_map.height do
        for x = 1, current_map.width do
            local id = current_map.tiles[y][x]
            local tile = tiles.get_tile(id)
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(
                tile,
                (x - 1) * tile_size + camera.x - shift.x,
                (y - 1) * tile_size + camera.y - shift.y
            )

            if current_map.events[''..x..','..y..''] then
                local event = current_map.events[''..x..','..y..'']
                local sprite;
                if event.type == 'gate' then
                    sprite = gates.get_gate(event.spriteID)
                end
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(
                    sprite,
                    (x - 1) * tile_size + camera.x - shift.x,
                    (y - 1) * tile_size + camera.y - shift.y
                )
            end
        end
    end
end

function map.move(direction, progress)
    local shift_amount = progress * tile_size

    if direction.axis == 'x' then
        shift.x = math.floor(direction.dx * shift_amount)
    elseif direction.axis == 'y' then
        shift.y = math.floor(direction.dy * shift_amount)
    end

    local step = math.abs(shift[direction.axis]) / tile_size

    return step
end

function map.stop(direction)
    shift[direction.axis] = 0
    camera.x = camera.x - direction.dx * tile_size
    camera.y = camera.y - direction.dy * tile_size
end

function map.get_tile_size()
    return tile_size
end

function map.get_camera()
    return camera
end

function map.get_height()
    return current_map.height
end

function map.get_width()
    return current_map.width
end

return map