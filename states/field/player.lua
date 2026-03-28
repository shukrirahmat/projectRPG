local player = {}

local game
local map
local sprites
local front_sprites
local back_sprites
local right_sprites
local left_sprites
local current_sprite
local position

local is_moving = false
local move_timer = 0
local move_speed = 0
local move_direction = nil

local directions = {
    up = {
        dx = 0, dy = -1,
        axis = "y",
        can_move = function() return position.y > 1 end
    },
    down = {
        dx = 0, dy = 1,
        axis = "y",
        can_move = function() return position.y < map.get_height() end
    },
    left = {
        dx = -1, dy = 0,
        axis = "x",
        can_move = function() return position.x > 1 end
    },
    right = {
        dx = 1, dy = 0,
        axis = "x",
        can_move = function() return position.x < map.get_width() end
    }
}


function player.load(_game, _position, _map)

    sprites = love.graphics.newImage('assets/images/player.png')
    front_sprites = {
        love.graphics.newQuad(0, 0, 64, 64, 192, 256),
        love.graphics.newQuad(64, 0, 64, 64, 192, 256),
        love.graphics.newQuad(128, 0, 64, 64, 192, 256)
    }
    back_sprites = {
        love.graphics.newQuad(0, 64, 64, 64, 192, 256),
        love.graphics.newQuad(64, 64, 64, 64, 192, 256),
        love.graphics.newQuad(128, 64, 64, 64, 192, 256)
    }
    right_sprites = {
        love.graphics.newQuad(0, 128, 64, 64, 192, 256),
        love.graphics.newQuad(64, 128, 64, 64, 192, 256),
        love.graphics.newQuad(128, 128, 64, 64, 192, 256)
    }
    left_sprites = {
        love.graphics.newQuad(0, 192, 64, 64, 192, 256),
        love.graphics.newQuad(64, 192, 64, 64, 192, 256),
        love.graphics.newQuad(128, 192, 64, 64, 192, 256)
    }

    current_sprite = front_sprites[1]
    directions.up.sprite = back_sprites
    directions.down.sprite = front_sprites
    directions.right.sprite = right_sprites
    directions.left.sprite = left_sprites


    position = _position
    map = _map
    move_speed = _game.move_speed
end

function player.update(dt)
    if is_moving then
        move_timer = move_timer + dt
        local direction = directions[move_direction]
        current_sprite = direction.sprite[1]

        if not direction.can_move() then
            is_moving = false
            move_timer = 0
            return
        end

        local progress = move_timer / move_speed
        if move_timer < move_speed then
            local step = map.move(direction, progress)
            if step <= 0.25 then
                current_sprite = direction.sprite[2]
            elseif step <= 0.5 then
                current_sprite = direction.sprite[1]
            elseif step <= 0.75 then
                current_sprite = direction.sprite[3]
            end
        else
            player.stop(direction)
        end
    else
        player.check_hold_movement()
    end
end

function player.stop(direction)
    is_moving = false
    move_timer = 0
    current_sprite = direction.sprite[1]
    position.x = position.x + direction.dx
    position.y = position.y + direction.dy
    map.stop(direction)
end

function player.check_hold_movement()
    if is_moving then return end

    if love.keyboard.isDown('up') then
        player.move('up')
    elseif love.keyboard.isDown('down') then
        player.move('down')
    elseif love.keyboard.isDown('left') then
        player.move('left')
    elseif love.keyboard.isDown('right') then
        player.move('right')
    end
end

function player.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        sprites,
        current_sprite,
        (position.x - 1) * map.get_tile_size() + map.get_camera().x,
        (position.y - 1) * map.get_tile_size() + map.get_camera().y
    )
end

function player.get_position()
    return position
end

function player.move(key)
    is_moving = true
    move_timer = 0
    move_direction = key
end

function player.is_moving()
    return is_moving
end

return player