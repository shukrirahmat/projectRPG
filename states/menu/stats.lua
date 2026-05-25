local input = require('input')
local fonts = require('fonts')
local Member_battler = require('entities.member_battler')
local utils = require('helpers.utils')
local action_data = require('data.action_data')
local passive_data = require('data.passive_data')

local Stats = {}

local Menu = nil
local Party = nil
local member_index = nil
local party_battlers = nil
local page = nil
local lg = love.graphics

function Stats.load(menu, party)
    Menu = menu
    Party = party
    member_index = 1
    page = 1

    party_battlers = {}
    for i, member in ipairs(Party.members) do
        table.insert(party_battlers, Member_battler.new(member))
    end
end

function Stats.draw(screen, profile)
    
    local margin_x = screen.margin_x
    local margin_y = screen.margin_y

    local body = {
        x = margin_x,
        y = margin_y + 10 + profile.height,
        width = lg.getWidth() - margin_x * 2,
        height = lg.getHeight() - margin_y * 2 - profile.height - 10,
        padding_x = 40,
        padding_y = 20,
        line_height = 28
    }

    Menu.draw_profile(Party.members[member_index], margin_x, margin_y, profile)
    lg.setColor(1, 1, 1)
    lg.rectangle('line', body.x, body.y, body.width, body.height)

    lg.setFont(fonts.medium)
    local font = lg.getFont()
    local page_text = 'Switch page'
    local page_text_width = font:getWidth(page_text) + 20
    lg.polygon(
        'fill',
        lg.getWidth() - margin_x,
        body.y - 20,
        lg.getWidth() - margin_x - 15,
        body.y - 30,
        lg.getWidth() - margin_x - 15,
        body.y - 10
    )
    lg.polygon(
        'fill',
        lg.getWidth() - margin_x - page_text_width - 15 * 2,
        body.y - 20,
        lg.getWidth() - margin_x - page_text_width - 15,
        body.y - 30,
        lg.getWidth() - margin_x - page_text_width - 15,
        body.y - 10
    )
    lg.printf(
        page_text, 
        lg.getWidth() - margin_x - 15 - page_text_width, 
        body.y - 30, 
        page_text_width, 
        'center'
    )
    
    local member_text = 'Change member'
    local member_text_width = font:getWidth(member_text) + 20
    lg.printf(member_text, margin_x + profile.width + 30, margin_y + 10, member_text_width, 'center')
    lg.polygon(
        'fill',
        margin_x + profile.width + 20,
        margin_y,
        margin_x + profile.width + 10,
        margin_y + 15,
        margin_x + profile.width + 30,
        margin_y + 15
    )
    lg.polygon(
        'fill',
        margin_x + profile.width + 20,
        margin_y + 15 * 2 + 10,
        margin_x + profile.width + 10,
        margin_y + 15 + 10,
        margin_x + profile.width + 30,
        margin_y + 15 + 10
    )

    if page == 1 then
        Stats.draw_attribute_page(body)
    elseif page == 2 then
        Stats.draw_equip_page(body)
    elseif page == 3 then
        Stats.draw_skill_page(body)
    end
end

function Stats.draw_skill_page(body)
    local text_width = body.width * 0.4 - body.padding_x * 2
    local member = Party.members[member_index]

    lg.setFont(fonts.bold)
    lg.printf('Skills', body.x + body.padding_x, body.y + body.padding_y, text_width, 'left')

    lg.setFont(fonts.large)
    local skill_y = body.y + body.padding_y + 50
    for i, skill in ipairs(member.skills) do
        local data = action_data[skill]
        lg.printf(data.name, body.x + body.padding_x, skill_y + (i - 1) * body.line_height , text_width, 'left')
        lg.printf(''..data.cost..'MP', body.x + body.padding_x, skill_y + (i - 1) * body.line_height , text_width, 'right')
    end

    local passive_y = body.y + body.padding_y + 50 + #member.skills * body.line_height
    for i, passive in ipairs(member.passive_skills) do
        local data = passive_data[passive]
        lg.printf(data.name, body.x + body.padding_x, passive_y + (i - 1) *body.line_height , text_width, 'left')
        lg.printf('PASSIVE', body.x + body.padding_x, passive_y + (i - 1) *body.line_height , text_width, 'right')
    end

    local row_2 = body.x + body.padding_x + body.width * 0.4
    lg.setFont(fonts.bold)
    lg.printf('Extra Skills', row_2, body.y + body.padding_y, text_width, 'left')
end

