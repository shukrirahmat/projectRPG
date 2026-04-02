local middle_screen = require('states.battle.middle_screen')
local hud = require('states.battle.hud')
local logger = require('states.battle.logger')
local loop = require('states.battle.loop')
local menu = require('states.battle.menu')
local battler = require('systems.battler')
local action = require('systems.action')
local transitions = require('systems.transitions')
local action_data = require('data.action_data')
local enemy_data = require('data.enemy_data')
local enemy_action = require('data.enemy_action')
local fonts = require('fonts')
local utils = require('helpers.utils')

local battle = {}

local party_battlers = {}
local enemy_battlers = {}
local phase = nil


local function draw_test_details()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.small)
    for i, enemy in ipairs(enemy_battlers) do
        local hp = ''..enemy.current_hp..'/'..enemy.max_hp..''
        local stat = 'ATK: '..enemy:get_atk()..' DEF: '..enemy:get_def()..'  SPD: '..enemy:get_spd()..''
        love.graphics.printf(
            ''..hp..' '..stat..'',
            love.graphics.getWidth() / 2,
            20 + (i - 1) * 20,
            love.graphics.getWidth() / 2 - 40,
            'right'
        )
    end
end

local function get_random_target(group)
    local available_targets = {}

    for i, target in ipairs(group) do
        if target:is_alive() then
            table.insert(available_targets, target)
        end
    end

    local selected = nil
    local i = 1

    while not selected do
        if i == #available_targets then
            selected = available_targets[i]
        else
            local chance = math.random(1, 10)
            if chance < 5 then
                i = i + 1
            else
                selected =  available_targets[i]
            end
        end
    end

    return selected
end

local function set_party_battlers(party)
    for i, member in ipairs(party) do
        local new_battler = battler.new_member(member)
        table.insert(party_battlers, new_battler)
    end
end

local function set_enemy_battlers(enemies)
    for k, v in pairs(enemies) do
        for i = 1, v do
            local name = utils.capitalize(k)
            if v > 1 then
                name = ''..name..' #'..i..''
            end
            local new_battler = battler.new_enemy(enemy_data[k], name)
            table.insert(enemy_battlers, new_battler)
        end
    end
end

local function intro_update(dt)
    transitions.update(dt)
    logger.update(dt)
    if not logger.is_active() and not transitions.is_active() then
        battle.enter_menu()
    end
end


---PUBLIC---


function battle.load(game, var)
    set_party_battlers(game.party.get_members())
    set_enemy_battlers(var.enemies)

    hud.load(party_battlers)
    middle_screen.load(enemy_battlers)

    phase = 'intro'

    transitions.load('fade_in', 0.5)
    logger.load('Enemy encountered!')
end

function battle.update(dt)
    if phase == 'intro' then
        intro_update(dt)
    elseif phase == 'battle_running' then
        loop.update(dt)
    end
end

function battle.draw()
    hud.draw()
    middle_screen.draw()

    --------------
    draw_test_details()

    if menu.is_active() then
        menu.draw()
    end

    if logger.is_active() then
        logger.draw()
    end

    if transitions.is_active() then
        transitions.draw()
    end
end

function battle.keypressed(key)
    if phase == 'menu_input' then
        menu.keypressed(key)
    end
end

function battle.enter_menu()
    menu.load(battle, party_battlers, enemy_battlers)
    phase = 'menu_input'
end

function battle.set_action(ref, user, targets)
    local data = action_data[ref]
    local new_action = action.new(ref, data, user, targets)
    user.current_action = new_action
end

function battle.run_action()

    local action_queue = {}

    for i, member in ipairs(party_battlers) do
        if not member:is_alive() then
            goto continue
        end

        if member.current_action then
            local to_send = member.current_action
            member.current_action = nil
            table.insert(action_queue, to_send)
        else
            local data = action_data['empty_action']
            local empty_action = action.new('empty_action', data, member)
            table.insert(action_queue, empty_action)
        end

        ::continue::
    end

    for i, enemy in ipairs(enemy_battlers) do
        if not enemy:is_alive() then
            goto continue
        end

        if enemy:cannot_act() then
            local data = action_data['empty_action']
            local empty_action = action.new('empty_action', data, enemy)
            table.insert(action_queue, empty_action)
            goto continue
        end

        local action_ref = enemy_action.get(enemy)
        local data = action_data[action_ref]

        local group = party_battlers
        if data.aim == 'allies' then
            group = enemy_battlers
        end

        local to_send
        if data.scope == 'all' then
            to_send = action.new(action_ref, data, enemy, {unpack(group)})
        elseif data.scope == 'self' then
            to_send = action.new(action_ref, data, enemy, enemy)
        elseif data.scope == 'single' then
            local target = get_random_target(group)
            to_send = action.new(action_ref, data, enemy, {target})
        end
        table.insert(action_queue, to_send)


        ::continue::
    end

    loop.load(battle, action_queue, logger)
    phase = 'battle_running'
end

return battle