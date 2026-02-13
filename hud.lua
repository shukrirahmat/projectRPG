local state = require('state')

local hud = {}

local function alignNumber(value)
    local result
    if value/100 >= 1 then
        result = ''..value..''
    elseif value/10 >= 1 then
        result = ' '..value..''
    else
        result = '  '..value..''
    end
    return result
end

local function drawStatusEffect(x, y, width, index, char)
    local borderX = x + (index - 1) * (width + x) + 10
    local borderY = y + 5
    local borderWidth = width - 20
    local borderHeight = 65
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle('fill', borderX, borderY, borderWidth, borderHeight)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(font_tiny)
    local i = 0
    local j = 0
    for k,v in pairs(char.status) do
        love.graphics.printf(
            string.sub(k, 1, 3),
            borderX + (i * (borderWidth  /3)),
            borderY + (j * 15),
            borderWidth /3,
            'center'
        )
        i = i + 1
        if i > 3 then
            i = 0
            j = j + 1
        end
    end
end
    

function hud.draw()

    local borderX = 10
    local borderY = 10
    local borderWidth = 120
    local borderHeight = 90
    local nameX = borderX + 5
    local nameY = borderY + 5
    local nameWidth = borderWidth - 10
    local hpX = borderX + 5
    local hpY = borderY + 25
    local hpWidth = borderWidth - 10
    local mpX = borderX + 5
    local mpY = borderY + 25 * 2
    local mpWidth = borderWidth - 10

    for index, member in ipairs(state.party) do

        --MOVE DOWNWARD FOR ANIMATION
        local shiftY = 0
        local hpBit = 0
        if state.animation 
        and state.animation.user == member 
        and state.animation.ref == 'partyDamaged' then
            if state.animation.tick <= 3 then
                shiftY = state.animation.tick * 4
            else
                shiftY = math.max(0, (16 - (state.animation.tick) * 2))
            end

            local hpDrop = math.min(state.animation.value, member.currentHp)
            local dropPerTick = math.floor(hpDrop/state.animation.maxTick)
            if state.animation.tick < state.animation.maxTick then
                hpBit = (state.animation.maxTick - state.animation.tick) * dropPerTick
            else
                hpBit = 0
            end
        end
        
        if state.infoMode then
            drawStatusEffect(borderX, borderY + borderHeight, borderWidth, index, state.party[index])
        end
        
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle(
            'fill',
            borderX + (index - 1) * (borderWidth + borderX),
            borderY + shiftY,
            borderWidth,
            borderHeight
        )

        if member.isDead then
            love.graphics.setColor(0.25, 0.25, 0.25)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.rectangle(
            'line',
            borderX + (index - 1) * (borderWidth + borderX),
            borderY + shiftY,
            borderWidth,
            borderHeight
        )
            

        love.graphics.setFont(font_small)
        love.graphics.printf(
            member.name,
            nameX + (index - 1) * (borderWidth + borderX),
            nameY + shiftY,
            nameWidth,
            'center'
        )
        love.graphics.setFont(font_large)
        local memberHpX = hpX + (index - 1) * (borderWidth + borderX)
        local memberMpX = mpX + (index - 1) * (borderWidth + borderX)
        love.graphics.setFont(font_large)
        if not state.infoMode then
            love.graphics.printf(
                'HP '..alignNumber(member.currentHp + hpBit)..'', 
                memberHpX, hpY + shiftY, hpWidth,'center')
            love.graphics.printf(
                'MP '..alignNumber(member.currentMp)..'', 
                memberMpX, mpY + shiftY, mpWidth,'center')
        else
            love.graphics.printf(
                ''..alignNumber(member.currentHp + hpBit)..'/'..alignNumber(member.maxHp)..'', 
                memberHpX, hpY + shiftY, hpWidth, 'center')
            love.graphics.printf(
                ''..alignNumber(member.currentMp)..'/'..alignNumber(member.maxMp)..'', 
                memberMpX, mpY + shiftY, mpWidth, 'center')
        end
    end
end

return hud