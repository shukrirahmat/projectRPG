local textBox = require('systems.textBox')
local expScreen = require('states.reward.expScreen')
local spoils = require('states.reward.spoils')
local gameState = require('gameState')
local transition = require('systems.transition')

local reward = {}

local state = {}

function reward.load(stateManager, var)
    state.manager = stateManager
    textBox.start({'Gained '..var.exp..' EXP.'})
    expScreen.start(var.exp)
    spoils.start(var.gold, var.items)
    state.exiting = false
end

function reward.update(dt)
    if textBox.isBusy() then
        textBox.update(dt)
    end
    
    if transition.isActive() then
        transition.update(dt)
    end
    
    if not expScreen.isDisplayOn() then
        expScreen.updateDisplay(dt)
    end
    
    if not textBox.isBusy() and expScreen.isDistributing() then
        expScreen.update(dt)
    end
    
    if not expScreen.isDistributing() and spoils.isActive() then
        spoils.update(dt)
    end
    
    if not textBox.isBusy()
    and not expScreen.isDistributing()
    and not spoils.isActive() 
    and not state.exiting then
        transition.start({ref = 'fadeOut', speed = 0.5})
        state.exiting = true
    end
    
    if state.exiting and not transition.isActive() then
        state.manager.switch('field', {fadesIn = true})
    end
end

function reward.draw()
    if textBox.isActive() then
        textBox.draw()
    end
    
    expScreen.draw()
    
    if transition.isActive() then
        transition.draw()
    end
end

function reward.keypressed(key)
    if textBox.isActive() and key == 'z' then
        if textBox.isFinished() then
            textBox.advance()
        else
            textBox.skip()
        end
    elseif expScreen.isDistributing() then
        expScreen.skip()
    end
end


return reward