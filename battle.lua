local battleState = require('battleState')
local hud = require('hud')
local enemySprites = require('enemySprites')
local menu = require('menu')
local input = require('input')
local loop = require('loop')

local battle = {}

function battle.load(party, enemies, gold, items)
    battleState.party = party
    battleState.enemies = enemies
    battleState.partyGold = gold
    battleState.partyItems = items
end

function battle.update(dt)

    if battleState.battleRunning or battleState.battleEnded then
        battleState.textTimer = battleState.textTimer + dt
        if battleState.animation then
            battleState.animation.timer = battleState.animation.timer + dt
            if battleState.animation.tick >= battleState.animation.maxTick then
                battleState.animation = nil
            elseif battleState.animation.timer > battleState.animation.speed then
                battleState.animation.tick = battleState.animation.tick + 1
                battleState.animation.timer = 0;
            end
        elseif battleState.textTimer > battleState.textSpeed then
            loop.run()
        end
    end

    if love.keyboard.isDown('c') then
        battleState.infoMode = true
    else
        battleState.infoMode = false
    end

end

function battle.draw()
    hud.draw()
    enemySprites.draw()
    if not battleState.battleRunning then
        menu.draw()
    elseif battleState.battleRunning and #battleState.battleLog > 0 then
        menu.drawBattleLog()
    end


    --TEMPORARY
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font_small)
    for index, enemy in ipairs(battleState.enemies) do
        local text
        if enemy.isDead then
            text = 'DEAD'
        else
            text = ''..enemy.name..' '..enemy.currentHp..'|'..enemy.currentMp..''
        end

        if battleState.animation and battleState.animation.user == enemy then
            text = 'ANI '..text..''
        else
            text = '--- '..text..''
        end

        love.graphics.print(
            text,
            windowWidth - 200,
            5 + (index - 1) * 20
        )

    end
end

function battle.keypressed(key)
    if not battleState.battleRunning then
        if key == 'up' then
            input.executeUp()
        elseif key == 'down' then
            input.executeDown()
        elseif key == 'left' then
            input.executeLeft()
        elseif key == 'right' then
            input.executeRight()
        elseif key == 'z' then
            input.executeConfirm()
        elseif key == 'x' then
            input.executeCancel()
        end
    end
end

return battle