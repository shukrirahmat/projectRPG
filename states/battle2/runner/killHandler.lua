local animationCreator = require('entities.animationCreator')
local gameState = require('gameState')

local killHandler = {}

local state = {}

function killHandler.load()
    state.killQueue = {}
    state.isFinished = false
    state.result = nil
end

function killHandler.add(toKill)
    table.insert(state.killQueue, toKill)
    state.isFinished = false
    state.result = nil
end

function killHandler.killNext()
    if #state.killQueue == 0 then
        state.isFinished = true
        return
    end
    
    local target = state.killQueue[1]
    table.remove(state.killQueue, 1)
    
    target.currentHp = 0
    target.isDead = true
    target.status = {}
    
    
    local text = ''..target.name..' defeated.'
    
    local animation
    if not target.isPartyMember then
        animation = animationCreator.new(target, 'enemyDied', gameState.battleSpeed * 0.5)
    end
    
    state.result = {text = text, target = target, animation = animation}
end

function killHandler.isFinished()
    return state.isFinished
end

function killHandler.getResult()
    local result = state.result
    state.result = nil
    return result
end



return killHandler