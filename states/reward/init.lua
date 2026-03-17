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
    --state.exiting = false
    state.phase = 'intro'
end

function reward.update(dt)

    if state.phase == 'intro' then
        expScreen.updateDisplay(dt)
        textBox.update(dt)
        if not textBox.isBusy() and expScreen.isDisplayOn() then
            state.phase = 'distributeExp'
        end
    end

    if state.phase == 'distributeExp' then
        expScreen.update(dt)
        if not expScreen.isDistributing() then
            state.phase = 'expText'
        end
    end

    if state.phase == 'expText' then
        textBox.update(dt)
        if not textBox.isBusy() then
            state.phase = 'spoils'
        end
    end

    if state.phase == 'spoils' then
        spoils.update(dt)
        if not spoils.isActive() then
            state.phase = 'spoilsText'
        end
    end

    if state.phase == 'spoilsText' then
        textBox.update(dt)
        if not textBox.isBusy() then
            transition.start({ref = 'fadeOut', speed = 0.5})
            state.phase = 'transitionOut'
        end
    end

    if state.phase == 'transitionOut' then
        transition.update(dt)
        if not transition.isActive() then
            state.phase = 'exiting'
        end
    end

    if state.phase == 'exiting' then
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