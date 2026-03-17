local gameState = require('gameState')
local enemyCreator = require('entities.enemyCreator')
local battlerCreator = require('entities.battlerCreator')

local encounter = {}

local state = {
    battlers = nil;
    isEncountering = false;
}

function encounter.isEncountering()
    return state.isEncountering
end

function encounter.setup()
    local battlers = state.battlers
    state.isEncountering = false
    state.battlers = nil
    
    return battlers
end

function encounter.start()

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
            local name = ''..k:sub(1, 1):upper()..''..k:sub(2)..' #'..i..''
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

    state.isEncountering = true
    state.battlers = {party = party, enemies = enemies}
end

return encounter