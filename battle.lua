local state = require('state')
local hud = require('hud')
local enemySprites = require('enemySprites')
local menu = require('menu')
local input = require('input')
local loop = require('loop')

local battle = {}

function battle.load(party, enemies, gold)
    state.party = party
    state.enemies = enemies
    state.partyGold = gold
end

function battle.update(dt)

    if state.battleRunning or state.battleEnded then
        state.textTimer = state.textTimer + dt
        if state.animation then
            state.animation.timer = state.animation.timer + dt
            if state.animation.tick >= state.animation.maxTick then
                state.animation = nil
            elseif state.animation.timer > state.animation.speed then
                state.animation.tick = state.animation.tick + 1
                state.animation.timer = 0;
            end
        elseif state.textTimer > state.textSpeed then
            loop.run()
        end
    end
    
    if love.keyboard.isDown('c') then
        state.infoMode = true
    else
        state.infoMode = false
    end
    
end

function battle.draw()
    hud.draw()
    enemySprites.draw()
    if not state.battleRunning then
        menu.draw()
    elseif state.battleRunning and #state.battleLog > 0 then
        menu.drawBattleLog()
    end
        

    --TEMPORARY
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font_small)
    for index, enemy in ipairs(state.enemies) do
        local text
        if enemy.isDead then
            text = 'DEAD'
        else
            text = ''..enemy.name..' '..enemy.currentHp..'|'..enemy.currentMp..''
        end
        
        if state.animation and state.animation.user == enemy then
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
    if not state.battleRunning then
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