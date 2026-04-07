local middle_screen = require('states.battle.middle_screen')
local hud = require('states.battle.hud')
local logger = require('states.battle.logger')
local engine = require('states.battle.engine')
local menu = require('states.battle.menu')
local transitions = require('systems.transitions')
local battler = require('entities.battler')
local action = require('entities.action')
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

local function set_enemy_action()
    for i, enemy in ipairs(enemy_battlers) do
        if not enemy:is_alive() or enemy:cannot_act() then
            goto continue
        end
        
        local action_ref = enemy_action.get(enemy)
        local data = action_data[action_ref]

        local group = party_battlers
        if data.aim == 'allies' then
            group = enemy_battlers
        end

        local targets
        if data.scope == 'all' then
            targets = {unpack(group)}
        elseif data.scope == 'self' then
            targets = {enemy}
        elseif data.scope == 'single' then
            local target = engine.get_random_target(group)
            targets = {target}
        end
        
        local new_action = action.new(action_ref, data, enemy, targets)
        enemy.current_action = new_action
        
        ::continue::
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
        engine.update(dt)
    elseif phase == 'battle_won' then
        logger.update(dt)
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

    if logger.is_active() or logger.is_open() then
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

function battle.run_action()
    set_enemy_action()
    engine.load(battle, party_battlers, enemy_battlers, logger, middle_screen, hud)
    phase = 'battle_running'
end

function battle.is_won()
    phase = 'battle_won'
    logger.load('Enemy defeated!')
end

return battle