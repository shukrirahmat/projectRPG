local function createTopWindow(_party)

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
        for i, member in ipairs(party) do
            if member.getStat('dead') then
                love.graphics.setColor(0.25, 0.25, 0.25)
            else
                love.graphics.setColor(1, 1, 1)
            end     

            love.graphics.rectangle(
                'line',
                borderX + (i - 1) * (borderWidth + borderX),
                borderY,
                borderWidth,
                borderHeight
            )
            love.graphics.setFont(font_small)
            love.graphics.printf(
                member.getStat('name'),
                nameX + (i - 1) * (borderWidth + borderX),
                nameY,
                nameWidth,
                'center'
            )
            love.graphics.setFont(font_large)
            local memberHpX = hpX + (i - 1) * (borderWidth + borderX)
            local memberMpX = memberHpX
            love.graphics.setFont(font_large)
            love.graphics.printf(
                'HP '..alignNumber(member.getStat('currentHp'))..'',
                memberHpX,
                hpY,
                hpWidth,
                'center'
            )
            love.graphics.printf(
                'MP '..alignNumber(member.getStat('currentMp'))..'', 
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

return createTopWindow