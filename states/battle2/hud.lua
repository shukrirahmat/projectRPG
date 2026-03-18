local gameState = require('gameState')
local sprites = require('graphics.sprites')

local hud = {}

local state = {}

function hud.load(party)
    state.party = party
    state.timer = 0
    state.speed = gameState.battleSpeed
    state.takingDamage = false
end

function hud.istakingDamage()
    return state.takingDamage
end

function hud.takeDamage(member, damage)
    state.takingDamage = { member = member, damage = damage}
end

function hud.update(dt)
    if not state.takingDamage then return end
    
    state.timer = state.timer + dt
    if state.timer >=  state.speed then
        state.timer = 0
        state.takingDamage = false
    end
end

function hud.draw()
    
    local marginX = 20
    local marginY = marginX
    local borderWidth = 128
    local borderHeight = 96
    local paddingX = 15
    local paddingY = 5
    
    local borderX = marginX
    local borderY = marginY
    local innerX = borderX + paddingX
    local innerY = borderY + paddingY
    local innerWidth = borderWidth - paddingX * 2


    for index, member in ipairs(state.party) do

        local shiftY = 0
        local hpBit = 0
        local progress;

        if state.takingDamage and state.takingDamage.member == member then
            progress = state.timer / state.speed
            shiftY = 15 * math.sin(progress * math.pi)

            local hpDrop = state.takingDamage.damage
            if member.currentHp < 0 then
                hpDrop = state.takingDamage.damage + member.currentHp
            end
            hpBit = math.floor( hpDrop * (1 - progress)^2)
        end

        local gap = 10
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle(
            'fill',
            borderX + (index - 1) * (borderWidth + gap),
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
            borderX + (index - 1) * (borderWidth + gap),
            borderY + shiftY,
            borderWidth,
            borderHeight
        )

        love.graphics.setFont(font_medium)
        love.graphics.printf(
            member.name,
            innerX + (index - 1) * (borderWidth + gap),
            innerY + shiftY,
            innerWidth,
            'center'
        )
        
        local statY = 25
        local statLineHeight = 28

        love.graphics.setFont(font_xlargeMono)
        local hudStat = {'HP' , 'MP'}
        local hpValue = math.max(0, member.currentHp + hpBit)
        local values = {hpValue, member.currentMp}
        for i, stat in ipairs(hudStat) do
            love.graphics.printf(
                stat, 
                innerX + (index - 1) * (borderWidth + gap),
                innerY + shiftY + statY + (i - 1) * statLineHeight,
                innerWidth * 0.4,
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
                innerX + innerWidth*0.4 + (index - 1) * (borderWidth + gap),
                innerY + shiftY + statY + (i - 1) * statLineHeight,
                innerWidth*0.6,
                'right'
            )
        end
        
        local barY = 48
        local barLineHeight = statLineHeight
        local barHeight = 4

        for n = 1, 2 do
            love.graphics.setColor(0.25, 0.25, 0.25)
            love.graphics.rectangle(
                'line',
                innerX + (index - 1) * (borderWidth + gap),
                innerY + shiftY + barY + (n - 1) * barLineHeight,
                innerWidth,
                barHeight
            )

            local barWidth;
            if n == 1 then
                love.graphics.setColor(0.75, 0.75, 0.75)
                local hpRatio;
                if progress then
                    hpRatio = math.max(0, (((1-progress)^2) * state.takingDamage.damage 
                            + member.currentHp)/member.maxHp)
                else
                    hpRatio = (math.max(0, member.currentHp) / member.maxHp)
                end
                barWidth = innerWidth * hpRatio
            else
                if member.isDead then
                    love.graphics.setColor(0.25, 0.25, 0.25)
                else
                    love.graphics.setColor(0.75, 0.75, 0.75)
                end
                barWidth = innerWidth * (member.currentMp / member.maxMp)
            end
            love.graphics.rectangle(
                'fill',
                innerX + (index - 1) * (borderWidth + gap),
                innerY + shiftY + barY + (n - 1) * barLineHeight,
                barWidth,
                barHeight
            )
        end


        love.graphics.setColor(1, 1, 1)
        local j = 1
        local statusY = 0
        for k, v in pairs(member.status) do
            if j > 8 then
                j = 1;
                statusY = statusIconDimension;
            end
            local xpos = borderX + (index - 1) * (borderWidth + gap) + (j - 1) * statusIconDimension
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

return hud