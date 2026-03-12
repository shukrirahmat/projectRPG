local gameState = require('gameState')
local enemyCreator = require('entities.enemyCreator')
local battlerCreator = require('entities.battlerCreator')

local fieldEncounter = {}

function fieldEncounter.generate(state)

    local encounterSet = {}

    local rollTimes = 1
    local moreRoll = true
    local moreRollChance = 100
    while moreRoll and rollTimes <= gameState.currentMap.maxEncounter do
        local roll_1 = math.random(0, 100)
        if roll_1 <= moreRollChance then
            local roll_2 = math.random(1, #gameState.currentMap.encounters)
            local enemyRef = gameState.currentMap.encounters[roll_2]
            if not encounterSet[enemyRef] then
                encounterSet[enemyRef] = 1
            else
                encounterSet[enemyRef] = encounterSet[enemyRef] + 1
            end
            rollTimes = rollTimes + 1
            moreRollChance = math.floor(moreRollChance * 0.9);
        else
            moreRoll = false
        end
    end

    local enemies = {}

    for k, v in pairs(encounterSet) do
        for i = 1, v do
            local name = ''..k:upper()..''..i..''
            local enemy = enemyCreator.new(k, name)
            table.insert(enemies, enemy)
        end
    end

    local party = {
        battlerCreator.new(gameState.party[1]),
        battlerCreator.new(gameState.party[2]),
        battlerCreator.new(gameState.party[3]),
        battlerCreator.new(gameState.party[4])
    }

    return {party = party, enemies = enemies}
end

return fieldEncounter;