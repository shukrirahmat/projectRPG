require('globals')
local stateManager = require('stateManager')
local gameState = require('gameState')
local field = require('states.field')

function love.load()
    math.randomseed(os.time())
    love.window.setMode(windowWidth, windowHeight)
    
    stateManager.initiate()
    field.load()
    stateManager.switch(field)    
end

function love.update(dt)
    stateManager.update(dt)
end

function love.draw()
    stateManager.draw()
end

function love.keypressed(key)
    stateManager.keypressed(key)
end
