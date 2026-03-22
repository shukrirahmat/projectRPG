local transition = require('systems.transition')
local logger = require('states.battle2.logger')
local hud = require('states.battle2.hud')
local enemySprites = require('states.battle2.enemySprites')
local menu = require('states.battle2.menu')

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
    enemySprites.load(state.enemies)
    state.phase = 'intro'
end

function battle.update(dt)

    if state.phase == 'intro' then
        transition.update(dt)
        logger.update(dt)
        if not transition.isActive() and not logger.isActive() then
            menu.load(state.party, state.enemies)
            state.phase = 'menu'
        end
    end

    if state.phase == 'menu' then
        menu.update(dt)
        if not menu.isActive() then
            --TEST--
            for i, member in ipairs(state.party) do
                print(member.currentAction.user.name)
                print(member.currentAction.ref)
                print(member.currentAction.targets[1].name)
                print('****')
            end
            state.phase = 'doneTest'
        end
    end
end

function battle.draw()

    hud.draw()
    enemySprites.draw()

    if menu.isActive() then
        menu.draw()
    end

    if logger.isActive() then
        logger.draw()
    end

    if transition.isActive() then
        transition.draw()
    end
end

function battle.keypressed(key)
    if menu.isActive() then
        menu.keypressed(key)
    end
end

return battle