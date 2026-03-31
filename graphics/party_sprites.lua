local party_sprites = {}

local sprites = {}

function party_sprites.load()
    sprites['one'] = love.graphics.newImage('assets/images/one.png')
    sprites['two'] = love.graphics.newImage('assets/images/two.png')
    sprites['three'] = love.graphics.newImage('assets/images/three.png')
    sprites['four'] = love.graphics.newImage('assets/images/four.png')
end

function party_sprites.get_sprite(reference)
    return sprites[reference]
end

return party_sprites