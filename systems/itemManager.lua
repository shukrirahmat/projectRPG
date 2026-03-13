local gameState = require('gameState')

local itemManager = {}

function itemManager.manageItems(ref, mod)
    if gameState.partyItems[ref] then
        gameState.partyItems[ref] = gameState.partyItems[ref] + mod
    elseif not gameState.partyItems[ref] and mod > 0 then
        gameState.partyItems[ref] = mod
    end

    if gameState.partyItems[ref] < 1 then
        gameState.partyItems[ref] = nil
    end
end

return itemManager