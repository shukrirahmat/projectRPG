local battleHud = {}

function battleHud.draw(state)

    local borderX = 10
    local borderY = 10
    local borderWidth = 120
    local borderHeight = 90
    local innerX = borderX + 20
    local innerY = borderY + 5
    local innerWidth = borderWidth - 40


    for index, member in ipairs(state.party) do

        local shiftY = 0
        local hpBit = 0

        if state.animation 
        and state.animation.user == member 
        and state.animation.ref == 'partyDamaged' then
            local progress = state.animation.timer / state.animation.speed
            shiftY = 15 * math.sin(progress * math.pi)

            local hpDrop = math.min(state.animation.value, member.currentHp)
            hpBit = math.ceil( hpDrop * (1 - progress))
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
        elseif (member.currentHp / member.maxHp) <= 0.2 then
            love.graphics.setColor(0.97, 0.28, 0.11)
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
            innerX + (index - 1) * (borderWidth + borderX),
            innerY + shiftY,
            innerWidth,
            'center'
        )

        love.graphics.setFont(font_large)
        local hudStat = {'HP' , 'MP'}
        local values = {member.currentHp + hpBit, member.currentMp}
        for i, stat in ipairs(hudStat) do
            love.graphics.printf(
                stat, 
                innerX + (index - 1) * (borderWidth + borderX),
                innerY + shiftY + 25 + (i - 1) * 25,
                innerWidth/2,
                'left'
            )
        end
        for i, value in ipairs(values) do
            love.graphics.printf(
                value, 
                innerX + innerWidth/2 + (index - 1) * (borderWidth + borderX),
                innerY + shiftY + 25 + (i - 1) * 25,
                innerWidth/2,
                'right'
            )
        end
    end
end

return battleHud