local function createHud(_party)

    local party = _party

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

    local function alignNumber(value)
        local result
        if value/100 > 1 then
            result = ''..value..''
        elseif value/10 > 1 then
            result = ' '..value..''
        else
            result = '  '..value..''
        end
        return result
    end

    local function draw()

        for index, member in ipairs(party) do
            if member.dead then
                love.graphics.setColor(0.25, 0.25, 0.25)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.rectangle(
                'line',
                borderX + (index - 1) * (borderWidth + borderX),
                borderY,
                borderWidth,
                borderHeight
            )
            love.graphics.setFont(font_small)
            love.graphics.printf(
                member.name,
                nameX + (index - 1) * (borderWidth + borderX),
                nameY,
                nameWidth,
                'center'
            )
            local memberHpX = hpX + (index - 1) * (borderWidth + borderX)
            local memberMpX = memberHpX
            love.graphics.setFont(font_large)
            love.graphics.printf(
                'HP '..alignNumber(member.currentHp)..'',
                memberHpX, 
                hpY, 
                hpWidth,
                'center'
            )
            love.graphics.printf(
                'MP '..alignNumber(member.currentMp)..'', 
                memberMpX, 
                mpY, 
                mpWidth,
                'center'
            )
        end
    end
    
    return {
        draw = draw
    }
end

return createHud;
