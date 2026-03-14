local gameState = require('gameState')
local expData = require('data.expData')

local rewardScreen = {}

function rewardScreen.draw()
    
    local startX = 20
    local startY = 20
    local boxWidth = ((windowWidth - startX * 2) / 4) - 10
    local boxHeight = windowHeight - 10 - gameState.textHeight - 10 - startY
    
    for i, member in ipairs(gameState.party) do
        
        local boxX = startX + 5 + (i - 1) * (boxWidth + 10)
        local boxY = startY
        local innerX = boxX + 15
        local innerWidth = boxWidth - 30
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle('line', boxX, boxY, boxWidth, boxHeight)
        
        local spriteX = boxX + boxWidth * 0.5 - monsterSpriteDimension * 0.5
        local spriteY = boxY + 20
        
        love.graphics.draw(member.sprite, spriteX, spriteY)
        love.graphics.rectangle('line', spriteX, spriteY, monsterSpriteDimension, monsterSpriteDimension)
        
        local nameX = innerX
        local nameY = spriteY + monsterSpriteDimension + 10
        local nameWidth = innerWidth
        
        love.graphics.setFont(font_medium)
        love.graphics.printf(member.name, nameX, nameY, nameWidth, 'center')
        
        local lvlX = innerX
        local lvlY = nameY + 40
        local lvlWidth = innerWidth
        
        love.graphics.setFont(font_medium)
        love.graphics.printf('LVL '..member.lvl..'', lvlX, lvlY, lvlWidth, 'left')
        
        local barX = innerX
        local barY = lvlY + 25
        local barWidth = innerWidth
        
        love.graphics.rectangle('line', barX, barY, innerWidth, 15)
        
        local currentExp = member.totalExp - expData[member.lvl]
        local filled = innerWidth * (currentExp / expData[member.lvl + 1])
        
        love.graphics.rectangle('fill', barX, barY, filled, 15)
        
        local nextX = innerX
        local nextY = barY + 20
        local nextWidth = innerWidth
        
        love.graphics.setFont(font_small)
        love.graphics.printf('Next: '..member.nextExp..'', nextX, nextY, nextWidth, 'right')
        
        
    end
end

return rewardScreen