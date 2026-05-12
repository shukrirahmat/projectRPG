local field = require('states.field')
local battle = require('states.battle')
local reward = require('states.reward')
local defeat = require('states.defeat')
local menu = require('states.menu')

local party_data = require('data.party_data')
local party = require('systems.party')
local player = require('systems.player')
local mapper = require('systems.mapper')
local Member = require('entities.member')
local graphics = require('graphics')
local fonts = require('fonts')
local input = require('input')

local game = {}

local states = { 
    field = field , 
    battle = battle, 
    reward = reward,
    defeat = defeat,
    menu = menu
}

local current_state = nil

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
    
    party.manage_item('potion', 10)
    party.manage_item('antidote', 5)
    party.manage_item('bandage', 3)
    party.manage_gold(200)
    
    game.party = party

    local current_map = require('maps.overworld')
    local start_position = current_map.start_position 
    
    game.checkpoint = { map = current_map, position = start_position, facing = 'front' }
    
    mapper.load(current_map, start_position)
    player.load(start_position, 'front')
    game.switch_state('field', {reset_encounter = true})
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