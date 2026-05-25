local input = require('input')
local fonts = require('fonts')
local renderer = require('helpers.renderer')
local passive_data = require('data.passive_data')
local item_data = require('data.item_data')
local Member_battler = require('entities.member_battler')

local Equip = {}

local Menu = nil
local Party = nil
local member = nil
local slot_position = nil
local slot_list = nil
local lg = love.graphics
local phase = nil
local equip_position = nil
local equip_list = nil
local member_battler = nil

function Equip.load(menu, party, member_arg)
    Menu = menu
    Party = party
    member = member_arg
    slot_position = 1
    slot_list = {'WEAPON', 'ARMOR', 'HEAD', 'OTHER'}
    phase = 'choose_slot'

    member_battler = Member_battler.new(member)
end

function Equip.draw(screen)

    local sprite = member.sprite
    local sprite_dimension = 128
    lg.draw(sprite, screen.margin_x, screen.margin_y)
    lg.rectangle('line', screen.margin_x, screen.margin_y, sprite_dimension, sprite_dimension)

    local bl = {}
    ----BOTTOM LEFT---
    bl.x = screen.margin_x
    bl.y = screen.margin_y + sprite_dimension
    bl.width = screen.width * 0.25
    bl.height = screen.height - sprite_dimension
    bl.line_height = 30
    bl.padding_x = 20
    bl.padding_y = 20
    lg.setColor(0, 0, 0)
    lg.rectangle('fill', bl.x, bl.y, bl.width, bl.height)
    lg.setColor(1, 1, 1)
    lg.rectangle('line', bl.x, bl.y, bl.width, bl.height)

    lg.setFont(fonts.bold)
    lg.printf(member.name, bl.x + bl.padding_x, bl.y + bl.padding_y, bl.width - bl.padding_x * 2, 'left')
    lg.printf('LVL'..member.lvl..'', bl.x + bl.padding_x, bl.y + bl.padding_y, bl.width - bl.padding_x * 2 - 10, 'right')

    lg.setFont(fonts.large_mono)
    local stat_list = {'ATK', 'DEF', '', 'STR', 'VIT', 'AGI'}
    local stat_value = {
        member_battler:get_atk(), 
        member_battler:get_def(), 
        '', 
        member_battler:get_str(), 
        member_battler:get_vit(), 
        member_battler:get_agi()
    }

    for i, stat in ipairs(stat_list) do
        local y = bl.y + bl.padding_y + 80 + (i - 1) * bl.line_height
        lg.printf(stat, bl.x + bl.padding_x, y, (bl.width - bl.padding_x * 2) * 0.55, 'left')
        lg.printf(stat_value[i], bl.x + bl.padding_x, y, (bl.width - bl.padding_x * 2) * 0.55, 'right')
    end

    if phase == 'choose_equip' and #equip_list > 0 then
        local preview_stats = Equip.get_preview_stats(equip_list[equip_position].equipment)  
        for i, new_stat in ipairs(preview_stats) do
            if new_stat ~= stat_value[i] then
                local x = bl.x + bl.padding_x + (bl.width - bl.padding_x * 2) * 0.6
                local y = bl.y + bl.padding_y + 80 + (i - 1) * bl.line_height
                
                lg.polygon('fill', x, y + 7, x, y + 17, x + 10, y + 12)
                
                if new_stat > stat_value[i] then
                    lg.setColor(0.1, 0.9, 0.1)
                elseif new_stat < stat_value[i] then
                    lg.setColor(1, 0.1, 0.1)
                end
                
                lg.printf(new_stat, x + 20, y, (bl.width - bl.padding_x * 2) * 0.4 - 10, 'left')
                lg.setColor(1, 1, 1)
            end
        end
    end


    local tr = {}
