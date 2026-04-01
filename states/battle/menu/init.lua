local main_menu = require('states.battle.menu.main_menu')
local member_menu = require('states.battle.menu.member_menu')

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
end

function menu.keypressed(key)
    if phase == 'main_menu' then main_menu.keypressed(key)
    elseif phase == 'member_menu' then member_menu.keypressed(key) end
end

function menu.is_active()
    return is_active
end

function menu.previous_party_member(index)
    
    local found = false
    local member_index = nil
    
    for i = index, 0, -1 do
        if index <= 0 then
            break
        elseif menu.party[i]:is_alive() and not menu.party[i]:cannot_act() then
            member_index = i
            found = true
            break
        end
    end
    
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
    
    if found then
        phase = 'member_menu'
        member_menu.load(menu, member_index)
    else
        is_active = false
        battle.run_action()
    end
end

function menu.choose_action(ref, user, targets)
    battle.set_action(ref, user, targets)
end

return menu