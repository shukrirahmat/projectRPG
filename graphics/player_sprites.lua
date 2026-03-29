local player_sprites = {}

local sprites = nil
local front_quad = nil
local back_quad = nil
local right_quad = nil
local left_quad = nil

function player_sprites.load()
    sprites = love.graphics.newImage('assets/images/player.png')
    front_quad = {
        love.graphics.newQuad(0, 0, 64, 64, 192, 256),
        love.graphics.newQuad(64, 0, 64, 64, 192, 256),
        love.graphics.newQuad(128, 0, 64, 64, 192, 256)
    }
    back_quad = {
        love.graphics.newQuad(0, 64, 64, 64, 192, 256),
        love.graphics.newQuad(64, 64, 64, 64, 192, 256),
        love.graphics.newQuad(128, 64, 64, 64, 192, 256)
    }
    right_quad = {
        love.graphics.newQuad(0, 128, 64, 64, 192, 256),
        love.graphics.newQuad(64, 128, 64, 64, 192, 256),
        love.graphics.newQuad(128, 128, 64, 64, 192, 256)
    }
    left_quad = {
        love.graphics.newQuad(0, 192, 64, 64, 192, 256),
        love.graphics.newQuad(64, 192, 64, 64, 192, 256),
        love.graphics.newQuad(128, 192, 64, 64, 192, 256)
    }
end

function player_sprites.get_sprite()
    return sprites
end

function player_sprites.get_quad(facing)
    if facing == 'front' then return front_quad
    elseif facing == 'back' then return back_quad
    elseif facing == 'right' then return right_quad
    elseif facing == 'left' then return left_quad
    end
end

return player_sprites