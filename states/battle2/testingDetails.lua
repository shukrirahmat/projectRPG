local testingDetails = {}

function testingDetails.draw(party, enemies)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font_small)
    for i, enemy in ipairs(enemies) do
        love.graphics.printf(
            ''..enemy.name..' '..enemy.currentHp..'/'..enemy.maxHp..' '..enemy:getAtk()..' '..enemy:getDef()..' '..enemy:getAgi()..'',
            10,
            10 + (i - 1) * 20,
            windowWidth - 20,
            'right'
        )
    end

    love.graphics.setFont(font_small)
    for i, char in ipairs(party) do
        love.graphics.printf(
            ''..char.name..' '..char.currentHp..'/'..char.maxHp..' '..char:getAtk()..' '..char:getDef()..' '..char:getAgi()..'',
            10,
            10 + #enemies * 20 + (i - 1) * 20,
            windowWidth - 20,
            'right'
        )
    end
end

return testingDetails