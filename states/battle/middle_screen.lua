local ui = require('graphics.ui')
local fonts = require('fonts')

local middle_screen = {}

local enemies = nil
local SPRITE_DIMENSION = 128
local SPRITE_GAP = 10
local STATUS_ICON_SIZE = 16
local lg = love.graphics
local animation = nil
local is_animating = false

local function draw_text(enemy, x, y, text, font, color)
    if color and color == 'grey' then
        lg.setColor(0.6,0.6,0.6)
    elseif color and color == 'blue' then
        lg.setColor(0.5,0.3,0.7)
    elseif color and color == 'dark_blue' then
        lg.setColor(0.3, 0.2 ,0.4)
    else
        lg.setColor(1,1,1)
    end
    local progress = animation.timer / animation.duration
    lg.setFont(font)
    lg.printf(
        text,
        x,
        y + (enemy.sprite:getHeight() - enemy.sprite_height) - 20 - (20 * progress),
        enemy.sprite:getWidth(),
        'center'
    )
end

local function draw_attack_animation(enemy, x, y)
    lg.setColor(1, 1, 1)
    local enemy_movement = { 
        {x=-5, y=0},
        {x=-5, y=-2.5},
        {x=-5, y=-5},
        {x=-2.5, y=-5},
        {x= 0, y=-5},
        {x= 2.5, y=-5},
        {x=5, y=-5},
        {x=5, y=-2.5},
        {x=5, y=0},
        {x=5, y=2.5},
        {x=5, y=5},
        {x=2.5, y=5},
        {x= 0, y=5},
    }

    local progress = animation.timer / animation.duration
    local move_index = math.floor(progress * 13)
    local movement = enemy_movement[move_index]

    if movement then
        lg.draw(enemy.sprite, x + movement.x, y + movement.y)
    else
        lg.draw(enemy.sprite, x, y)
    end
end

local function draw_damaged_animation(enemy, x, y, color)
    local progress = animation.timer / animation.duration
    local tick = math.floor(progress * 10)
    if tick == 1 or tick == 3 then
        lg.setColor(0.1, 0.1, 0.1)
        lg.draw(enemy.sprite, x, y)
    else
        lg.setColor(1, 1, 1)
        lg.draw(enemy.sprite, x, y)
    end

    if tick >= 1 then
        draw_text(enemy, x, y, animation.value, fonts.bold_mono, color)
    end
end

local function draw_missed_animation(enemy, x, y, color)
    local progress = animation.timer / animation.duration
    local tick = math.floor(progress * 10)
    if tick == 1 or tick == 3 then
        lg.draw(enemy.sprite, x + 3, y)
    elseif tick == 2 then
        lg.draw(enemy.sprite, x + 5, y)
    else
        lg.draw(enemy.sprite, x, y)
    end

    if tick >= 1 then
        draw_text(enemy, x, y, 'MISS', fonts.medium_mono, color)
    end
end

local function draw_immune_animation(enemy, x, y)
    local progress = animation.timer / animation.duration
    local tick = math.floor(progress * 10)
    if tick == 1 or tick == 2 or tick == 3  then
        lg.setColor(1, 1, 1, 0.8)
        lg.draw(enemy.sprite, x, y)
    else
        lg.setColor(1, 1, 1)
        lg.draw(enemy.sprite, x, y)
    end
end

local function draw_death_animation(enemy, x, y)
    local tint = math.max(0, 1 - animation.timer / animation.duration)
    lg.setColor(tint, tint, tint)
    lg.draw(enemy.sprite, x, y)
end

local function draw_animation(enemy, x, y)
    if animation.type == 'attack' then
        draw_attack_animation(enemy, x, y)
    elseif animation.type == 'damaged' then
        draw_damaged_animation(enemy, x, y)
    elseif animation.type == 'resisted' then
        draw_damaged_animation(enemy, x, y, 'grey')
    elseif animation.type == 'mp_damaged' then
        draw_damaged_animation(enemy, x, y, 'blue')
    elseif animation.type == 'mp_resisted' then
        draw_damaged_animation(enemy, x, y, 'dark_blue')
    elseif animation.type == 'missed' then
        draw_missed_animation(enemy, x, y)
    elseif animation.type == 'missed_resist' then
        draw_missed_animation(enemy, x, y, 'grey')
    elseif animation.type == 'immune' then
        draw_immune_animation(enemy, x, y)
    elseif animation.type == 'death' then
        draw_death_animation(enemy, x, y)
    end
end


local function draw_enemy(enemy, x, y)
    if is_animating and animation.enemy == enemy then
        draw_animation(enemy, x, y)
    else
        if enemy.is_dead then return end
        lg.setColor(1, 1, 1)
        lg.draw(enemy.sprite, x, y)
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

        local ref = k
        if type(v) == 'table' and v.stack and v.stack == 2 then
            ref = ''..ref..'2'
        end

        lg.draw(
            ui.get_sprite('status_icons'),
            ui.get_sprite(ref),
            xpos,
            ypos
        )
        i = i + 1;
    end
end

function middle_screen.load(enemy_battlers)
    enemies = enemy_battlers
end

function middle_screen.update(dt)
    if not is_animating then return end
    animation.timer = animation.timer + dt
    if animation.timer >= animation.duration then
        animation.timer = 0
        animation = nil
        is_animating = false
    end
end

function middle_screen.draw()

    for i, enemy in ipairs(enemies) do
        local x_start = lg.getWidth()/2 + (i - 1) * (SPRITE_DIMENSION + SPRITE_GAP)
        local x_reposition = (SPRITE_DIMENSION/2) * #enemies + (#enemies - 1) * (SPRITE_GAP/2)
        local x = x_start - x_reposition
        local y = lg.getHeight() * 0.4 - SPRITE_DIMENSION/1.5
        draw_enemy(enemy, x, y)
        draw_enemy_status(enemy, x, y)
    end
end

function middle_screen.animate(enemy, type, duration, value)
    is_animating = true
    animation = { enemy = enemy, type = type, timer = 0, duration = duration, value = value}
end

function middle_screen.is_animating()
    return is_animating
end

return middle_screen