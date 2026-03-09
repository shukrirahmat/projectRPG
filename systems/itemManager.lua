local gameState = require('gameState')

local itemManager = {}

function itemManager.manageItems(item, mod)
    if gameState.partyItems[item.ref] then
        gameState.partyItems[item.ref].amount = gameState.partyItems[item.ref].amount + mod
    elseif not gameState.partyItems[item.ref] and mod > 0 then
        gameState.partyItems[item.ref] = {item = item , amount = mod}
    end

    if gameState.partyItems[item.ref].amount < 1 then
        gameState.partyItems[item.ref] = nil
    end
end

return itemManager