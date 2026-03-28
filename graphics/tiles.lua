local tiles = {}

local sprites = {}

function tiles.load()
    sprites[1] = love.graphics.newImage('assets/images/tile_1.png')
end

function tiles.get_tile(id)
    return sprites[id]
end

return tiles