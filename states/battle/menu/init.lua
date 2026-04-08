local main_menu = require('states.battle.menu.main_menu')
local member_menu = require('states.battle.menu.member_menu')
local target_menu = require('states.battle.menu.target_menu')
local skill_menu = require('states.battle.menu.skill_menu')
local action = require('entities.action')
local action_data = require('data.action_data')

local menu = {}

local battle = nil
local is_active = false
local phase = nil

menu.party = nil
menu.enemies = nil
menu.MARGIN_X = 20
menu.MARGIN_Y = 20
menu.PADDING_X = 20
menu.PADDING_Y = 10
menu.GAP = 10
menu.FULL_HEIGHT = 180
menu.OPTION_HEIGHT = (menu.FULL_HEIGHT - menu.PADDING_Y * 2) / 4
menu.FULL_WIDTH = nil


function menu.load(parent_battle, party_battlers, enemy_battlers)

    battle = parent_battle
    menu.FULL_WIDTH = love.graphics.getWidth() - menu.MARGIN_X * 2

    menu.party = party_battlers
    menu.enemies = enemy_battlers
    is_active = true

    phase = 'main_menu'
    main_menu.load(menu)
end

function menu.draw()
    if main_menu.is_active() then main_menu.draw() end
    if member_menu.is_active() then member_menu.draw() end
    if target_menu.is_active() then target_menu.draw() end
    if skill_menu.is_active() then skill_menu.draw() end
end

function menu.keypressed(key)
    if phase == 'main_menu' then main_menu.keypressed(key)
    elseif phase == 'member_menu' then member_menu.keypressed(key)
    elseif phase == 'target_menu' then target_menu.keypressed(key)
    elseif phase == 'skill_menu' then skill_menu.keypressed(key) end
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
    else
        phase = 'main_menu'
        main_menu.load(menu)
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

function menu.cancel(prev_menu)
    if prev_menu == member_menu then
        phase = 'member_menu'
    elseif prev_menu == skill_menu then
        phase = 'skill_menu'
    end
end

function menu.set_action(ref, user, targets)
    local data = action_data[ref]
    local new_action = action.new(ref, data, user, targets)
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

return menu