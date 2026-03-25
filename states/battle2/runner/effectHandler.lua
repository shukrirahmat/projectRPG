local effectData = require('data.effectData')
local animationCreator = require('entities.animationCreator')
local gameState = require('gameState')

local effectHandler = {}

local state = {}

local function runEffect(effect)
    
    if effect.target.isDead 
    and effect.ref ~= 'revive' 
    and effect.ref ~= 'stealGold' 
    and effect.ref ~= 'stealItem' then
        return
    end
    
    if effect.target and effect.target.isInvincible then
        state.result = effectData['immune'].apply(effect.user, effect.target, effect.value)
        return
    end

    state.result = effectData[effect.ref].apply(effect.user, effect.target, effect.value)

    if effect.target and effect.target.isPartyMember and effectData[effect.ref].partyAnimation then
        local aniData = effectData[effect.ref].partyAnimation
        local animation = animationCreator.new(
            effect.target, aniData.ref, gameState.battleSpeed * aniData.speed, effect.value
        )
        state.result.animation = animation
    elseif effect.target and not effect.target.isPartyMember and effectData[effect.ref].enemyAnimation then
        local aniData = effectData[effect.ref].enemyAnimation
        local animation = animationCreator.new(
            effect.target, aniData.ref, gameState.battleSpeed * aniData.speed, effect.value
        )
        state.result.animation = animation
    end
end

-----------------------------------------
----------------PUBLIC-------------------
-----------------------------------------

function effectHandler.load()
    state.effectQueue = {}
    state.isFinished = false
    state.result = nil
end

function effectHandler.add(effects)
    for i, effect in ipairs(effects) do
        table.insert(state.effectQueue, effect)
    end
    state.isFinished = false
    state.result = nil
end

function effectHandler.runNext()
    if #state.effectQueue == 0 then
        state.isFinished = true
        return
    end

    local effect = state.effectQueue[1]
    table.remove(state.effectQueue, 1)
    runEffect(effect)
end

function effectHandler.isFinished()
    return state.isFinished
end

function effectHandler.getResult()
    local result = state.result
    state.result = nil
    return result
end

return effectHandler