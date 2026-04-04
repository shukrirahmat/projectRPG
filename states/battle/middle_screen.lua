local middle_screen = {}

local enemies = nil
local SPRITE_DIMENSION = 128
local SPRITE_GAP = 10
local lg = love.graphics
local is_animating = false

function middle_screen.load(enemy_battlers)
    enemies = enemy_battlers
end

function middle_screen.is_animating()
    return is_animating
end

function middle_screen.update(dt)    
    is_animating = false
    
    for i, enemy in ipairs(enemies) do
        if enemy.animation then
            is_animating = true
            enemy:update(dt)
        end
    end
end

function middle_screen.draw()
    
    for i, enemy in ipairs(enemies) do
        local x_start = lg.getWidth()/2 + (i - 1) * (SPRITE_DIMENSION + SPRITE_GAP)
        local x_reposition = (SPRITE_DIMENSION/2) * #enemies + (#enemies - 1) * (SPRITE_GAP/2)
        local x = x_start - x_reposition
        local y = lg.getHeight()/2 - SPRITE_DIMENSION/1.5
        enemy:draw(x, y)
    end
end

return middle_screen