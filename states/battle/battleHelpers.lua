local battleHelpers = {}

function battleHelpers.getOppositeGroup(state, character)
    if character.isPartyMember then
        return state.enemies
    else
        return state.party
    end
end

function battleHelpers.getOwnGroup(state, character)
    if character.isPartyMember then
        return state.party
    else
        return state.enemies
    end
end

function battleHelpers.selectTargetRandomly(group)
    local availableTargets = {}

    for _, target in ipairs(group) do
        if not target.isDead then
            table.insert(availableTargets, target)
        end
    end

    local selectedTarget
    local i = 1

    while not selectedTarget do
        if i == #availableTargets then
            selectedTarget = availableTargets[i]
        else
            local chance = math.random(1, 10)
            if chance < 5 then
                i = i + 1
            else
                selectedTarget = availableTargets[i]
            end
        end
    end

    return selectedTarget
end

function battleHelpers.removeAction(state, user)
    for i = #state.actionQueue, 1, -1 do
        if state.actionQueue[i].user == user then
            table.remove(state.actionQueue, i)
        end
    end
    for i = #state.priorityQueue, 1, -1 do
        if state.priorityQueue[i].user == user then
            table.remove(state.priorityQueue, i)
        end
    end
end

function battleHelpers.updateStatChange(target, stat)
    if stat == 'def' then
        local buff = target.defBuff or 0
        local debuff = target.defDebuff or 0
        target.def = target.baseDef + buff - debuff
    elseif stat == 'agi' then
        local buff = target.agiBuff or 0
        local debuff = target.agiDebuff or 0
        target.agi = target.baseAgi + buff - debuff
    elseif stat == 'atk' then
        local buff = target.atkBuff or 0
        target.atk = target.baseAtk + buff
    end
end

return battleHelpers