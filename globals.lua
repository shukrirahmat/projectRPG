windowWidth = 800
windowHeight = 600
love.graphics.setBackgroundColor(0,0,0)
font_small = love.graphics.newFont('fonts/AtkinsonHyperlegibleMono-Medium.ttf', 14)
font_medium = love.graphics.newFont('fonts/AtkinsonHyperlegibleMono-Medium.ttf', 16)
font_large = love.graphics.newFont('fonts/AtkinsonHyperlegibleMono-Medium.ttf', 18)
font_small:setFilter("nearest", "nearest")
font_medium:setFilter("nearest", "nearest")
font_large:setFilter("nearest", "nearest")
monsterSpriteDimension = 128
skillSpriteDimension = 64

createCharacter = require('createCharacter')
createBattle = require('createBattle')
createHud = require('createHud')
createEnemySprites = require('createEnemySprites')
createMenu = require('createMenu')
createController = require('createController')