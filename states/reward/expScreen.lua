local gameState = require('gameState')
local expData = require('data.expData')
local partyManager = require('systems.partyManager')
local textBox = require('systems.textBox')

local expScreen = {}

local state = {
    isDistributing = false,
    levelUpQueue = {}
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

function expScreen.start(totalExp)
    state.isDistributing = true
    state.levelUpQueue = {}
    state.aliveMember = setAliveMember()
    state.expPerMember = math.floor(totalExp / #state.aliveMember)
    state.speed = math.max(1, math.floor(state.expPerMember * 0.75))

    for i, member in ipairs(gameState.party) do
        member.displayExp = member.totalExp
        member.displayLvl = member.lvl
        if not member.isDead then
            local levelUps = partyManager.increaseExp(member, state.expPerMember)

            for i, data in ipairs(levelUps) do
                table.insert(state.levelUpQueue, data)
            end
        end
    end
end

function expScreen.isDistributing()
    return state.isDistributing
end

function expScreen.skip()
    for i, member in ipairs(state.aliveMember) do
        member.displayExp = member.totalExp
        member.displayLvl = member.lvl
    end
end

function expScreen.update(dt)
    if not state.isDistributing then return end

    local allFinished = true
    for i, member in ipairs(state.aliveMember) do

        if member.displayExp < member.totalExp then
            allFinished = false

            member.displayExp = math.min(member.displayExp + state.speed * dt, member.totalExp)

            local requiredExp = expData[member.displayLvl + 1]
            if requiredExp and member.displayExp >= requiredExp then
                member.displayLvl = member.displayLvl + 1
            end
        end
    end

    if allFinished then 
        state.isDistributing = false
        for i, data in ipairs(state.levelUpQueue) do
            local textLines = {}
            table.insert(textLines, ''..data.member.name..' has leveled up to LVL '..data.lvl..'!')
            if data.skill then
                table.insert(textLines, 'Learned: '..data.skill..'.')
            end
            textBox.queue(textLines)
        end
    end
end

function expScreen.draw()

    local startX = 20
    local startY = 20
    local boxWidth = ((windowWidth - startX * 2) / 4) - 10
    local boxHeight = windowHeight - 20 - gameState.textHeight - 20 - startY

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

        love.graphics.setFont(font_large)
        love.graphics.printf(member.name, nameX, nameY, nameWidth, 'center')

        local lvlX = innerX
        local lvlY = nameY + 40
        local lvlWidth = innerWidth

        love.graphics.setFont(font_large)
        love.graphics.printf('LVL '..member.displayLvl..'', lvlX, lvlY, lvlWidth, 'left')

        local plusX = innerX
        local plusY = nameY + 43
        local plusWidth = innerWidth

        if not member.isDead then
            love.graphics.setFont(font_medium)
            love.graphics.printf('+ '..state.expPerMember..' EXP', plusX, plusY, plusWidth, 'right')
        end

        local barX = innerX
        local barY = lvlY + 27
        local barWidth = innerWidth

        love.graphics.rectangle('line', barX, barY, innerWidth, 15)

        local currentExp = member.displayExp - expData[member.displayLvl]
        local diffExp = expData[member.displayLvl + 1] - expData[member.displayLvl]
        local filled = innerWidth * (currentExp / diffExp)

        love.graphics.rectangle('fill', barX, barY, filled, 15)

        local nextX = innerX
        local nextY = barY + 20
        local nextWidth = innerWidth
        local nextExp = expData[member.displayLvl + 1]
        local remainingExp = math.ceil(nextExp - member.displayExp)

        love.graphics.setFont(font_medium)
        love.graphics.printf('Next: '..remainingExp..'', nextX, nextY, nextWidth, 'right')
    end
end

return expScreen