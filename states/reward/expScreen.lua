local gameState = require('gameState')
local expData = require('data.expData')

local expScreen = {}

local state = {
    isDistributing = false,
}

local function setAliveMember()
    local alive = {}
    for i, member in ipairs(gameState.party) do
        if not member.isDead then
            table.insert(alive, member)
        end
    end    
    return alive
end

function expScreen.distribute(totalExp)
    state.isDistributing = true
    state.timer = 0
    state.speed = 0.05    
    state.aliveMember = setAliveMember()
    
    state.expPerMember = math.floor(totalExp / #state.aliveMember) 
    state.remainingExp = state.expPerMember
end

function expScreen.isDistributing()
    return state.isDistributing
end

function expScreen.update(dt)
    if not state.isDistributing then return end
    state.timer = state.timer + dt
    
    while state.timer >= state.speed and state.remainingExp > 0 do
        state.timer = state.timer - state.speed
        for i, member in ipairs(state.aliveMember) do
            member.totalExp = member.totalExp + 1
            if member.totalExp >= expData[member.lvl + 1] then
                member.lvl = member.lvl + 1
            end
        end
        state.remainingExp = state.remainingExp - 1
    end
    
    if state.remainingExp <= 0 then
        state.isDistributing = false
    end
end

function expScreen.draw()

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
        local filled = innerWidth * (currentExp / (expData[member.lvl + 1] - expData[member.lvl]))

        love.graphics.rectangle('fill', barX, barY, filled, 15)

        local nextX = innerX
        local nextY = barY + 20
        local nextWidth = innerWidth

        love.graphics.setFont(font_small)
        love.graphics.printf('Next: '..member.nextExp()..'', nextX, nextY, nextWidth, 'right')


    end
end

return expScreen