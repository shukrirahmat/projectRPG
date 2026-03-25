local effectCreator = require('entities.effectCreator')

local turnEndHandler = {}

local state = {}

local function statusApply()
    
    if state.user.status['POISON'] then
        local baseAmount = math.floor(state.user.maxHp * 0.1)
        local mod = math.floor(baseAmount*0.2)
        local amount = math.max(1, baseAmount + math.random(-mod, mod))
        local poisonEffect = effectCreator.new('poisonDamage', state.user, state.user, amount)
        table.insert(state.result.effects, poisonEffect)
    end

    if state.user.status['CURSE'] then
        local max
        if state.user.isPartyMember then
            max = 20
        else
            max = 4
        end
        local roll = math.random(1, max)
        if roll == 1 then
            local curseEffect = effectCreator.new('curseEffect', state.user, state.user)
            table.insert(state.result.effects, curseEffect)
        end
    end

    if state.user.passives['regenerate'] then
        local baseAmount = math.floor(state.user.maxHp * 0.1)
        local mod = math.floor(baseAmount*0.2)
        local amount = baseAmount + math.random(-mod, mod)
        local recoverEffect = effectCreator.new('recover', state.user, state.user, amount)
        table.insert(state.result.effects, recoverEffect)
    end
end

local function statusClear(user, status, chance)
    local roll = math.random(0, 100)
    if roll <= chance then
        local clear = effectCreator.new('clearStatus', user, user, status)
        table.insert(state.result.effects, clear)
    end
end

local function countDownStats(user, status)
    if user.status[status].countdown > 0 then
        user.status[status].countdown = user.status[status].countdown - 1;
    elseif user.status[status].countdown <= 0 then
        local clear = effectCreator.new('clearStatus', user, user, status)
        table.insert(state.result.effects, clear)
    end
end

local function statusClearAll()

    local cat1 = {'BLIND', 'SEAL', 'STUN'}
    local rate = {20, 30, 60}

    for i, status in ipairs(cat1) do
        if state.user.status[status] then
            statusClear(state.user, status, rate[i])
        end
    end

    local cat2 = {'STEEL', 'FLEET', 'FRAIL', 'SNARE', 'BARRIER', 'MIGHT'}

    for i, status in ipairs(cat2) do
        if state.user.status[status] then
            countDownStats(state.user, status)
        end
    end
end

-----------------------------------------
----------------PUBLIC-------------------
-----------------------------------------

function turnEndHandler.load(user)
    state.user = user
    state.isFinished = false
    state.result = nil
end

function turnEndHandler.run()
    state.result = { effects = {} }
    statusApply()
    statusClearAll()
    state.isFinished = true
end

function turnEndHandler.isFinished()
    return state.isFinished
end

function turnEndHandler.getResult()
    local result = state.result
    state.result = nil
    return result
end

return turnEndHandler