local textbox = require('systems.textbox')
local transitions = require('systems.transitions')
local party_manager = require('systems.party_manager')
local exp_screen = require('states.reward.exp_screen')
local spoils = require('states.reward.spoils')
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
    spoils.load(var.gold, var.items, party_manager, textbox)
    
    reward.phase = 'exp'
end

function reward.update(dt)
    if reward.phase == 'exp' then
        exp_screen.update(dt)
        textbox.update(dt)
        if not exp_screen.is_active and not textbox.is_busy() then
            reward.phase = 'spoils'
        end
    end
    
    if reward.phase == 'spoils' then
        spoils.update(dt)
        textbox.update(dt)
        if not spoils.is_active and not textbox.is_busy() then
            transitions.load('fade_out', 0.5, reward.exit)
            reward.phase = 'done'
        end
    elseif reward.phase == 'done' then
        transitions.update(dt)
    end
end

function reward.draw()
    exp_screen.draw()

    if textbox.is_active() then
        textbox.draw()
    end
    
    if transitions.is_active() then
        transitions.draw()
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

function reward.recover_party()
    for i, member in ipairs(reward.party) do
        if member:is_alive() then
            local hp_recover = math.max(1, math.floor(member.max_hp * 0.05))
            local mp_recover = math.max(1, math.floor(member.max_mp * 0.05))
            member.current_hp = math.min(member.max_hp, member.current_hp + hp_recover)
            member.current_mp = math.min(member.max_mp, member.current_mp + mp_recover)
        end
    end
end

function reward.exit()
    reward.recover_party()
    reward.game.switch_state('field', {reset_encounter = true})
end

return reward