function Stats.draw_equip_page(body)
    local text_width = body.width * 0.4 - body.padding_x * 2
    local member = Party.members[member_index]

    lg.setFont(fonts.bold)
    lg.printf('Equipments', body.x + body.padding_x, body.y + body.padding_y, text_width, 'left')

    lg.setFont(fonts.large)
    local classes = {'SWORD', 'AXE', 'HAMMER', 'SPEAR', 'FIST', 'DAGGER', 'BOW', 'STAFF','HEAVY_ARMOR', 'LIGHT_ARMOR', 'ROBE', 'HELMET', 'HAT', 'SHIELD', 'BOOT'}
    local can_equip_text = 'Can equip: '
    for i, class in ipairs(classes) do
        if member.can_equip[class] then
            local text = class:gsub("_", " ")
            can_equip_text = ''..can_equip_text..' '..utils.capitalize(text:lower())..'s,'
        end
    end
    can_equip_text = can_equip_text:sub(1, -2)
    lg.printf(can_equip_text, body.x + body.padding_x, body.y + body.padding_y + 50, text_width * 2, 'left')

    local slots = { 'WEAPON:', 'ARMOR:', 'HEAD:', 'OTHER:'}
    local eq_y = body.y + body.padding_y + 120

    for i, slot in ipairs(slots) do
        lg.printf(slot, body.x + body.padding_x, eq_y + (i - 1)*(body.line_height + 5), text_width, 'left')

        local eq_name = "-----"
        if slot == 'WEAPON:' and member.weapon then
            eq_name = member.weapon.name
        elseif slot == 'ARMOR:' and member.armor then
            eq_name = member.armor.name
        elseif slot == 'HEAD:' and member.headgear then
            eq_name = member.headgear.name
        elseif slot == 'OTHER:' and member.other_eq then
            eq_name = member.other_eq.name
        end

        lg.printf(eq_name, body.x + body.padding_x, eq_y + (i - 1)*(body.line_height + 5), text_width, 'right')
    end
end

function Stats.draw_attribute_page(body)
    local text_width = body.width * 0.3 - body.padding_x * 2
    local member = party_battlers[member_index]

    lg.setFont(fonts.bold)
    lg.printf('Attributes', body.x + body.padding_x, body.y + body.padding_y, text_width, 'left')

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
        member:get_str(),
        member:get_vit(),
        member:get_agi(),
        '',
        member:get_atk(),
        member:get_def(),
        member.total_exp
    }
    lg.setFont(fonts.large)
    for i, stat in ipairs(stats_list) do
        lg.printf(stat, body.x + body.padding_x, body.y + body.padding_y + 50 + (i - 1) * body.line_height, text_width, 'left')
    end
    lg.setFont(fonts.large_mono)
    for i, value in ipairs(stats_value) do
        lg.printf(value, body.x + body.padding_x, body.y + body.padding_y + 50 + (i - 1) * body.line_height, text_width, 'right') 
    end

    local row_2 = body.x + body.padding_x + body.width * 0.3
    local row_3 = body.x + body.padding_x + body.width * 0.6
    lg.setFont(fonts.bold)
    lg.printf('Resistance', row_2, body.y + body.padding_y, text_width, 'left')

    local resistance_list = { 
        'FIRE', 'ICE', 'WIND', 'THUNDER', 'LIGHT', 'DARK', 'AURA', 'DRAIN', 'MANABURN',
        'BLIND', 'SEAL', 'STUN', 'POISON', 'WOUND', 'CURSE', 'SLEEP', 'CONFUSE', 'PARALYSIS',
        'DEATH', 'FRAIL', 'SLOW'
    }

    lg.setFont(fonts.large_mono)
    for i, res in ipairs(resistance_list) do
        if i > 11 then
            lg.printf(res, row_3, body.y + body.padding_y + 50 + (i - 12) * body.line_height, text_width, 'left')
            if member.immune[res] then
                lg.printf('Immune', row_3, body.y + body.padding_y + 50 + (i - 12) * body.line_height, text_width,                'right')
            elseif member.strong[res] then
                lg.printf('Strong', row_3, body.y + body.padding_y + 50 + (i - 12) * body.line_height, text_width,                'right')
            else
                lg.printf('---', row_3, body.y + body.padding_y + 50 + (i - 12) * body.line_height, text_width,                'right')
            end
        else
            lg.printf(res, row_2, body.y + body.padding_y + 50 + (i - 1) * body.line_height, text_width, 'left')
            if member.immune[res] then
                lg.printf('Immune', row_2, body.y + body.padding_y + 50 + (i - 1) * body.line_height, text_width,                'right')
            elseif member.strong[res] then
                lg.printf('Strong', row_2, body.y + body.padding_y + 50 + (i - 1) * body.line_height, text_width,                'right')
            else
                lg.printf('---', row_2, body.y + body.padding_y + 50 + (i - 1) * body.line_height, text_width,                'right')
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
    elseif key == input.left then
        Stats.prev_page()
    elseif key == input.right then
        Stats.next_page()
    end
end

function Stats.next_member()
    if member_index == #Party.members then
        member_index = 1
    else
        member_index = member_index + 1
    end
end

function Stats.prev_member()
    if member_index == 1 then
        member_index = #Party.members
    else
        member_index = member_index - 1
    end
end

function Stats.next_page()
    if page == 3 then
        page = 1
    else
        page = page + 1
    end
end

function Stats.prev_page()
    if page == 1 then
        page = 3
    else
        page = page - 1
    end
end

function Stats.back()
    Menu.switch_phase('main')
end

return Stats