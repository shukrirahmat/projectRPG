local input = require('input')
local fonts = require('fonts')
local member_battler = require('entities.member_battler')

local Stats = {}

local Menu = nil
local Party = nil
local member_index = nil
local party_battlers = nil
local page = nil

local margin_x = nil
local margin_y = nil
local body_x = nil
local body_y = nil
local body_height = nil
local body_width = nil
local padding_x = nil
local padding_y = nil
local line_height = nil

local lg = love.graphics

function Stats.load(menu, party, profile_height)
    Menu = menu
    Party = party
    member_index = 1
    page = 1

    margin_x = menu.MARGIN_X
    margin_y = menu.MARGIN_Y
    body_x = margin_x
    body_y = margin_y + 10 + profile_height
    body_width = lg.getWidth() - margin_x * 2
    body_height = lg.getHeight() - margin_y * 2 - profile_height - 10
    padding_x = 40
    padding_y = 20
    line_height = 28

    party_battlers = {}
    for i, member in ipairs(Party.members) do
        table.insert(party_battlers, member_battler.new(member))
    end
end

function Stats.draw()
    Menu.draw_profile(Party.members[member_index], Menu.MARGIN_X, Menu.MARGIN_Y)
    lg.setColor(1, 1, 1)
    lg.rectangle('line', body_x, body_y, body_width, body_height)

    local text_width = body_width * 0.3 - padding_x * 2

    if page == 1 then
        Stats.draw_main_attributes()
    end
end

function Stats.draw_main_attributes()
    local text_width = body_width * 0.3 - padding_x * 2
    local member = party_battlers[member_index]

    lg.setFont(fonts.bold)
    lg.printf('Attributes', body_x + padding_x, body_y + padding_y, text_width, 'left')

    local stats_list = {
        'Max HP',
        'Max MP',
        'Strength',
        'Vitality',
        'Agility',
        '',
        'Attack',
        'Defense',
        'Exp',
    }
    local stats_value = {
        member.max_hp,
        member.max_mp,
        member.str,
        member.vit,
        member.agi,
        '',
        member:get_atk(),
        member:get_def(),
        member.total_exp
    }
    lg.setFont(fonts.large)
    for i, stat in ipairs(stats_list) do
        lg.printf(stat, body_x + padding_x, body_y + padding_y + 50 + (i - 1) * line_height, text_width, 'left')
    end
    lg.setFont(fonts.large_mono)
    for i, value in ipairs(stats_value) do
        lg.printf(value, body_x + padding_x, body_y + padding_y + 50 + (i - 1) * line_height, text_width, 'right') 
    end

    local row_2 = body_x + padding_x + body_width * 0.3
    local row_3 = body_x + padding_x + body_width * 0.6
    lg.setFont(fonts.bold)
    lg.printf('Resistance', row_2, body_y + padding_y, text_width, 'left')

    local resistance_list = { 
        'FIRE', 'ICE', 'WIND', 'THUNDER', 'LIGHT', 'DARK', 'AURA', 'DRAIN', 'MANABURN',
        'BLIND', 'SEAL', 'STUN', 'POISON', 'WOUND', 'CURSE', 'SLEEP', 'CONFUSE', 'PARALYSIS',
        'DEATH', 'FRAIL', 'SLOW'
    }

    lg.setFont(fonts.large_mono)
    for i, res in ipairs(resistance_list) do
        if i > 11 then
            lg.printf(res, row_3, body_y + padding_y + 50 + (i - 12) * line_height, text_width, 'left')
            if member.immune[res] then
                lg.printf('Immune', row_3, body_y + padding_y + 50 + (i - 12) * line_height, text_width,                'right')
            elseif member.strong[res] then
                lg.printf('Strong', row_3, body_y + padding_y + 50 + (i - 12) * line_height, text_width,                'right')
            else
                lg.printf('---', row_3, body_y + padding_y + 50 + (i - 12) * line_height, text_width,                'right')
            end
        else
            lg.printf(res, row_2, body_y + padding_y + 50 + (i - 1) * line_height, text_width, 'left')
            if member.immune[res] then
                lg.printf('Immune', row_2, body_y + padding_y + 50 + (i - 1) * line_height, text_width,                'right')
            elseif member.strong[res] then
                lg.printf('Strong', row_2, body_y + padding_y + 50 + (i - 1) * line_height, text_width,                'right')
            else
                lg.printf('---', row_2, body_y + padding_y + 50 + (i - 1) * line_height, text_width,                'right')
            end
        end
    end


end

function Stats.keypressed(key)
    if key == input.down then
        Stats.next_member()
    elseif key == input.up then
        Stats.prev_member()
    elseif key == input.back then
        Stats.back()
    end
end

function Stats.next_member()
    if member_index < #Party.members then
        member_index = member_index + 1
    end
end

function Stats.prev_member()
    if member_index > 1 then
        member_index = member_index - 1
    end
end

function Stats.back()
    Menu.switch_phase('main')
end

return Stats