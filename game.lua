local field = require('states.field')
local battle = require('states.battle')
local party_data = require('data.party_data')
local party = require('systems.party')
local Member = require('entities.member')
local graphics = require('graphics')
local fonts = require('fonts')
local input = require('input')

local game = {}

local states = { field = field , battle = battle}
local current_state = nil

game.party = nil
game.current_map = nil
game.player_position = nil
game.player_facing = nil

function game.load()
    
    graphics.load()
    fonts.load()
    party.load(
        { 
            Member.new(party_data.test[1]),
            Member.new(party_data.test[2]),
            Member.new(party_data.test[3]),
            Member.new(party_data.test[4]),
        }
    )
    
    game.party = party
    game.current_map = require('maps.overworld')
    game.player_position = game.current_map.start_position
    game.player_facing = 'front'
    
    game.switch_state('field')
end

function game.switch_state(state, var)
    current_state = states[state]
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