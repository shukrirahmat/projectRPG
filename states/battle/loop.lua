local loop = {}

local battle = nil
local is_active = nil
local action_queue = nil
local logger = nil
local START_DELAY = 0.5
local phase = nil
local timer = 0
local current_action = nil

local function get_next_action()
    
    local index
    local highest_speed = -1
    
    for i, action in ipairs(action_queue) do
        local base_speed = action.user:get_spd()
        local mod = math.floor(base_speed * 0.5)
        local speed = base_speed + (math.random(-mod, mod))
        if speed > highest_speed then
            highest_speed = speed
            index = i
        end
    end
    
    local action = action_queue[index]
    table.remove(action_queue, index)
    return action
end
    

local function execute_next_action()
    if #action_queue <= 0 then
        is_active = false
        battle.enter_menu()
        return
    end
    
    current_action = get_next_action()
    current_action.data:execute(current_action.user, current_action.targets, logger)
    
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


---PUBLIC---


function loop.load(_battle, queue, _logger)
    
    battle = _battle
    action_queue = queue
    logger = _logger
    
    timer = 0
    is_active = true
    phase = 'start'
end

function loop.update(dt)
    if not is_active then return end
    
    if phase == 'start' then
        run_start_delay(dt)
    elseif phase == 'run_action' then
        run_next_action(dt)
    end
end

return loop