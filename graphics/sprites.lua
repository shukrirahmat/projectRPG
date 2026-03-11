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

--STATUS SPRITES--
sprites['status_Icons'] = love.graphics.newImage('graphics/images/status_Icons.png')
sprites['BLIND'] = love.graphics.newQuad(0, 0, 16, 16, 128, 32)
sprites['SEAL'] = love.graphics.newQuad(16, 0, 16, 16, 128, 32)
sprites['POISON'] = love.graphics.newQuad(32, 0, 16, 16, 128, 32)
sprites['WOUND'] = love.graphics.newQuad(48, 0, 16, 16, 128, 32)
sprites['CURSE'] = love.graphics.newQuad(64, 0, 16, 16, 128, 32)
sprites['STUN'] = love.graphics.newQuad(80, 0, 16, 16, 128, 32)
sprites['SLEEP'] = love.graphics.newQuad(96, 0, 16, 16, 128, 32)
sprites['CONFUSE'] = love.graphics.newQuad(112, 0, 16, 16, 128, 32)
sprites['PARALYSIS'] = love.graphics.newQuad(0, 16, 16, 16, 128, 32)
sprites['STEEL'] = love.graphics.newQuad(16, 16, 16, 16, 128, 32)
sprites['FRAIL'] = love.graphics.newQuad(32, 16, 16, 16, 128, 32)
sprites['FLEET'] = love.graphics.newQuad(48, 16, 16, 16, 128, 32)
sprites['SNARE'] = love.graphics.newQuad(64, 16, 16, 16, 128, 32)
sprites['MIGHT'] = love.graphics.newQuad(80, 16, 16, 16, 128, 32)
sprites['BARRIER'] = love.graphics.newQuad(96, 16, 16, 16, 128, 32)

return sprites