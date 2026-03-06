local sprites = {}

--PLAYER--

sprites['player'] = love.graphics.newImage('graphics/images/player_sprites.png')

sprites['player_front'] = {
    love.graphics.newQuad(0, 0, 64, 64, 192, 256),
    love.graphics.newQuad(64, 0, 64, 64, 192, 256),
    love.graphics.newQuad(128, 0, 64, 64, 192, 256)
}
sprites['player_back'] = {
    love.graphics.newQuad(0, 64, 64, 64, 192, 256),
    love.graphics.newQuad(64, 64, 64, 64, 192, 256),
    love.graphics.newQuad(128, 64, 64, 64, 192, 256)
}
sprites['player_right'] = {
    love.graphics.newQuad(0, 128, 64, 64, 192, 256),
    love.graphics.newQuad(64, 128, 64, 64, 192, 256),
    love.graphics.newQuad(128, 128, 64, 64, 192, 256)
}
sprites['player_left'] = {
    love.graphics.newQuad(0, 192, 64, 64, 192, 256),
    love.graphics.newQuad(64, 192, 64, 64, 192, 256),
    love.graphics.newQuad(128, 192, 64, 64, 192, 256)
}


--MAP SPRITES--

sprites['gate'] = love.graphics.newImage('graphics/images/gate.png')

--ENEMY SPRITES--

sprites['slime'] = love.graphics.newImage('graphics/images/slime.png')
sprites['goblin'] = love.graphics.newImage('graphics/images/goblin.png')
sprites['skeleton'] = love.graphics.newImage('graphics/images/skeleton.png')
sprites['dragon'] = love.graphics.newImage('graphics/images/dragon.png')

return sprites