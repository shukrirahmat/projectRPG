local gameState = require('gameState')

local rewardScreen = {}

function rewardScreen.draw()
    
    local startX = 20
    local startY = 20
    local boxWidth = ((windowWidth - startX * 2) / 4) - 10
    local boxHeight = windowHeight - 10 - gameState.textHeight - 10 - startY
    
    for i, member in ipairs(gameState.party) do
        local boxX = startX + 5 + (i - 1) * (boxWidth + 10)
        local boxY = startY
        
        love.graphics.rectangle(
            'line',
            boxX,
            boxY,
            boxWidth,
            boxHeight
        )
    end
end

return rewardScreen