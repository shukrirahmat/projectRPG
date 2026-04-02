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
        execute_next_action()
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

function executor.log(text)
    return logger.load(text)
end

return executor