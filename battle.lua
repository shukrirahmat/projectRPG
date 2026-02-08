local state = require('state')
local hud = require('hud')
local enemySprites = require('enemySprites')
local menu = require('menu')
local input = require('input')

local battle = {}

function battle.load(party, enemies)
    state.party = party
    state.enemies = enemies
end

function battle.update(dt)

end

function battle.draw()
    hud.draw()
    enemySprites.draw()
    if not state.battleRunning then
        menu.draw()
    end
end

function battle.keypressed(key)
    if not state.battleRunning then
        if key == 'up' then
            input.executeUp()
        elseif key == 'down' then
            input.executeDown()
        elseif key == 'z' then
            input.executeConfirm()
        elseif key == 'x' then
            input.executeCancel()
        end
    end
end

return battle