local tiles = {}

local sprites = {}

function tiles.load()
    sprites[1] = love.graphics.newImage('assets/images/tile_1.png')
    sprites[2] = love.graphics.newImage('assets/images/tile_2.png')
end

function tiles.get_sprite(id)
    return sprites[id]
end

return tiles