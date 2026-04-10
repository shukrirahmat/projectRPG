local enemy_sprites = {}

local sprites = {}

function enemy_sprites.load()
    sprites['goblin'] = love.graphics.newImage('assets/images/goblin.png')
    sprites['skeleton'] = love.graphics.newImage('assets/images/skeleton.png')
    sprites['dragon'] = love.graphics.newImage('assets/images/dragon.png')
end

function enemy_sprites.get_sprite(reference)
    return sprites[reference]
end

return enemy_sprites