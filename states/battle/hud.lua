local fonts = require('fonts')

local hud = {}

local MARGIN_X = 20
local MARGIN_Y = 20
local BORDER_WIDTH = 128
local BORDER_HEIGHT = 96
local PADDING_X = 15
local PADDING_Y = 5
local GAP = 10
local INNER_WIDTH = BORDER_WIDTH - PADDING_X * 2
local STAT_Y = 25
local STAT_LINE_HEIGHT = 28
local BAR_Y = 48
local BAR_LINE_HEIGHT = STAT_LINE_HEIGHT
local BAR_HEIGHT = 4


local party = nil
local lg = love.graphics
local animation = false
local is_animating = false

local function draw_member_hud(member, index, x, y, animation)
    lg.setColor(0, 0, 0)
    lg.rectangle('fill', x, y, BORDER_WIDTH, BORDER_HEIGHT)

    lg.setColor(1, 1, 1)
    if not member:is_alive() then
        lg.setColor(0.25, 0.25, 0.25)
    end
    lg.rectangle('line', x, y, BORDER_WIDTH, BORDER_HEIGHT)

    lg.setFont(fonts.medium)
    lg.printf(member.name, x + PADDING_X, y + PADDING_Y, INNER_WIDTH, 'center')

    lg.setFont(fonts.xlarge_mono)
    local stats = {'HP' , 'MP'}
    for i, stat in ipairs(stats) do
        lg.printf(
            stat, 
            x + PADDING_X,
            y + PADDING_Y + STAT_Y + (i - 1) * STAT_LINE_HEIGHT,
            INNER_WIDTH,
            'left'
        )
    end

    local display_hp = math.max(0, member.current_hp)

    local values = { display_hp, member.current_mp }
    for i, value in ipairs(values) do
        if not member:is_alive() then
            lg.setColor(0.25, 0.25, 0.25)
        elseif i == 1 and value/member.max_hp <= 0.2 then
            lg.setColor(0.97, 0.28, 0.11)
        else
            lg.setColor(1, 1, 1)
        end
        lg.printf(
            value, 
            x + PADDING_X,
            y + PADDING_Y + STAT_Y + (i - 1) * STAT_LINE_HEIGHT,
            INNER_WIDTH,
            'right'
        )
    end

    for n = 1, 2 do
        lg.setColor(0.25, 0.25, 0.25)
        lg.rectangle(
            'line',
            x + PADDING_X,
            y + PADDING_Y + BAR_Y + (n - 1) * BAR_LINE_HEIGHT,
            INNER_WIDTH,
            BAR_HEIGHT
        )
        
        if n == 1 and animation and animation.type == 'damaged' then
            local progress = animation.timer / animation.duration
            local damage_bar = math.max(0, 
                INNER_WIDTH * ((animation.value + member.current_hp) / member.max_hp)
            )
            local opacity = 1 - progress
            
            lg.setColor(0.97, 0.28, 0.11, opacity)
            lg.rectangle(
                'fill',
                x + PADDING_X,
                y + PADDING_Y + BAR_Y,
                damage_bar,
                BAR_HEIGHT
            )
            lg.setColor(1, 1, 1, 1)
        end

        local bar_width
        lg.setColor(0.75, 0.75, 0.75)
        if not member:is_alive() then
            lg.setColor(0.25, 0.25, 0.25)
        end
        if n == 1 then
            local hp_ratio = (math.max(0, member.current_hp) / member.max_hp)
            bar_width = INNER_WIDTH * hp_ratio
        else
            local mp_ratio = member.current_mp / member.max_mp
            bar_width = INNER_WIDTH * mp_ratio
        end
        lg.rectangle(
            'fill',
            x + PADDING_X,
            y + PADDING_Y + BAR_Y + (n - 1) * BAR_LINE_HEIGHT,
            bar_width,
            BAR_HEIGHT
        )
    end
end

local function draw_member_animation(member, index, x, y)
    if animation.type == 'damaged' then
        local progress = animation.timer / animation.duration
        local offset_y = 15 * math.sin(progress * math.pi)
        draw_member_hud(member, index, x, offset_y + y, animation)
    end
end


---PUBLIC---


function hud.load(party_battlers)
    party = party_battlers
end

function hud.update(dt)
    if not is_animating then return end

    animation.timer = animation.timer + dt
    if animation.timer >= animation.duration then
        animation = nil
        is_animating = false
    end
end

function hud.draw()
    for i, member in ipairs(party) do
        local x = MARGIN_X + (i- 1) * (BORDER_WIDTH + GAP)
        local y = MARGIN_Y

        if animation and member == animation.member then
            draw_member_animation(member, i, x, y)
        else
            draw_member_hud(member, i, x, y)
        end
    end
end

function hud.is_animating()
    return is_animating
end

function hud.animate(type, duration, member, value)
    is_animating = true
    animation = { type = type, timer = 0, duration = duration, member = member, value = value }
end


return hud