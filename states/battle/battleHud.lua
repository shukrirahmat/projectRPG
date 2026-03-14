local sprites = require('graphics.sprites')

local battleHud = {}

function battleHud.draw(state)

    local borderX = 10
    local borderY = 10
    local borderWidth = 128
    local borderHeight = 96
    local innerX = borderX + 15
    local innerY = borderY + 5
    local innerWidth = borderWidth - 30


    for index, member in ipairs(state.party) do

        local shiftY = 0
        local hpBit = 0
        local progress;

        if state.animation 
        and state.animation.user == member 
        and state.animation.ref == 'partyDamaged' then
            progress = state.animation.timer / state.animation.speed
            shiftY = 15 * math.sin(progress * math.pi)

            local hpDrop = state.animation.value
            if member.currentHp < 0 then
                hpDrop = state.animation.value + member.currentHp
            end
            hpBit = math.floor( hpDrop * (1 - progress)^2)
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
            innerX + (index - 1) * (borderWidth + borderX),
            innerY + shiftY,
            innerWidth,
            'center'
        )

        love.graphics.setFont(font_large)
        local hudStat = {'HP' , 'MP'}
        local hpValue = math.max(0, member.currentHp + hpBit)
        local values = {hpValue, member.currentMp}
        for i, stat in ipairs(hudStat) do
            love.graphics.printf(
                stat, 
                innerX + (index - 1) * (borderWidth + borderX),
                innerY + shiftY + 25 + (i - 1) * 28,
                innerWidth*0.25,
                'left'
            )
        end
        for i, value in ipairs(values) do
            if member.isDead then
                love.graphics.setColor(0.25, 0.25, 0.25)
            elseif i == 1 and value/member.maxHp <= 0.2 then
                love.graphics.setColor(0.97, 0.28, 0.11)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.printf(
                value, 
                innerX + innerWidth*0.25 + (index - 1) * (borderWidth + borderX),
                innerY + shiftY + 25 + (i - 1) * 28,
                innerWidth*0.75,
                'right'
            )
        end

        for n = 1, 2 do
            love.graphics.setColor(0.25, 0.25, 0.25)
            love.graphics.rectangle(
                'line',
                innerX + (index - 1) * (borderWidth + borderX),
                innerY + shiftY + 46 + (n - 1) * 28,
                innerWidth,
                5
            )

            local bar;
            if n == 1 then
                love.graphics.setColor(0, 0.85, 0.4)
                local hpBar;
                if progress then
                    hpBar = math.max(0, (((1-progress)^2) * state.animation.value + member.currentHp)/member.maxHp)
                else
                    hpBar = (math.max(0, member.currentHp) / member.maxHp)
                end
                bar = innerWidth * hpBar
            else
                if member.isDead then
                    love.graphics.setColor(0.25, 0.25, 0.25)
                else
                    love.graphics.setColor(0.50, 0, 0.85)
                end
                bar = innerWidth * (member.currentMp / member.maxMp)
            end
            love.graphics.rectangle(
                'fill',
                innerX + (index - 1) * (borderWidth + borderX),
                innerY + shiftY + 46 + (n - 1) * 28,
                bar,
                5
            )
        end


        local j = 1
        local statusY = 0
        for k, v in pairs(member.status) do
            if j > 8 then
                j = 1;
                statusY = statusIconDimension;
            end
            local xpos = borderX + (index - 1) * (borderWidth + borderX) + (j - 1) * statusIconDimension
            local ypos = borderY + borderHeight + statusY
            love.graphics.draw(
                sprites['status_Icons'],
                sprites[k],
                xpos,
                ypos + shiftY
            )
            j = j + 1;
        end
    end
end

return battleHud