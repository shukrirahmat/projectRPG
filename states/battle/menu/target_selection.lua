local action_data = require('data.action_data')
local input = require('input')
local fonts = require('fonts')

local target_selection = {}

local lg = love.graphics

local function clear_target()
    target_selection.middle_screen.targeted = nil
    target_selection.hud.clear_target()
end

local function hover_target()
    local battler = target_selection.list[target_selection.position]
    if battler.is_party_member then
        target_selection.hud.target(battler)
        target_selection.middle_screen.targeted = nil
    else
        target_selection.middle_screen.targeted = battler
        target_selection.hud.clear_target()
    end
end

local function move_left()
    if target_selection.position > 1 then
        target_selection.position = target_selection.position - 1
        hover_target()
    end
end

local function move_right()
    if target_selection.position < #target_selection.list then
        target_selection.position = target_selection.position + 1
        hover_target()
    end
end

local function confirm()
    local target = target_selection.list[target_selection.position]
    target_selection.is_active = nil
    clear_target()
    target_selection.prev_menu.close()
    target_selection.menu.set_action(target_selection.action_ref, target_selection.member, {target})

    if action_data[target_selection.action_ref].type == 'Item' then
        local item = target_selection.action_ref
        target_selection.member.using_item = item
        target_selection.menu.remove_item(item)
    end

    target_selection.menu.next_party_member(target_selection.member_index + 1)
end

local function back()
    target_selection.is_active = false
    target_selection.menu.cancel(target_selection.prev_menu)
    clear_target()
end

local function target_exists()
    return #target_selection.list > 0
end

function target_selection.load(menu, action_ref, targets, prev_menu, member, member_index)
    target_selection.menu = menu
    target_selection.hud = menu.hud
    target_selection.middle_screen = menu.middle_screen
    target_selection.list = targets
    target_selection.prev_menu = prev_menu
    target_selection.member = member
    target_selection.member_index = member_index
    target_selection.action_ref = action_ref

    target_selection.position = 1
    target_selection.is_active = true

    if target_exists() then
        hover_target()
    end
end

function target_selection.draw()
    if target_exists() then return end

    local width = (target_selection.menu.FULL_WIDTH - target_selection.menu.GAP * 2) * 0.5
    local height = (target_selection.menu.FULL_HEIGHT / 2)
    local x = lg.getWidth() / 2 - width * 0.5
    local y = lg.getHeight() - target_selection.menu.FULL_HEIGHT - target_selection.menu.MARGIN_Y - height/2

    lg.setColor(0,0,0)
    lg.rectangle('fill', x, y, width, height)
    lg.setColor(1,1,1)
    lg.rectangle('line', x, y, width, height)
    
    lg.setFont(fonts.large)
    lg.printf( 'There is no available target.', 
        x + target_selection.menu.PADDING_X, 
        y + target_selection.menu.PADDING_Y,
        width
    )
end

function target_selection.keypressed(key)
    if target_exists() and key == input.left then
        move_left()
    elseif target_exists() and key == input.right then
        move_right()
    elseif target_exists() and key == input.confirm then
        confirm()
    elseif key == input.back then
        back()
    end
end

return target_selection