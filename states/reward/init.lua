local textBox = require('systems.textBox')
local expScreen = require('states.reward.expScreen')

local reward = {}

local state = {}

function reward.load(stateManager, var)
    state.expGained = var.exp
    textBox.start('Gained '..state.expGained..' EXP.')
end

function reward.update(dt)
    if textBox.isOpen() then
        textBox.update(dt)
    end
    
    if expScreen.isDistributing() then
        expScreen.update(dt)
    end
end

function reward.draw()
    if textBox.isOpen() then
        textBox.draw()
    end
    expScreen.draw()
end

function reward.keypressed(key)
    if textBox.isOpen and key == 'z' then
        if textBox.isFinished() then
            textBox.close()
            expScreen.distribute(state.expGained)
        else
            textBox.skip()
        end
    end
end


return reward