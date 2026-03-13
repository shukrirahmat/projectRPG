local testingDetails = {}

function testingDetails.draw(state)
    love.graphics.setFont(font_small)
    for i, enemy in ipairs(state.enemies) do
        love.graphics.printf(
            ''..enemy.name..' '..enemy.currentHp..'/'..enemy.maxHp..' '..enemy.atk..' '..enemy.def..' '..enemy.agi..'',
            10,
            10 + (i - 1) * 20,
            windowWidth - 20,
            'right'
        )
    end

    love.graphics.setFont(font_small)
    for i, char in ipairs(state.party) do
        love.graphics.printf(
            ''..char.name..' '..enemy.currentHp..'/'..enemy.maxHp..' '..char.atk..' '..char.def..' '..char.agi..'',
            10,
            10 + #state.enemies * 20 + (i - 1) * 20,
            windowWidth - 20,
            'right'
        )
    end
end

return testingDetails