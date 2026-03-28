local field = require('states.field')
local graphics = require('graphics')

local game = {}

local states = { field = field }
local current_state = nil

game.move_speed = 0.5

function game.load()
    
    graphics.load()
    
    game.switch_state('field', {map = 'overworld'})
    
end

function game.switch_state(state, var)
    current_state = states[state];
    current_state.load(game, var)
end

function game.update(dt)
    current_state.update(dt)
end

function game.draw()
    current_state.draw()
end

function game.keypressed(key)
    current_state.keypressed(key)
end


return game