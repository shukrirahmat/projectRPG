local effect = require('systems.effect')
local effect_data = require('data.effect_data')

local executor = {}

local battle = nil
local party = nil
local enemies = nil
local logger = nil
local is_active = nil
local START_DELAY = 0.5
local phase = nil
local timer = 0
local active_battlers = nil
local current_battler = nil
local effect_queue = nil

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
    local highest_speed = -1

    for i, battler in ipairs(active_battlers) do
        local base_speed = battler:get_spd()
        local mod = math.floor(base_speed * 0.5)
        local speed = base_speed + (math.random(-mod, mod))
        if speed > highest_speed then
            highest_speed = speed
            index = i
        end
    end

    local battler = active_battlers[index]
    table.remove(active_battlers, index)
    return battler
end


local function execute_next_action()
    if #active_battlers <= 0 then
        is_active = false
        battle.enter_menu()
        return
    end

    current_battler = get_next_battler()
    current_battler:execute_action(executor)

    phase = 'run_action'
end

local function execute_next_effect()
    if #effect_queue <= 0 then
        if is_enemy_defeated() then
            battle.is_won()
        else
            execute_next_action()
        end
        return
    end

    local effect = effect_queue[1]
    table.remove(effect_queue, 1)

    if effect.target:is_alive() then
        effect.data:apply(executor, effect.user, effect.target, effect.value)
    end

    phase = 'run_effects'
end


local function run_start_delay(dt)
    timer = timer + dt
    if timer >= START_DELAY then
        timer = 0
        execute_next_action()
    end
end

local function run_next_action(dt)
    logger.update(dt)
    if not logger.is_active() then
        execute_next_effect()
    end
end

local function run_next_effect(dt)
    logger.update(dt)
    if not logger.is_active() then
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


function executor.load(_battle, _party, _enemies, _logger)

    battle = _battle
    party = _party
    enemies = _enemies
    logger = _logger


    effect_queue = {}


    set_active_battlers(party, enemies)

    timer = 0
    is_active = true
    phase = 'start'
end

function executor.update(dt)
    if not is_active then return end

    if phase == 'start' then
        run_start_delay(dt)
    elseif phase == 'run_action' then
        run_next_action(dt)
    elseif phase == 'run_effects' then
        run_next_effect(dt)
    end
end

function executor.get_random_target(group)
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

function executor.get_party()
    return party
end

function executor.get_enemies()
    return enemies
end

function executor.log_action(text)
    return logger.load(text)
end

function executor.log_effect(text)
    return logger.add(text)
end

function executor.add_effect(ref, user, target, value)
    local data = effect_data[ref]
    local effect = effect.new(ref, data, user, target, value)
    table.insert(effect_queue, effect)
end

function executor.kill_target(target)
    local data = effect_data['kill']
    local effect = effect.new('kill', data, target, target)
    table.insert(effect_queue, 1, effect)
end

function executor.remove_active_battler(target)
    for i = #active_battlers, 1, -1 do
        if active_battlers[i] == target then
            table.remove(active_battlers, i)
        end
    end
end

return executor