local tiles = {}

local images = {}

function tiles.load()
    images[1] = love.graphics.newImage('assets/images/tile_1.png')
end

function tiles.get_tile(id)
    return images[id]
end

return tiles