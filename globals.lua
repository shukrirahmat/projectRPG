windowWidth = 800
windowHeight = 600

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

goblin_sprite = love.graphics.newImage('images/goblin.png')
skeleton_sprite = love.graphics.newImage('images/skeleton.png')
dragon_sprite = love.graphics.newImage('images/dragon.png')