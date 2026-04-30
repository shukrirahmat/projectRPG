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

local game = nil
local party_battlers = nil
local enemy_battlers = nil
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
    party_battlers = {}

    for i, member in ipairs(party) do
        local new_battler = Member_battler.new(member)
        table.insert(party_battlers, new_battler)
    end
end

local function set_enemy_battlers(enemies)
    enemy_battlers = {}

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

local function sync_member()
    for i, battler in ipairs(party_battlers) do
        local member = battler.party_ref
        member.is_dead = battler.is_dead
        member.current_hp = battler.current_hp
        member.current_mp = battler.current_mp
        member.status['POISON'] = battler.status['POISON']
        member.status['CURSE'] = battler.status['CURSE']
        member.status['WOUND'] = battler.status['WOUND']
        member.status['PARALYSIS'] = battler.status['PARALYSIS']
    end
end

local function flee_success()
    local enemy_total_level = 0
    local party_total_level = 0

    for i, enemy in ipairs(enemy_battlers) do
        if enemy:is_alive() then
            enemy_total_level = enemy_total_level + enemy.lvl
        end
    end

    for i, member in ipairs(party_battlers) do
        if member:is_alive() then
            party_total_level = party_total_level + member.lvl
        end
    end

    local difference = party_total_level - enemy_total_level
    local roll = math.random(1, 100)
    if roll <= ( 50 + difference * 2 ) then
        return true
    end

    return false
end    

local function handle_flee()
    local success = flee_success()

    local function escape()
        logger.close()
        sync_member()
        game.switch_state('field')
    end

    logger.stay()
    if success then
        logger.add('The party successfully escaped!', 
            function() transitions.load('fade_out', 0.5, escape) end
        )
    else
        logger.add('But the enemies blocked the exit!', battle.run_action)
    end
end

---PUBLIC---


function battle.load(_game, var)
    game = _game
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
    elseif phase == 'battle_lost' then
        logger.update(dt)
        transitions.update(dt)
    elseif phase == 'fleeing' then
        logger.update(dt)
        transitions.update(dt)
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

    local function to_reward_screen()
        logger.close()
        sync_member()
        
        local exp_gain = 0
        local gold_gain = 0
        local item_drop = {}
        for i, enemy in ipairs(enemy_battlers) do
            exp_gain = exp_gain + enemy.exp_drop
            gold_gain = gold_gain + enemy.gold_drop

            if enemy.item_drop then
                for k,v in pairs(enemy.item_drop) do
                    local success = math.random(1, v) == 1
                    if success then
                        table.insert(item_drop, {ref = k, enemy_name = enemy.name})
                    end
                end
            end
        end

        game.switch_state('reward', {exp = exp_gain, gold = gold_gain, items = item_drop})
    end

    logger.load('Enemy defeated!', to_reward_screen, 2)
end

function battle.is_lost()
    phase = 'battle_lost'
    
    local function to_defeat_screen()
        logger.close()
        transitions.load('fade_out', 0.5, function() game.switch_state('defeat') end)
    end
    
    logger.load('The party has fallen.', to_defeat_screen, 2)
end

function battle.add_item(item)
    party_manager.manage_item(item, 1)
end

function battle.flee()
    phase = 'fleeing'
    logger.load('The party tried to escape...', handle_flee)
end


return battle