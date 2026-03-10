local battleLog = require('states.battle.battleLog')
local battleHandler = require('states.battle.battleHandler')
local animationCreator = require('entities.animationCreator')
local effectData = require('data.effectData')

local battleLoop = {}

local function checkIfAllDead(group)
    local totalDead = 0
    for _, member in ipairs(group) do
        if member.isDead then
            totalDead = totalDead + 1
        end
    end
    return totalDead == #group;
end

local function handleDeath(state, target)
    target.currentHp = 0
    target.isDead = true
    target.status = {}
    battleLog.addText(''..target.name..' defeated.')
    battleHandler.removeAction(state, target)

    if target.isPartyMember and checkIfAllDead(state.party) then
        state.partyDied = true
    elseif not target.isPartyMember and checkIfAllDead(state.enemies) then
        state.allEnemyDead = true
    end
end

local function handleBattleEnd(state)
    state.battleLog = {}
    if state.partyDied then
        battleLog.addText('Party has been defeated')
    elseif state.allEnemyDead then
        battleLog.addText('All enemies has been defeated')
    end
end

local function doNextKill(state)
    local toKill = state.killQueue[1]
    table.remove(state.killQueue, 1)
    handleDeath(state, toKill)
    if not toKill.isPartyMember then
        state.animation = animationCreator.new(toKill, 'enemyDied', state.actionSpeed)
    end

    if (state.partyDied or state.allEnemyDead) and #state.effectQueue == 0 then
        state.battleEnded = true
    end
    state.textTimer = 0
end

function applyEffect(state, effect)
    if effect.target and effect.target.isInvincible then
        effectData['immune'].apply(effect.user, effect.target, effect.value)
        return
    end

    effectData[effect.ref].apply(effect.user, effect.target, effect.value)
    
    if effect.target and effect.target.isPartyMember and effectData[effect.ref].partyAnimation then
        local aniRef = effectData[effect.ref].partyAnimation
        local animation = animationCreator.new(effect.target, aniRef, state.actionSpeed, effect.value)
        state.animation = animation
    elseif effect.target and not effect.target.isPartyMember and effectData[effect.ref].enemyAnimation then
        local aniRef = effectData[effect.ref].enemyAnimation
        local animation = animationCreator.new(effect.target, aniRef, state.actionSpeed, effect.value)
        state.animation = animation
    end
end

local function doNextEffect(state)
    local effect = state.effectQueue[1]
    table.remove(state.effectQueue, 1)

    if not effect.target.isDead 
    or effect.ref == 'revive' 
    or effect.ref == 'stealGold' 
    or effect.ref == 'stealItem' then
        applyEffect(state, effect)
        if effect.ref == 'instakill' then
            state.actionTimer = state.actionSpeed
        else
            state.actionTimer = 0
        end
    else
        state.actionTimer = state.actionSpeed
    end 
end


function battleLoop.run(state, dt)
    state.actionTimer = state.actionTimer + dt
    if state.actionTimer >= state.actionSpeed then
        if state.battleEnded then
            handleBattleEnd(state)
        elseif #state.killQueue > 0 then
            doNextKill(state)
        elseif #state.effectQueue > 0 then
            doNextEffect(state)        
        elseif #battleState.followUp > 0 then
            local action = battleState.followUp[1]
            table.remove(battleState.followUp, 1)

            local skip;

            if action.ref == 'secondAtk' or action.ref == 'counterAtk' then
                if action.targets[1].isDead or utils.checkCannotMove(action.targets[1]) then
                    skip = true
                else
                    battleState.battleLog = {};
                    executeAction(action, true)
                end
            else
                battleState.battleLog = {};
                action = redirectTarget(action)
                executeAction(action, true)
            end

            if #battleState.followUp == 0 then
                statusApply(action)
                statusClearAll(action)
            end

            if skip then
                battleState.textTimer = 5
            else
                battleState.textTimer = 0
            end

        elseif #battleState.priorityList > 0 then
            battleState.battleLog = {};

            local actionIndex = nextPriorityIndex()
            local action = battleState.priorityList[actionIndex]
            table.remove(battleState.priorityList, actionIndex)

            action = redirectTarget(action)
            action = statusPass(action)
            executeAction(action)

            if #battleState.followUp == 0 then
                statusApply(action)
                statusClearAll(action)
            end
            battleState.textTimer = 0

        elseif #battleState.actionList > 0 then
            battleState.battleLog = {};
            local nextActionIndex = utils.chooseNextActionIndex()
            local action = battleState.actionList[nextActionIndex]
            table.remove(battleState.actionList, nextActionIndex)

            action = redirectTarget(action)
            action = statusPass(action)
            executeAction(action)

            if #battleState.followUp == 0 then
                statusApply(action)
                statusClearAll(action)
            end
            battleState.textTimer = 0

        else
            utils.clearTemporaryStatus()
            battleState.battleRunning = false
            battleState.battleLog = {}
            battleState.currentMenu = battleState.mainMenu
            battleState.mainMenu.position = 1
            battleState.textTimer = 0
        end
    end
end

return battleLoop;