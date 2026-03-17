local gameState = require('gameState')
local textBox = require('systems.textBox')
local itemData = require('data.itemData')
local itemManager = require('systems.itemManager')

local spoils = {}

local state = {}

function spoils.load(gold, items)
    state.active = true
    state.gold = gold
    state.items = items
end

function spoils.isActive()
    return state.active
end

function spoils.update(dt)
    gameState.partyGold = gameState.partyGold + state.gold
    textBox.queue({'The party obtained '..state.gold..' gold.'})
    
    local itemLines = {}
    for i, item in ipairs(state.items) do
        itemManager.manageItems(item.ref, 1)
        local itemName = itemData[item.ref].name
        table.insert(itemLines, ''..item.dropper..' dropped '..itemName..'.')
    end
    
    if #itemLines > 0 then
        textBox.queue(itemLines)
    end
    
    state.active = false;    
end

return spoils