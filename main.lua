require('globals')
local battle = require('battle')
local overworld = require('overworld')
local transition = require('transition')
local partyMemberCreator = require('partyMemberCreator')
local gameState = require('gameState')

function love.load()
    math.randomseed(os.time())
    love.window.setMode(windowWidth, windowHeight)
    
    local party = {}
    party[1] = partyMemberCreator.new('ONE')
    party[2] = partyMemberCreator.new('TWO')
    party[3] = partyMemberCreator.new('THREE')
    party[4] = partyMemberCreator.new('FOUR')
    
    overworld.load(party)
    gameState.currentState = overworld
end

function love.update(dt)
    gameState.currentState.update(dt)
end

function love.draw()
    gameState.currentState.draw()
end

function love.keypressed(key)
    gameState.currentState.keypressed(key)
end
