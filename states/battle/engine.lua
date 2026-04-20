local Action = require('entities.action')
local Effect = require('entities.effect')
local action_data = require('data.action_data')
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

local BATTLE_SPEED = 1

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

local function reaim_target(action)
    if action.data.aim == 'enemies' and action.data.scope == 'single' then
        if action.targets[1].is_dead then
            local new_target
            if action.targets[1].is_party_member then
                new_target = engine.get_random_target(party)
            else
                new_target = engine.get_random_target(enemies)
            end
            action.targets = {new_target}
        end
    end

    for i, target in ipairs(action.targets) do
        if target:is_alive() and target.is_covered and action.data.aim ~= 'allies' then
            if target.is_covered.covered_by:is_alive() then
                action.targets[i] = target.is_covered.covered_by
            end
        end
    end

    return action
end

local function finish_round()

    for i, group in ipairs({party, enemies}) do
        for j, battler in ipairs(group) do
            engine.clear_temporary_status(battler)
        end
    end

    is_active = false
    logger.close()
    battle.enter_menu()    
end

local function status_effect_pass(action, battler)
    if battler.status['SLEEP'] then
        action = Action.new('sleeping', action_data['sleeping'], battler, {battler})
        return action
    elseif battler.status['STUN'] and action then
        action = Action.new('stunned', action_data['stunned'], battler, {battler})
        return action
    elseif battler.status['PARALYSIS'] and action then
        local roll = math.random(1, 4)
        if roll == 1 then 
            action = Action.new('paralyzed', action_data['paralyzed'], battler, {battler})
            return action
        end
    end

    if battler.status['CONFUSE'] then
        local target
        local roll = math.random(1,5)
        if roll == 1 then
            action = Action.new('confused_idle', action_data['confused_idle'], battler, {battler})
        elseif roll == 2 then
            target = engine.get_random_target(engine.get_opposite_group(battler))
            action = Action.new('confused_attack', action_data['confused_attack'], battler, {target})
        elseif roll >= 3 then
            target = engine.get_random_target(engine.get_own_group(battler))
            action = Action.new('confused_attack', action_data['confused_attack'], battler, {target})
        end
        return action
    end
    return action
end


local function execute_next_action()
    if #active_battlers <= 0 then
        finish_round()
        return
    end

    current_battler = get_next_battler()
    current_battler.status_effect_updated = nil    
    local action = current_battler.current_action
    
    current_battler.current_action = nil

    action = status_effect_pass(action, current_battler)

    if not action or current_battler.is_invincible then
        phase = 'run_action'
        return
    end

    action = reaim_target(action)

    local ref = action.ref
    local data = action.data
    local targets = action.targets
    local var = {}

    if data.type == 'Magic' or data.type == 'Tech' then
        if current_battler.status['SEAL'] or (data.cost and current_battler.current_mp < data.cost) then
            var = { to_use = data }
            ref = 'skill_cancelled'
            data = action_data[ref]
            targets = {current_battler}
        else
            current_battler.current_mp = current_battler.current_mp - data.cost
        end
    end

    data:execute(current_battler, targets, engine, var)

    if not current_battler.is_party_member and data.enemy_animation then
        local animation = data.enemy_animation
        middle_screen.animate(current_battler, animation.type, animation.duration * BATTLE_SPEED)
    end

    if data.type == 'Magic' then
        if current_battler.passives['dual_cast'] then
            local roll = math.random(1, 4)
            if roll == 1 then
                engine.add_combo(ref, current_battler, targets)
            end
        end
    end

    phase = 'run_action'
end

local function execute_next_combo()
    local combo = combo_queue[1]
    table.remove(combo_queue, 1)

    if combo.user.is_dead or combo.user:cannot_act() then
        goto continue
    end

    if combo.ref == 'second_attack' and combo.targets[1].is_dead then
        goto continue
    end

    combo = reaim_target(combo)
    combo.data:execute(combo.user, combo.targets, engine)

    if not combo.user.is_party_member and combo.data.enemy_animation then
        local animation = combo.data.enemy_animation
        middle_screen.animate(combo.user, animation.type, animation.duration * BATTLE_SPEED)
    end

    ::continue::

    phase = 'run_combo'
end

local function apply_status_effects()

    if current_battler.status['POISON'] then
        local base_amount = math.floor(current_battler.max_hp * 0.15)
        local mod = math.floor(base_amount * 0.2)
        local amount = math.max(1, base_amount + math.random(-mod, mod))
        engine.add_effect('poison_damage', current_battler, current_battler, amount)
    end

    if current_battler.status['CURSE'] then
        local max
        if current_battler.is_party_member then
            max = 20
        else
            max = 4
        end
        local roll = math.random(1, max)
        if roll == 1 then
            engine.add_effect('curse_effect', current_battler, current_battler)
        end
    end

    if current_battler.passives['regenerate'] and current_battler.current_hp < current_battler.max_hp then
        local base_amount = math.floor(current_battler.max_hp * 0.15)
        local mod = math.floor(base_amount * 0.2)
        local amount = math.min(
            current_battler.max_hp - current_battler.current_hp, 
            base_amount + math.random(-mod, mod)
        )
        engine.add_effect('recover', current_battler, current_battler, amount)
    end
