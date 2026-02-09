local state = require('state')
local utils = require('utils')
local animation = require('animation')

local loop = {}

function loop.run()

    if state.battleEnded then
        state.battleLog = {}
        if state.partyDied then
            utils.battleLogAdd('Party has been defeated')
        elseif state.allEnemyDead then
            utils.battleLogAdd('All enemy has been defeated')
        end
        state.textTimer = 0
    elseif #state.killList > 0 then
        local toKill = state.killList[1]
        table.remove(state.killList, 1)
        utils.handleDeath(toKill)

        if not toKill.isPartyMember then
            state.animation = animation.new(toKill, 'enemyDied', 8, 0.05)
        end

        if state.partyDied or state.allEnemyDead then
            state.battleEnded = true
        end

    elseif #state.effectList > 0 then
        local effect = state.effectList[1]
        table.remove(state.effectList, 1)
        effect.apply()

    elseif #state.priorityList > 0 then
        state.battleLog = {};
        local action = state.priorityList[1]
        table.remove(state.priorityList, 1)

        if action.target and action.target.isDead then
            action.target = utils.reselectTargetWhenDead(action.target)
        end

        action.execute()

    elseif #state.actionList > 0 then
        state.battleLog = {};
        local nextActionIndex = utils.chooseNextActionIndex()
        local action = state.actionList[nextActionIndex]
        table.remove(state.actionList, nextActionIndex)

        if action.target and action.target.isDead then
            action.target = utils.reselectTargetWhenDead(action.target)
        end

        action.execute()
    else
        utils.clearTemporaryStatus()
        state.battleRunning = false
        state.textTimer = 0
        state.battleLog = {}
        state.currentMenu = state.mainMenu
        state.mainMenu.position = 1
    end
end

return loop