----TOP RIGHT----
    tr.x = screen.margin_x + bl.width + 20
    tr.y = screen.margin_y
    tr.width = screen.width - bl.width - 20
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

    local prop_list = {'weapon', 'armor', 'headgear', 'other_eq'}
    if member[prop_list[slot_position]] then
        Equip.draw_equipment_description(t_desc, member[prop_list[slot_position]])
    end

    if phase == 'choose_equip' then

        lg.setFont(fonts.large)
        local br = {}
        ----BOTTOM RIGHT----
        br.x = tr.x
        br.y = screen.margin_y + tr.height + 20
        br.width = tr.width
        br.height = tr.height
        br.line_height = tr.line_height
        br.padding_x = tr.padding_x
        br.padding_y = tr.padding_y
        br.hz_line_y = tr.hz_line_y + tr.height + 20
        lg.rectangle('line', br.x, br.y, br.width, br.height)
        lg.line(br.x + br.width * 0.5, br.y, br.x + br.width * 0.5, br.y + br.height)
        lg.line(br.x + br.width * 0.5, br.hz_line_y, br.x + br.width, br.hz_line_y)

        local text_x = br.x + br.padding_x
        local text_y = br.y + br.padding_y + renderer.center_text(br.line_height)
        local text_width = (br.width * 0.5) - br.padding_x - 20
        if #equip_list < 1 then
            lg.printf('No equipment available', text_x, text_y, text_width, 'left')
        else
            for i, eq in ipairs(equip_list) do
                local text;
                local text_y = text_y + (i - 1) * br.line_height
                if eq.equipment.type == 'UNEQUIP' then
                    text = 'Unequip'
                    lg.printf(text, text_x, text_y, text_width, 'left')
                else
                    text = eq.equipment.name
                    lg.printf(text, text_x, text_y, text_width, 'left')
                    lg.printf('x'..eq.amount..'', text_x, text_y, text_width, 'right')
                end

                if equip_position == i then
                    renderer.draw_option_cursor(text_x - 30, text_y, tr.line_height - 5)
                end
            end
        end

        local b_desc = {}
        b_desc.x = br.x + br.width * 0.5 + 20
        b_desc.y = br.y + br.padding_y
        b_desc.width = br.width * 0.5 - 40
        b_desc.passive_y = br.hz_line_y + br.padding_y

        if #equip_list > 0 and equip_list[equip_position].equipment.type ~= 'UNEQUIP' then
            Equip.draw_equipment_description(b_desc, equip_list[equip_position].equipment)
        end
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
    if phase == 'choose_slot' then
        if key == input.back then
            Equip.exit()
        elseif key == input.up then
            Equip.slot_up()
        elseif key == input.down then
            Equip.slot_down()
        elseif key == input.confirm then
            Equip.load_equipment_choices()
            equip_position = 1
            phase = 'choose_equip'
        end
    elseif phase == 'choose_equip' then
        if key == input.back then
            Equip.back()
        elseif key == input.up then
            Equip.equipment_up()
        elseif key == input.down then
            Equip.equipment_down()
        elseif key == input.confirm then
            Equip.switch_equipment()
        end
    end
end

function Equip.slot_up()
    if slot_position > 1 then
        slot_position = slot_position - 1
    end
end

function Equip.slot_down()
    if slot_position < #slot_list then
        slot_position = slot_position + 1
    end
end

function Equip.exit()
    Menu.switch_phase('choose_member')
end

function Equip.load_equipment_choices()
    equip_list = {}
    local prop_list = {'weapon', 'armor', 'headgear', 'other_eq'}
    local type_list = {'WEAPON', 'ARMOR', 'HEADGEAR', 'OTHER_EQ'}

    local current_slot = slot_list[slot_position]
    if member[prop_list[slot_position]] then
        table.insert(equip_list, {equipment = {type = 'UNEQUIP'}})
    end
    for item_ref, amount in pairs(Party.items) do
        local equipment = item_data[item_ref]
        if equipment.type == type_list[slot_position] and member.can_equip[equipment.class] then
            table.insert(equip_list, {equipment = equipment, amount = amount})
        end
    end
end

function Equip.equipment_up()
    if equip_position > 1 then
        equip_position = equip_position - 1
    end
end

function Equip.equipment_down()
    if equip_position < #equip_list then
        equip_position = equip_position + 1
    end
end

function Equip.back()
    phase = 'choose_slot'
end

function Equip.switch_equipment()
    if #equip_list < 1 then return end

    local prop_list = {'weapon', 'armor', 'headgear', 'other_eq'}

    if equip_list[equip_position].equipment.type == 'UNEQUIP' then
        Party.manage_item(member[prop_list[slot_position]].ref, 1)
        member[prop_list[slot_position]] = nil
    else
        if member[prop_list[slot_position]] then
            Party.manage_item(member[prop_list[slot_position]].ref, 1)
            member[prop_list[slot_position]] = nil
        end
        Party.manage_item(equip_list[equip_position].equipment.ref, -1)
        member[prop_list[slot_position]] = equip_list[equip_position].equipment
    end

    member_battler = Member_battler.new(member)
    phase = 'choose_slot'
end

function Equip.get_preview_stats(equipment)
    local prop_list = {'weapon', 'armor', 'headgear', 'other_eq'}
    local current = member[prop_list[slot_position]]

    if equipment.type == 'UNEQUIP' then
        member[prop_list[slot_position]] = nil
    else
        member[prop_list[slot_position]] = equipment
    end

    local prev_battler = Member_battler.new(member)
    local prev_stats = {
        prev_battler:get_atk(), 
        prev_battler:get_def(), 
        '', 
        prev_battler:get_str(), 
        prev_battler:get_vit(), 
        prev_battler:get_agi()
    }
    member[prop_list[slot_position]] = current
    member_battler = Member_battler.new(member)

    return prev_stats
end


return Equip