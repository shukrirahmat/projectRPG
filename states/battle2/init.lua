local transition = require('systems.transition')
local logger = require('states.battle2.logger')
local hud = require('states.battle2.hud')

local battle = {}

local state = {}

function battle.load(stateManager, var)
    state.manager = stateManager
    state.party = var.party
    state.enemies = var.enemies
    state.isBossBattle = var.boss or false

    transition.load({ref = 'fadeIn', speed = 0.5})
    logger.load('Enemies encountered!')
    hud.load(state.party)
    state.phase = 'intro'
end

function battle.update(dt)

    if state.phase == 'intro' then
        transition.update(dt)
        logger.update(dt)
        if not transition.isActive() and not logger.isActive() then
            state.phase = 'menuInput'
        end
    end
end

function battle.draw()
    
    hud.draw()

    if logger.isActive() then
        logger.draw()
    end

    if transition.isActive() then
        transition.draw()
    end
end

function battle.keypressed(key)
end

return battle