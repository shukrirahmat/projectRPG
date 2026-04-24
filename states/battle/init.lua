local middle_screen = require('states.battle.middle_screen')
local hud = require('states.battle.hud')
local logger = require('states.battle.logger')
local engine = require('states.battle.engine')
local menu = require('states.battle.menu')
local transitions = require('systems.transitions')
local party_manager = require('systems.party_manager')
local Member_battler = require('entities.member_battler')
local Enemy_battler = require('entities.enemy_battler')
local Action = require('entities.action')
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
        local hp = ''..enemy.current_hp..'/'..enemy.max_hp..' '..enemy.current_mp..'/'..enemy.max_mp..''
        local stat = 'ATK: '..enemy:get_atk()..' DEF: '..enemy:get_def()..'  SPD: '..enemy:get_spd()..''
        love.graphics.printf(
            ''..hp..' '..stat..'',
            love.graphics.getWidth() / 2,
            20 + (i - 1) * 20,
            love.graphics.getWidth() / 2 - 40,
            'right'
        )
    end
    
    --[[for i, member in ipairs(party_battlers) do
        local hp = ''..member.current_hp..'/'..member.max_hp..' '..member.current_mp..'/'..member.max_mp..''
        local stat = 'ATK: '..member:get_atk()..' DEF: '..member:get_def()..'  SPD: '..member:get_spd()..''
        love.graphics.printf(
            ''..hp..' '..stat..'',
            love.graphics.getWidth() / 2,
            150 + (i - 1) * 20,
            love.graphics.getWidth() / 2 - 40,
            'right'
        )
    end]]
end

local function set_party_battlers(party)
    for i, member in ipairs(party) do
        local new_battler = Member_battler.new(member)
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
            local new_battler = Enemy_battler.new(enemy_data[k], name)
            table.insert(enemy_battlers, new_battler)
        end
    end
end

local function set_enemy_action()
    for i, enemy in ipairs(enemy_battlers) do
        if not enemy:is_alive() then
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
        
        local new_action = Action.new(action_ref, data, enemy, targets)
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
    set_party_battlers(party_manager.get_members())
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
    menu.load(battle, party_manager, party_battlers, enemy_battlers)
    phase = 'menu_input'
end

function battle.run_action()
    set_enemy_action()
    engine.load(battle, party_manager, party_battlers, enemy_battlers, logger, middle_screen, hud)
    phase = 'battle_running'
end

function battle.is_won()
    phase = 'battle_won'
    logger.load('Enemy defeated!')
end

function battle.add_item(item)
    party_manager.manage_item(item, 1)
end

return battle