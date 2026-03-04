windowWidth = 1024
windowHeight = 576

love.graphics.setBackgroundColor(0,0,0)

font_tiny = love.graphics.newFont('fonts/AtkinsonHyperlegibleMono-Medium.ttf', 12)
font_small = love.graphics.newFont('fonts/AtkinsonHyperlegibleMono-Medium.ttf', 14)
font_medium = love.graphics.newFont('fonts/AtkinsonHyperlegibleMono-Medium.ttf', 16)
font_text = love.graphics.newFont('fonts/AtkinsonHyperlegibleMono-Medium.ttf', 16)
font_large = love.graphics.newFont('fonts/AtkinsonHyperlegibleMono-Medium.ttf', 18)
font_bold = love.graphics.newFont('fonts/AtkinsonHyperlegibleMono-Bold.ttf', 18)
font_small:setFilter("nearest", "nearest")
font_medium:setFilter("nearest", "nearest")
font_large:setFilter("nearest", "nearest")
monsterSpriteDimension = 128
skillSpriteDimension = 64

--SPRITES
player_sprites = love.graphics.newImage('images/player_sprites.png')
player_front = {
    love.graphics.newQuad(0, 0, 64, 64, 192, 256),
    love.graphics.newQuad(64, 0, 64, 64, 192, 256),
    love.graphics.newQuad(128, 0, 64, 64, 192, 256)
}
player_back = {
    love.graphics.newQuad(0, 64, 64, 64, 192, 256),
    love.graphics.newQuad(64, 64, 64, 64, 192, 256),
    love.graphics.newQuad(128, 64, 64, 64, 192, 256)
}
player_right = {
    love.graphics.newQuad(0, 128, 64, 64, 192, 256),
    love.graphics.newQuad(64, 128, 64, 64, 192, 256),
    love.graphics.newQuad(128, 128, 64, 64, 192, 256)
}
player_left = {
    love.graphics.newQuad(0, 192, 64, 64, 192, 256),
    love.graphics.newQuad(64, 192, 64, 64, 192, 256),
    love.graphics.newQuad(128, 192, 64, 64, 192, 256)
}

gate_sprite = love.graphics.newImage('images/gate.png')


slime_sprite = love.graphics.newImage('images/slime.png')
goblin_sprite = love.graphics.newImage('images/goblin.png')
armored_goblin_sprite = love.graphics.newImage('images/armored_goblin.png')
skeleton_sprite = love.graphics.newImage('images/skeleton.png')
dragon_sprite = love.graphics.newImage('images/dragon.png')


