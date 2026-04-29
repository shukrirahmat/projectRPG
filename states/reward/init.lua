local textbox = require('systems.textbox')
local party_manager = require('systems.party_manager')
local exp_screen = require('states.reward.exp_screen')
local input = require('input')

local reward = {
    game = nil,
    phase = nil,
    party = nil,
}

function reward.load(game, var)
    reward.game = game
    reward.party = party_manager.get_members()
    
    textbox.load({'Gained '..var.exp..' EXP.'})
    exp_screen.load(reward, var.exp, textbox)
    reward.phase = 'distributing_exp'
end

function reward.update(dt)
    if reward.phase == 'distributing_exp' then
        textbox.update(dt)
        exp_screen.update(dt)
    end
end

function reward.draw()
    exp_screen.draw()
    
    if textbox.is_active() then
        textbox.draw()
    end
end

function reward.keypressed(key)
    if textbox.is_active() and key == input.confirm then
        if textbox.is_finished() then
            textbox.advance()
        else
            textbox.skip()
        end
    elseif exp_screen.is_active then
        exp_screen.skip()
    end
end

return reward