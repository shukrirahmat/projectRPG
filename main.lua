require('globals')
local battle = require('battle')
local overworld = require('overworld')
local partyMemberCreator = require('partyMemberCreator')
local currentState = nil;

function love.load()
    math.randomseed(os.time())
    love.window.setMode(windowWidth, windowHeight)
    
    local party = {}
    party[1] = partyMemberCreator.new('ONE')
    party[2] = partyMemberCreator.new('TWO')
    party[3] = partyMemberCreator.new('THREE')
    party[4] = partyMemberCreator.new('FOUR')
    
    overworld.load(party)
    currentState = overworld
end

function love.update(dt)
    currentState.update(dt)
end

function love.draw()
    currentState.draw()
end

function love.keypressed(key)
    currentState.keypressed(key)
end
