local game = require('game')

function love.load()
    math.randomseed(os.time())
    love.window.setMode(1024, 576)
    
    game.load()
end

function love.update(dt)
    game.update(dt)
end

function love.draw()
    game.draw()
end

function love.keypressed(key)
    game.keypressed(key)
end