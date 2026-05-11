local player_sprites = require('graphics.player_sprites')
local input = require('input')

local player = {}

local position = nil
local current_sprite = nil
local is_moving = false
local move_timer = 0
local move_speed = 0
local move_direction = nil
local directions = nil


function player.load(start_position, player_facing)
    
    position = {x = start_position.x, y = start_position.y}
    current_sprite = player_sprites.get_quad(player_facing)[1]
    move_speed = 0.3
    
    directions = {
    up = {
        dx = 0, dy = -1,
        axis = "y",
        sprite = player_sprites.get_quad('back'),
        can_move = function(mapper) return position.y > 1 end
    },
    down = {
        dx = 0, dy = 1,
        axis = "y",
        sprite = player_sprites.get_quad('front'),
        can_move = function(mapper) return position.y < mapper.get_current_map().height end
    },
    left = {
        dx = -1, dy = 0,
        axis = "x",
        sprite = player_sprites.get_quad('left'),
        can_move = function(mapper) return position.x > 1 end
    },
    right = {
        dx = 1, dy = 0,
        axis = "x",
        sprite = player_sprites.get_quad('right'),
        can_move = function(mapper) return position.x < mapper.get_current_map().width end
    }
}
    
end

function player.update(dt, field, mapper, encounter)
    if is_moving then
        move_timer = move_timer + dt
        local direction = directions[move_direction]
        current_sprite = direction.sprite[1]

        if not direction.can_move(mapper) then
            is_moving = false
            move_timer = 0
            return
        end

        local progress = move_timer / move_speed
        if move_timer < move_speed then
            local step = mapper.move(direction, progress)
            if step < 0.5 then
                current_sprite = direction.sprite[1]
            elseif step < 1 then
                if position[direction.axis] % 2 == 0 then
                    current_sprite = direction.sprite[3]
                else
                    current_sprite = direction.sprite[2]
                end
            end
        else
            player.stop(direction, mapper)
            player.check_area(field, mapper, encounter)
            player.queued_action(field)
        end
    else
        player.check_hold_movement()
        player.queued_action(field)
    end
end

function player.stop(direction, mapper)
    is_moving = false
    move_timer = 0
    current_sprite = direction.sprite[1]
    position.x = position.x + direction.dx
    position.y = position.y + direction.dy
    mapper.stop(direction)
end

function player.check_area(field, mapper, encounter)
    local current_map = mapper.get_current_map()
    local event = current_map.events[''..position.x..','..position.y..'']
    local has_encounter = current_map.has_encounter
    
    if event then
        if event.type == 'gate' then
            field.change_area(event.to, event.start)
        end
    elseif has_encounter then
        encounter.attempt(field)
    end
end

function player.queued_action(field)
    if field.opening_menu then field.open_menu() end
end

function player.check_hold_movement()
    if is_moving then return end

    if love.keyboard.isDown(input.up) then
        player.move('up')
    elseif love.keyboard.isDown(input.down) then
        player.move('down')
    elseif love.keyboard.isDown(input.left) then
        player.move('left')
    elseif love.keyboard.isDown(input.right) then
        player.move('right')
    end
end

function player.draw(camera, tile_size)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        player_sprites.get_sprite(),
        current_sprite,
        (position.x - 1) * tile_size + camera.x,
        (position.y - 1) * tile_size + camera.y
    )
end

function player.move(key)
    if is_moving then return end
    
    is_moving = true
    move_timer = 0
    move_direction = key
end

function player.is_moving()
    return is_moving
end

return player