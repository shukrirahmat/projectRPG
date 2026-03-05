local owState = require('overworldState')
local levelHandler = require('levelHandler')
local actionData = require('actionData')
local passiveData = require('passiveData')
local battlerCreator = require('battlerCreator')

local statusScreen = {}

local function drawLeft(member, divider_1, divider_2, panelSize)
    
    local divider_3 = monsterSpriteDimension * 2 + 20 + 10
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.line(10, divider_3, divider_1, divider_3)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font_large)
    love.graphics.print(member.name, 10 + 20, 10 + 10)
    
    local stats = {
        'LEVEL', 'HP', 'MP', 
        'ATTACK', 'DEFENSE', 'STRENGTH', 'VITALITY', 'AGILITY', 
        'CURRENT EXP', 'NEXT LEVEL'
    }
    
    local values = {
        member.lvl, 
        ''..member.currentHp..'/'..member.maxHp..'', 
        ''..member.currentMp..'/'..member.maxMp..'',
        member.baseAtk,
        member.baseDef,
        member.str,
        member.vit,
        member.baseAgi,
        member.totalExp,
        levelHandler.expNeeded[member.lvl + 1] - member.totalExp
    }
    
    love.graphics.setFont(font_medium)
    for i, text in ipairs(stats) do
        love.graphics.printf(
            text,
            10 + 20,
            divider_3 + 20 + (i - 1) * 24,
            panelSize / 2 - 40,
            'left'
        )
    end
    
    love.graphics.setFont(font_medium)
    for i, text in ipairs(values) do
        love.graphics.printf(
            text,
            panelSize / 2 + 20,
            divider_3 + 20 + (i - 1) * 24,
            panelSize / 2 - 40,
            'right'
        )
    end
end

function drawMiddle(member, divider_1, divider_2, panelSize)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font_large)
    love.graphics.printf('EQUIPMENT', divider_1, 10 + 10, panelSize, 'center')
    
    local weapon = member.weapon and member.weapon.name or '---'
    local shield = member.shield and member.shield.name or '---'
    local armor = member.armor and member.armor.name or '---'
    
    local eqtype = {'WEAPON', 'SHIELD', 'ARMOR'}
    local name = {weapon, shield, armor}
    
    love.graphics.setFont(font_medium)
    for i, text in ipairs(eqtype) do
        love.graphics.printf(
            text,
            divider_1 + 20,
            10 + 40 + (i - 1) * 24,
            panelSize / 2 - 40,
            'left'
        )
    end
    
    love.graphics.setFont(font_medium)
    for i, text in ipairs(name) do
        love.graphics.printf(
            text,
            panelSize / 2 + divider_1 + 20,
            10 + 40 + (i - 1) * 24,
            panelSize / 2 - 40,
            'right'
        )
    end
    
    local skillsY = 24 * 3 + 40 * 2
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font_large)
    love.graphics.printf('SKILLS', divider_1, skillsY, panelSize, 'center')
    
    local skillsList = {}
    for i, skillRef in ipairs(member.skills) do
        local name = actionData[skillRef].name
        table.insert(skillsList, name)
    end
    
    for i, passiveRef in ipairs(member.passiveSkills) do
        local name = passiveData[passiveRef].name
        table.insert(skillsList, name)
    end
    
    love.graphics.setFont(font_medium)
    for i, skill in ipairs(skillsList) do
        love.graphics.printf(
            skill,
            divider_1 + 20,
            skillsY + 40 + (i - 1) * 22,
            panelSize - 40,
            'left'
        )
    end
end

function drawRight(member, divider_1, divider_2, panelSize)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font_large)
    love.graphics.printf('RESISTANCE', divider_2, 20 , panelSize, 'center')
    
    local resistances = { 
        'FIRE', 'ICE', 'WIND', 'BOLT', 'LIGHT', 'VOID', 'AURA', 'DRAIN', 'MANABURN',
        'BLIND', 'SEAL', 'STUN', 'POISON', 'WOUND', 'CURSE', 'SLEEP', 'CONFUSE', 'PARALYSIS',
        'DEATH', 'FRAIL', 'SNARE'
    }
    
    love.graphics.setFont(font_medium)
    for i, res in ipairs(resistances) do
        love.graphics.printf(
            res,
            divider_2 + 20,
            10 + 40 + (i - 1) * 24,
            (windowWidth - 20) / 6 - 40,
            'left'
        )
        
        local value;
        if member.immune[res] then
            value = 'IMMUNE'
        elseif member.strong[res] then
            value = 'STRONG'
        else
            value = '---'
        end
        
        love.graphics.printf(
            value,
            divider_2 + 20 + panelSize/2,
            10 + 40 + (i - 1) * 24,
            panelSize/2 - 40,
            'right'
        )
    end
end

local function drawTopArrow()
    love.graphics.polygon(
        'fill',
        windowWidth/2 - 10,
        20,
        windowWidth/2 + 10,
        20,
        windowWidth/2 ,
        15
    )
end

local function drawBottomArrow()
    love.graphics.polygon(
        'fill',
        windowWidth/2 - 10,
        windowHeight - 20,
        windowWidth/2 + 10,
        windowHeight - 20,
        windowWidth/2 ,
        windowHeight - 15
    )
end
    

function statusScreen.draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', 0, 0, windowWidth, windowHeight)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', 10, 10, windowWidth - 20, windowHeight - 20)
    
    local member = battlerCreator.new(owState.party[owState.statusScreen.position])
    local panelSize = (windowWidth - 20) / 3
    local divider_1 = panelSize + 10
    local divider_2 = 2 * panelSize + 10
    
    love.graphics.line(divider_1, 10, divider_1, windowHeight - 10)
    love.graphics.line(divider_2, 10, divider_2, windowHeight - 10)
    
    drawLeft(member, divider_1, divider_2, panelSize)
    drawMiddle(member, divider_1, divider_2, panelSize)
    drawRight(member, divider_1, divider_2, panelSize)
    
    if owState.statusScreen.position < #owState.party then
        drawBottomArrow()
    end
    
    if owState.statusScreen.position > 1 then
        drawTopArrow()
    end
    
end

return statusScreen