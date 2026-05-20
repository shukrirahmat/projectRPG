local input = require('input')
local fonts = require('fonts')
local renderer = require('helpers.renderer')
local passive_data = require('data.passive_data')

local Equip = {}

local Menu = nil
local member = nil
local slot_position = nil
local slot_list = {}
local lg = love.graphics

function Equip.load(menu, member_arg)
    Menu = menu
    member = member_arg
    slot_position = 1
    slot_list = {'WEAPON', 'ARMOR', 'HEAD', 'OTHER'}
end

function Equip.draw(screen)

    local tr = {}
    ----TOP RIGHT----
    tr.x = screen.margin_x + screen.width * 0.3
    tr.y = screen.margin_y
    tr.width = screen.width - screen.width * 0.3
    tr.height = screen.height *  0.5 - 10
    tr.line_height = 30
    tr.padding_x = 45
    tr.padding_y = 15
    tr.hz_line_y = tr.y + tr.padding_y + 40
    lg.rectangle('line', tr.x, tr.y, tr.width, tr.height)
    lg.line(tr.x + tr.width * 0.5, tr.y, tr.x + tr.width * 0.5, tr.y + tr.height)
    lg.line(tr.x + tr.width * 0.5, tr.hz_line_y, tr.x + tr.width, tr.hz_line_y)

    for i, slot in ipairs(slot_list) do
        lg.setFont(fonts.large_mono)
        local text_x = tr.x + tr.padding_x
        local text_y = tr.y + tr.padding_y + (i - 1) * tr.line_height + renderer.center_text(tr.line_height)
        local text_width = (tr.width * 0.5) - tr.padding_x - 20
        lg.printf(slot, text_x, text_y, text_width, 'left')

        if slot_position == i then
            renderer.draw_option_cursor(text_x - 30, text_y, tr.line_height - 5)
        end

        lg.setFont(fonts.large)
        local eq_name = '-----'

        if slot == 'WEAPON' and member.weapon then
            eq_name = member.weapon.name
        elseif slot == 'ARMOR' and member.armor then
            eq_name = member.armor.name
        elseif slot == 'HEAD' and member.headgear then
            eq_name = member.headgear.name
        elseif slot == 'OTHER' and member.other_eq then
            eq_name = member.other_eq.name
        end

        lg.printf(eq_name, text_x + text_width * 0.35, text_y, text_width * 0.65, 'left')
    end

    local t_desc = {}

    t_desc.x = tr.x + tr.width * 0.5 + 20
    t_desc.y = tr.y + tr.padding_y
    t_desc.width = tr.width * 0.5 - 40
    t_desc.passive_y = tr.hz_line_y + tr.padding_y

    lg.setFont(fonts.large_mono)
    if slot_list[slot_position] == 'WEAPON' and member.weapon then
        Equip.draw_equipment_description(t_desc, member.weapon)
    elseif slot_list[slot_position] == 'ARMOR' and member.armor then
        Equip.draw_equipment_description(t_desc, member.armor)
    elseif slot_list[slot_position] == 'HEAD' and member.headgear then
        Equip.draw_equipment_description(t_desc, member.headgear)
    elseif slot_list[slot_position] == 'OTHER' and member.other_eq then
        Equip.draw_equipment_description(t_desc, member.other_eq)
    end
end

function Equip.draw_equipment_description(desc, equipment)

    local order = {'atk', 'def', 'str', 'vit', 'agi'}
    local i = 1
    for _, key in ipairs(order) do
        if equipment.stat[key] then
            local text = ''..key:upper()..' +'..equipment.stat[key]..''
            lg.printf(text, desc.x + (i - 1) * 110, desc.y, desc.width, 'left')
            i = i + 1
        end
    end
    
    if equipment.passives then
        for i, passive in ipairs(equipment.passives) do
            lg.setFont(fonts.large)
            local data = passive_data[passive]
            local y = desc.passive_y + (i - 1) * 80
            lg.printf(data.name, desc.x, y, desc.width, 'left')
            lg.setFont(fonts.medium)
            lg.printf(data.desc, desc.x + 20, y + 25, desc.width - 20, 'left')
        end
    end
    lg.setFont(fonts.large)
end

function Equip.keypressed(key)
    if key == input.back then
        Equip.exit()
    elseif key == input.up then
        Equip.move_up()
    elseif key == input.down then
        Equip.move_down()
    end
end

function Equip.move_up()
    if slot_position > 1 then
        slot_position = slot_position - 1
    end
end

function Equip.move_down()
    if slot_position < #slot_list then
        slot_position = slot_position + 1
    end
end

function Equip.exit()
    Menu.switch_phase('choose_member')
end

return Equip