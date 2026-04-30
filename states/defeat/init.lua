local textbox = require('systems.textbox')
local transitions = require('systems.transitions')
local player = require('systems.player')
local mapper = require('systems.mapper')
local party_manager = require('systems.party_manager')
local input = require('input')

local defeat = {
    timer = 0,
    delay = 0.5
}

function defeat.load(game)
    defeat.game = game
    defeat.phase = 'start'
    
    local party = party_manager.get_members()
    local total_level = 0
    for i, member in ipairs(party) do
        total_level = total_level + member.lvl
    end
    defeat.gold_lost = math.min(total_level * 50, party_manager.get_gold())
end

function defeat.update(dt)
    if defeat.phase == 'start' then
        defeat.timer = defeat.timer + dt
        if defeat.timer >= defeat.delay then
            defeat.phase = 'text'
            textbox.queue({'You managed to ran away toward safety.'})
            textbox.queue({'You dropped '..defeat.gold_lost..' gold in panic.'})
        end
    elseif defeat.phase == 'text' then
        textbox.update(dt)
        if not textbox.is_busy() then
            transitions.load('fade_out', 0.5, defeat.exit)
            defeat.phase = 'exiting'
        end
    elseif defeat.phase == 'exiting' then
        transitions.update(dt)
    end
end

function defeat.draw()
    if textbox.is_active() then
        textbox.draw()
    end
    
    if transitions.is_active() then
        transitions.draw()
    end
end

function defeat.keypressed(key)
    if textbox.is_active() and key == input.confirm then
        if textbox.is_finished() then
            textbox.advance()
        else
            textbox.skip()
        end
    end
end

function defeat.exit()
    local party = party_manager.get_members()
    for i, member in ipairs(party) do
        member.is_dead = false
        member.current_hp = member.max_hp
        member.current_mp = member.max_mp
        member.status = {}
    end
    party_manager.manage_gold(-1 * defeat.gold_lost)
    
    defeat.game.switch_state('field', {checkpoint = true})
end

return defeat