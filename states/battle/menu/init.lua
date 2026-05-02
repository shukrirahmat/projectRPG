local main_menu = require('states.battle.menu.main_menu')
local member_menu = require('states.battle.menu.member_menu')
local target_menu = require('states.battle.menu.target_menu')
local skill_menu = require('states.battle.menu.skill_menu')
local item_menu = require('states.battle.menu.item_menu')
local Action = require('entities.action')
local action_data = require('data.action_data')

local menu = {}

local battle = nil
local is_active = false
local phase = nil
local party_manager = nil

menu.party = nil
menu.enemies = nil
menu.MARGIN_X = 20
menu.MARGIN_Y = 20
menu.PADDING_X = 20
menu.PADDING_Y = 10
menu.GAP = 10
menu.FULL_HEIGHT = 140
menu.OPTION_HEIGHT = (menu.FULL_HEIGHT - menu.PADDING_Y * 2) / 4
menu.FULL_WIDTH = nil
menu.party_manager = nil
menu.timer = 0
menu.timer_end = 0.2


function menu.load(parent_battle, _party_manager, party_battlers, enemy_battlers)

    battle = parent_battle
    menu.FULL_WIDTH = love.graphics.getWidth() - menu.MARGIN_X * 2

    menu.party = party_battlers
    menu.enemies = enemy_battlers
    is_active = true

    party_manager = _party_manager
    phase = 'main_menu'
    main_menu.load(menu)
    
    menu.previous_member = nil
    menu.current_member = nil
end

function menu.update(dt)
    if not is_active then return end
    menu.timer = menu.timer + dt
    if menu.timer >= menu.timer_end then
        menu.timer = menu.timer_end
    end
end

function menu.draw()
    if main_menu.is_active() then main_menu.draw() end
    if member_menu.is_active() then member_menu.draw() end
    if target_menu.is_active() then target_menu.draw() end
    if skill_menu.is_active() then skill_menu.draw() end
    if item_menu.is_active() then item_menu.draw() end
end

function menu.keypressed(key)
    if phase == 'main_menu' then main_menu.keypressed(key)
    elseif phase == 'member_menu' then member_menu.keypressed(key)
    elseif phase == 'target_menu' then target_menu.keypressed(key)
    elseif phase == 'skill_menu' then skill_menu.keypressed(key)
    elseif phase == 'item_menu' then item_menu.keypressed(key) end
end

function menu.is_active()
    return is_active
end

function menu.previous_party_member(index)

    local found = false
    local member_index = nil

    for i = index, 0, -1 do
        if i <= 0 then
            break
        elseif menu.party[i]:is_alive() and not menu.party[i]:cannot_act() then
            member_index = i
            found = true
            break
        end
    end

    member_menu.close()

    if found then
        phase = 'member_menu'
        member_menu.load(menu, member_index)
        
        menu.timer = 0
        menu.previous_member = menu.current_member
        menu.current_member = menu.party[member_index]
    else
        phase = 'main_menu'
        main_menu.load(menu)
        
        menu.timer = 0
        menu.previous_member = menu.current_member
        menu.current_member = nil
    end
end

function menu.next_party_member(index)

    local found = false
    local member_index = nil

    for i = index, #menu.party do
        if menu.party[i]:is_alive() and not menu.party[i]:cannot_act() then
            member_index = i
            found = true
            break
        end
    end

    member_menu.close()

    if found then
        phase = 'member_menu'
        member_menu.load(menu, member_index)
        
        menu.timer = 0
        menu.previous_member = menu.current_member
        menu.current_member = menu.party[member_index]
    else
        is_active = false
        battle.run_action()
    end
end

function menu.open_target_menu(action_ref, targets, prev_menu, member, member_index)
    phase = 'target_menu'
    target_menu.load(menu, action_ref, targets, prev_menu, member, member_index)
end

function menu.open_skill_menu(prev_menu, member, member_index)
    phase = 'skill_menu'
    skill_menu.load(menu, prev_menu, member, member_index)
end

function menu.open_item_menu(prev_menu, member, member_index)
    phase = 'item_menu'
    item_menu.load(menu, prev_menu, member, member_index)
end

function menu.cancel(prev_menu)
    if prev_menu == member_menu then
        phase = 'member_menu'
    elseif prev_menu == skill_menu then
        skill_menu.stop_targeting()
        phase = 'skill_menu'
    elseif prev_menu == item_menu then
        item_menu.stop_targeting()
        phase = 'item_menu'
    end
end

function menu.set_action(ref, user, targets)
    local data = action_data[ref]
    local new_action = Action.new(ref, data, user, targets)
    user.current_action = new_action
end

function menu.get_alive_targets(group)
    local alive = {}
    for i, target in ipairs(group) do
        if target:is_alive() then
            table.insert(alive, target)
        end
    end

    return alive
end

function menu.get_alive_targets_exclusive(user, group)
    local alive = {}
    for i, target in ipairs(group) do
        if target:is_alive() and target ~= user then
            table.insert(alive, target)
        end
    end

    return alive
end

function menu.get_dead_targets(group)
    local dead = {}
    for i, target in ipairs(group) do
        if target.is_dead then
            table.insert(dead, target)
        end
    end

    return dead
end

function menu.get_party_items()
    return party_manager.get_items()
end

function menu.add_item(item)
    party_manager.manage_item(item, 1)
end

function menu.remove_item(item)
    party_manager.manage_item(item, -1)
end

function menu.flee_battle()
    battle.flee()
end

return menu