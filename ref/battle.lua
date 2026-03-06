local battleState = require('battleState')
local hud = require('hud')
local enemySprites = require('enemySprites')
local menu = require('menu')
local battleInput = require('battleInput')
local loop = require('loop')

local battle = {}

function battle.load(party, enemies, gold, items)
    battleState.party = party
    battleState.enemies = enemies
end

function battle.update(dt)
    
    if battleState.encounterMessage then
        battleState.textTimer = battleState.textTimer + dt
        if battleState.textTimer >= battleState.textSpeed * 0.5 then
            battleState.encounterMessage = nil
            battleState.battleLog = {}
        end
    elseif battleState.battleRunning or battleState.battleEnded then
        
        if #battleState.rewardQueue == 0 then
            battleState.textTimer = battleState.textTimer + dt
        end
        
        if battleState.animation then
            battleState.animation.timer = battleState.animation.timer + dt
            if battleState.animation.tick >= battleState.animation.maxTick then
                battleState.animation = nil
            elseif battleState.animation.timer >= battleState.animation.speed then
                battleState.animation.tick = battleState.animation.tick + 1
                battleState.animation.timer = 0;
            end
        elseif battleState.textTimer >= battleState.textSpeed then
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
    if battleState.encounterMessage then
        menu.drawBattleLog()
    elseif not battleState.battleRunning then
        menu.draw()
    elseif battleState.battleRunning and #battleState.battleLog > 0 then
        menu.drawBattleLog()
    end


    --TEMPORARY
    --[[love.graphics.setColor(1, 1, 1)
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

    end]]
end

function battle.keypressed(key)
    if #battleState.rewardQueue > 0 then
        if key == 'z' then
            battleState.textTimer = battleState.textSpeed
        end
    elseif not battleState.battleRunning and not battleState.encounterMessage then
        if key == 'up' then
            battleInput.executeUp()
        elseif key == 'down' then
            battleInput.executeDown()
        elseif key == 'left' then
            battleInput.executeLeft()
        elseif key == 'right' then
            battleInput.executeRight()
        elseif key == 'z' then
            battleInput.executeConfirm()
        elseif key == 'x' then
            battleInput.executeCancel()
        end
    end
end

return battle