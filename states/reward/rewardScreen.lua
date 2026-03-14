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
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle(
            'line',
            boxX,
            boxY,
            boxWidth,
            boxHeight
        )
        
        local spriteX = boxX + boxWidth * 0.5 - monsterSpriteDimension * 0.5
        local spriteY = boxY + 20
        
        love.graphics.draw(
            member.sprite,
            spriteX,
            spriteY
        )
        love.graphics.rectangle(
            'line',
            spriteX,
            spriteY,
            monsterSpriteDimension,
            monsterSpriteDimension
        )
    end
end

return rewardScreen