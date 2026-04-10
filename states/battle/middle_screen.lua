local ui = require('graphics.ui')

local middle_screen = {}

local enemies = nil
local SPRITE_DIMENSION = 128
local SPRITE_GAP = 10
local STATUS_ICON_SIZE = 16
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

local function draw_enemy_status(enemy, x, y)
    local i = 1
    local shift = 0
    for k, v in pairs(enemy.status) do
        if i > 8 then
            i = 1;
            shift = STATUS_ICON_SIZE;
        end
        local xpos = x + (i - 1) * STATUS_ICON_SIZE
        local ypos = y + SPRITE_DIMENSION + shift
        lg.draw(
            ui.get_sprite('status_icons'),
            ui.get_sprite(k),
            xpos,
            ypos
        )
        i = i + 1;
    end
end

function middle_screen.draw()
    
    for i, enemy in ipairs(enemies) do
        local x_start = lg.getWidth()/2 + (i - 1) * (SPRITE_DIMENSION + SPRITE_GAP)
        local x_reposition = (SPRITE_DIMENSION/2) * #enemies + (#enemies - 1) * (SPRITE_GAP/2)
        local x = x_start - x_reposition
        local y = lg.getHeight()/2 - SPRITE_DIMENSION/1.5
        enemy:draw(x, y)
        draw_enemy_status(enemy, x, y)
    end
end

return middle_screen