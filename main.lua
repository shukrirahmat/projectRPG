require('globals')
local stateManager = require('stateManager')
local gameState = require('gameState')

function love.load()
    math.randomseed(os.time())
    love.window.setMode(windowWidth, windowHeight)
    
    stateManager.initiate()
    stateManager.switch('field')    
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
