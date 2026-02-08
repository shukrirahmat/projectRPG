local state = require('state')
local utils = require('utils')

local loop = {}

function loop.run()

    if state.battleEnded then
        state.battleLog = {}
        if partyDied then
            utils.battleLogAdd('Party has been defeated')
        elseif allEnemyDead then
            utils.battleLogAdd('All enemy has been defeated')
        end
        state.textTimer = 0
    elseif #state.killList > 0 then
        local toKill = state.killList[1]
        table.remove(state.killList, 1)
        utils.handleDeath(toKill)

        if partyDied or allEnemyDead then
            state.battleEnded = true
        end

    elseif #state.effectList > 0 then
        local effect = state.effectList[1]
        table.remove(state.effectList, 1)
        effect.apply()

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
        state.battleRunning = false
        state.textTimer = 0
        state.battleLog = {}
        state.currentMenu = state.mainMenu
        state.mainMenu.position = 1
    end
end

return loop