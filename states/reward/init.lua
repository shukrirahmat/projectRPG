local textBox = require('systems.textBox')
local expScreen = require('states.reward.expScreen')

local reward = {}

local state = {}

function reward.load(stateManager, var)
    textBox.start('Gained '..var.exp..' EXP.')
    expScreen.start(var.exp)
end

function reward.update(dt)
    if textBox.isBusy() then
        textBox.update(dt)
    elseif expScreen.isDistributing() then
        expScreen.update(dt)
    end
end

function reward.draw()
    if textBox.isActive() then
        textBox.draw()
    end
    expScreen.draw()
end

function reward.keypressed(key)
    if textBox.isActive() and key == 'z' then
        if textBox.isFinished() then
            textBox.close()
        else
            textBox.skip()
        end
    elseif expScreen.isDistributing() then
        expScreen.skip()
    end
end


return reward