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
        if member.isDead then
            love.graphics.setColor(0.25, 0.25, 0.25)
        else
            love.graphics.setColor(1, 1, 1)
        end

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
        love.graphics.printf('HP '..alignNumber(member.currentHp + hpBit)..'', memberHpX, hpY + shiftY, hpWidth,        'center')
        love.graphics.printf('MP '..alignNumber(member.currentMp)..'', memberMpX, mpY + shiftY, mpWidth,        'center')
    end
end

return hud