local helpers = {}

function helpers.selectTargetRandomly(group)
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

function helpers.getDeadTarget(group)
    local deadTargets = {}

    for _, target in ipairs(group) do
        if target.isDead then
            table.insert(deadTargets, target)
        end
    end

    if #deadTargets <= 0 then return nil end

    local roll = math.random(1 , #deadTargets)
    return deadTargets[roll]
end

return helpers