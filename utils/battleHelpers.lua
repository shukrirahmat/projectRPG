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

return battleHelpers