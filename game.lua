local field = require('states.field')
local battle = require('states.battle')
local party_data = require('data.party_data')
local party_manager = require('systems.party_manager')
local Member = require('entities.member')
local graphics = require('graphics')
local fonts = require('fonts')
local input = require('input')

local game = {}

local states = { field = field , battle = battle}
local current_state = nil

game.current_map = nil
game.player_position = nil
game.player_facing = nil

function game.load()
    
    graphics.load()
    fonts.load()
    
    party_manager.load(
        { 
            Member.new(party_data.test[1]),
            Member.new(party_data.test[2]),
            Member.new(party_data.test[3]),
            Member.new(party_data.test[4]),
        }
    )
    
    party_manager.manage_item('potion', 10)
    party_manager.manage_item('antidote', 5)
    party_manager.manage_item('bandage', 3)
    party_manager.manage_gold(200)

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