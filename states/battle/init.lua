local gameState = require('gameState')

local battle = {}

local state = {}

function battle.load(stateManager, var)
    state.manager = stateManager
    state.party = var.party
    state.enemies = var.enemies
end

function battle.update(dt)
end

function battle.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font_large)
    for i, member in ipairs(state.party) do
        love.graphics.print(member.name, 10, 10 + (i - 1) * 20)
    end
    
    for i, enemy in ipairs(state.enemies) do
        love.graphics.print(enemy.name, 100, 10 + (i - 1) * 20)
    end
end

function battle.keypressed(key)
end

return battle