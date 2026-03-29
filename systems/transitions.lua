local transition = {}

local is_active = false
local timer = 0
local speed = nil
local type = nil
local window_width = nil
local window_height = nil
local callback = nil

local function draw_battle_transition()

    local progress = timer / speed

    love.graphics.setColor(0, 0, 0)
    love.graphics.polygon(
        'fill',
        0,
        0,
        0,
        progress  * window_width,
        progress * window_width,
        0
    )

    love.graphics.polygon(
        'fill',
        window_width,
        0,
        window_width - progress  * window_width,
        0,
        window_width,
        progress * window_width
    )

    love.graphics.polygon(
        'fill',
        0,
        window_height,
        0,
        window_height - progress * window_width,
        progress * window_width,
        window_height
    )

    love.graphics.polygon(
        'fill',
        window_width,
        window_height,
        window_width - progress * window_width,
        window_height,
        window_width,
        window_height - progress * window_width
    )
end

local function draw_fade_out()
    local opacity = timer / speed
    love.graphics.setColor(0, 0, 0, opacity)
    love.graphics.rectangle(
        'fill',
        0,
        0,
        window_width,
        window_height
    )
    love.graphics.setColor(1, 1, 1, 1)
end

local function draw_fade_in()
    local opacity = 1 - timer / speed;
    love.graphics.setColor(0, 0, 0, opacity)
    love.graphics.rectangle(
        'fill',
        0,
        0,
        window_width,
        window_height
    )
    love.graphics.setColor(1, 1, 1, 1)
end

function transition.load(_type, _speed, _callback)

    window_width = love.graphics.getWidth()
    window_height = love.graphics.getHeight()

    is_active = true;
    timer = 0
    type = _type
    speed = _speed
    callback = _callback or function() end
end

function transition.is_active(dt)
    return is_active
end

function transition.update(dt)
    if not is_active then return end

    timer = timer + dt
    if timer >= speed then
        is_active = false
        callback()
    end
end

function transition.draw()
    if not is_active then return end

    if type == 'fade_out' then
        draw_fade_out()
    elseif type == 'fade_in' then
        draw_fade_in()
    elseif type == 'battle' then
        draw_battle_transition()
    end
end

return transition