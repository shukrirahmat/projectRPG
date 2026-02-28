require('globals')
local battle = require('battle')
local overworld = require('overworld')
local currentState = nil;

function love.load()
    math.randomseed(os.time())
    love.window.setMode(windowWidth, windowHeight)
    
    overworld.load()
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