end

local function clear_status_effects()
    local status = {
        'BLIND', 
        'SEAL', 
        'STUN', 
        'STEEL', 
        'HASTE', 
        'MIGHT', 
        'BARRIER', 
        'FRAIL', 
        'SLOW', 
        'RESILIENT',
    }

    for i, status in ipairs(status) do
        if current_battler.status[status] then
            current_battler.status[status].countdown = current_battler.status[status].countdown - 1
            if current_battler.status[status].countdown <= 0 then
                engine.add_effect('clear_status', current_battler, current_battler, status)
            end
        end
    end
end

local function execute_next_effect()
    if #effect_queue <= 0 then
        if is_enemy_defeated() then
            battle.is_won()
        elseif #combo_queue > 0 then
            execute_next_combo()    
        elseif not current_battler.status_effect_updated then
            phase = 'update_status_effects'
        else
            execute_next_action()
        end
        return
    end

    local effect = effect_queue[1]
    table.remove(effect_queue, 1)

    if effect.target:is_alive() or effect.ref == 'revive' then

        if effect.target.is_invincible then
            effect = Effect.new('immune', effect_data['immune'], effect.user, effect.target)
        end

        effect.data:apply(engine, effect.user, effect.target, effect.value)

        if not effect.target.is_party_member and effect.data.enemy_animation then
            local animation =  effect.data.enemy_animation
            middle_screen.animate(
                effect.target, 
                animation.type, 
                animation.duration * BATTLE_SPEED, 
                effect.value)
        elseif effect.target.is_party_member and effect.data.party_animation then
            local animation =  effect.data.party_animation
            hud.animate(
                animation.type, 
                animation.duration * BATTLE_SPEED, 
                effect.target, 
                effect.value
            )
        end
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

local function update_status_effects()
    logger.clear()

    if not current_battler.is_invincible then
        apply_status_effects()
        clear_status_effects()
    end

    current_battler.status_effect_updated = true
    execute_next_effect()
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
    elseif phase == 'update_status_effects' then
        update_status_effects()
    end
end

function engine.get_own_group(battler)
    if battler.is_party_member then return party
    elseif not battler.is_party_member then return enemies
    end
end

function engine.get_opposite_group(battler)
    if battler.is_party_member then return enemies
    elseif not battler.is_party_member then return party
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

function engine.log_action(text, delayed_text, delay_time)
    local delay = delay_time or 1
    if delayed_text then
        logger.load(text, function() logger.add(delayed_text, nil, delay) end)
    else
        logger.load(text)
    end
end

function engine.log_effect(text, delayed_text, delay_time)
    local delay = delay_time or 1
    if delayed_text then
        logger.add(text, function() logger.add(delayed_text, nil, delay) end)
    else
        logger.add(text)
    end
end

function engine.add_effect(ref, user, target, value)
    local data = effect_data[ref]
    local effect = Effect.new(ref, data, user, target, value)
    table.insert(effect_queue, effect)
end

function engine.add_instant_effect(ref, user, target, value)
    local data = effect_data[ref]
    local effect = Effect.new(ref, data, user, target, value)
    table.insert(effect_queue, 1 , effect)
end

function engine.add_combo(ref, user, targets)
    local data = action_data[ref]
    local combo = Action.new(ref, data, user, targets)
    table.insert(combo_queue, combo)
end

function engine.kill_target(target)
    local data = effect_data['kill']
    local effect = Effect.new('kill', data, target, target)
    table.insert(effect_queue, 1, effect)
end

function engine.remove_active_battler(target)
    for i = #active_battlers, 1, -1 do
        if active_battlers[i] == target then
            table.remove(active_battlers, i)
        end
    end
end

function engine.clear_temporary_status(battler)

    battler.current_action = nil
    battler.is_defending = nil
    battler.is_invincible = nil
    battler.is_covered = nil

    if battler.is_aura_charged then
        battler.is_aura_charged.countdown = battler.is_aura_charged.countdown - 1
        if battler.is_aura_charged.countdown <= 0 or battler.is_dead then
            battler.is_aura_charged = nil
        end
    end

    if battler.is_focused then
        battler.is_focused.countdown = battler.is_focused.countdown - 1
        if battler.is_focused.countdown <= 0 or battler.is_dead then
            battler.is_focused = nil
        end
    end
end

return engine