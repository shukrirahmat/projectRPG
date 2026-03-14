local reward = {}

local state = {}

function reward.load(stateManager, var)
end

function reward.update(dt)

end

function reward.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font_large)
    love.graphics.print('something', 10, 10)
end

function reward.keypressed(key) 
end


return reward