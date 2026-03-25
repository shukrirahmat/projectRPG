local transition = require('systems.transition')
local logger = require('states.battle2.logger')
local hud = require('states.battle2.hud')
local enemySprites = require('states.battle2.enemySprites')
local menu = require('states.battle2.menu')
local runner = require('states.battle2.runner')
local testingDetails = require('states.battle2.testingDetails')
local gameState = require('gameState')

local battle = {}

local state = {}

local function exitBattle()
    for i, member in ipairs(state.party) do
        gameState.party[i].isDead = member.isDead;
        gameState.party[i].currentHp = member.currentHp
        gameState.party[i].currentMp = member.currentMp
        gameState.party[i].status['POISON'] = member.status['POISON']
        gameState.party[i].status['CURSE'] = member.status['CURSE']
        gameState.party[i].status['WOUND'] = member.status['WOUND']
        gameState.party[i].status['PARALYSIS'] = member.status['PARALYSIS']
    end

    local expGained = 0
    local goldGained = 0
    local itemDropped = {}
    for i, enemy in ipairs(state.enemies) do
        expGained = expGained + enemy.exp
        goldGained = goldGained + enemy.goldDrop

        if enemy.itemDrop then
            for k,v in pairs(enemy.itemDrop) do
                local success = math.random(1, v) == 1
                if success then
                    table.insert(itemDropped, {ref = k, dropper = enemy.name})
                end
            end
        end
    end

    state.manager.switch('reward', {exp = expGained, gold = goldGained, items = itemDropped})
end

---------------------------
----------PUBLIC-----------
---------------------------

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
            runner.load(state.party, state.enemies)
            state.phase = 'running'
        end
    end

    if state.phase == 'running' then
        runner.update(dt)
        if not runner.isActive() then
            if runner.isEnemyDefeated() then
                logger.load('Battle won!')
                state.phase = 'exit'
            else
                menu.load(state.party, state.enemies)
                state.phase = 'menu'
            end
        end
    end

    if state.phase == 'exit' then
        logger.update(dt)
        if not logger.isActive() then
            exitBattle()
        end
    end
end

function battle.draw()

    hud.draw()
    enemySprites.draw()

    if menu.isActive() then
        menu.draw()
    end

    if logger.isActive() or state.phase == 'running' then
        logger.draw()
    end

    if transition.isActive() then
        transition.draw()
    end

    testingDetails.draw(state.party, state.enemies)
end

function battle.keypressed(key)
    if menu.isActive() then
        menu.keypressed(key)
    end
end

return battle