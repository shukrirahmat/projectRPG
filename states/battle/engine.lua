local action = require('entities.action')
local action_data = require('data.action_data')
local effect = require('entities.effect')
local effect_data = require('data.effect_data')

local engine = {}

local battle = nil
local party = nil
local enemies = nil
local logger = nil
local middle_screen = nil
local hud = nil
local is_active = nil
local START_DELAY = 0.5
local phase = nil
local timer = 0
local active_battlers = nil
local current_battler = nil
local effect_queue = nil
local combo_queue = nil

engine.BATTLE_SPEED = 1

local function is_enemy_defeated()
    local alive = 0
    for i, enemy in ipairs(enemies) do
        if enemy:is_alive() then
            alive = alive + 1
        end
    end

    return alive == 0
end

local function get_next_battler()

    local index
    local highest_priority = 0
    local highest_speed = -1

    for i, battler in ipairs(active_battlers) do
        if battler.current_action then
            local data = battler.current_action.data
            if data.priority and data.priority > highest_priority then
                highest_priority = data.priority
                index = i
            end
        end

        if highest_priority == 0 then
            local base_speed = battler:get_spd()
            local mod = math.floor(base_speed * 0.5)
            local speed = base_speed + (math.random(-mod, mod))
            if speed > highest_speed then
                highest_speed = speed
                index = i
            end
        end
    end

    local battler = active_battlers[index]
    table.remove(active_battlers, index)
    return battler
end

local function clear_temporary_status(battler)
    if battler.is_defending then
        battler.is_defending = nil
    end
end

local function finish_round()

    for i, group in ipairs({party, enemies}) do
        for j, battler in ipairs(group) do
            clear_temporary_status(battler)
        end
    end

    is_active = false
    logger.close()
    battle.enter_menu()    
end


local function execute_next_action()
    if #active_battlers <= 0 then
        finish_round()
        return
    end

    current_battler = get_next_battler()
    current_battler:execute_action(engine)

    phase = 'run_action'
end

local function execute_next_combo()
    local combo = combo_queue[1]
    table.remove(combo_queue, 1)

    if not combo.user:is_alive() or combo.user:cannot_act() then
        goto continue
    end

    if combo.ref == 'second_attack' and not combo.targets[1]:is_alive() then
        goto continue
    end

    combo.user:execute_combo(combo, engine)

    ::continue::

    phase = 'run_combo'
end

local function execute_next_effect()
    if #effect_queue <= 0 then
        if is_enemy_defeated() then
            battle.is_won()
        elseif #combo_queue > 0 then
            execute_next_combo()    
        else
            execute_next_action()
        end
        return
    end

    local effect = effect_queue[1]
    table.remove(effect_queue, 1)

    if effect.target:is_alive() then
        effect.target:apply_effect(effect, engine, hud)
    end

    phase = 'run_effects'
end


local function run_start_delay(dt)
    timer = timer + dt
    if timer >= START_DELAY then
        timer = 0
        logger.stay()
        execute_next_action()
    end
end

local function run_next_action(dt)
    middle_screen.update(dt)
    logger.update(dt)
    if not logger.is_active() and not middle_screen.is_animating() then
        execute_next_effect()
    end
end

local function run_next_combo(dt)
    middle_screen.update(dt)
    logger.update(dt)
    if not logger.is_active() and not middle_screen.is_animating() then
        execute_next_effect()
    end
end

local function run_next_effect(dt)
    middle_screen.update(dt)
    logger.update(dt)
    hud.update(dt)
    if not logger.is_active() and not middle_screen.is_animating()  and not hud.is_animating() then
        execute_next_effect()
    end
end


local function set_active_battlers(party, enemies)

    active_battlers = {}

    for i, group in ipairs({party, enemies}) do
        for i, member in ipairs(group) do
            if member:is_alive() then
                table.insert(active_battlers, member)
            end
        end
    end
end

---PUBLIC---


function engine.load(_battle, _party, _enemies, _logger, _middle_screen, _hud)

    battle = _battle
    party = _party
    enemies = _enemies
    logger = _logger
    middle_screen = _middle_screen
    hud = _hud


    effect_queue = {}
    combo_queue = {}

    set_active_battlers(party, enemies)

    timer = 0
    is_active = true
    phase = 'start'
end

function engine.update(dt)
    if not is_active then return end

    if phase == 'start' then
        run_start_delay(dt)
    elseif phase == 'run_action' then
        run_next_action(dt)
    elseif phase == 'run_effects' then
        run_next_effect(dt)
    elseif phase == 'run_combo' then
        run_next_combo(dt)
    end
end

function engine.get_random_target(group)
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

function engine.log_action(text, delayed_text)
    if delayed_text then
        logger.load(text, function() logger.add(delayed_text, nil, 0.5) end)
    else
        logger.load(text)
    end
end

function engine.log_effect(text, delayed_text)
    if delayed_text then
        logger.add(text, function() logger.add(delayed_text, nil, 0.5) end)
    else
        logger.add(text)
    end
end

function engine.add_effect(ref, user, target, value)
    local data = effect_data[ref]
    local effect = effect.new(ref, data, user, target, value)
    table.insert(effect_queue, effect)
end

function engine.add_combo(ref, user, targets)
    local data = action_data[ref]
    local combo = action.new(ref, data, user, targets)
    table.insert(combo_queue, combo)
end

function engine.kill_target(target)
    local data = effect_data['kill']
    local effect = effect.new('kill', data, target, target)
    table.insert(effect_queue, 1, effect)
end

function engine.remove_active_battler(target)
    for i = #active_battlers, 1, -1 do
        if active_battlers[i] == target then
            table.remove(active_battlers, i)
        end
    end
end

function engine.reaim_target(action)
    if action.data.aim == 'enemies' and action.data.scope == 'single' then
        if not action.targets[1]:is_alive() then
            local new_target
            if action.targets[1].is_party_member then
                new_target = engine.get_random_target(party)
            else
                new_target = engine.get_random_target(enemies)
            end
            action.targets = {new_target}
        end
    end

    return action
end

return engine