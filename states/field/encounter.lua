local encounter = {}

local initial_chance = nil
local current_chance = nil
local step_ratio = 0.8
local pool = nil
local maximum = nil


function encounter.load(current_map)
    initial_chance = current_map.encounter_chance
    pool = current_map.encounter_pool
    maximum = current_map.encounter_max
    
    current_chance = initial_chance
end

function encounter.generate()
    
    local encounters = {}
    
    local enemy_count = 0
    local more_enemies = true
    local more_chance = 100
    
    while more_enemies and enemy_count < maximum do
        local roll_for_more = math.random(0, 100)
        if roll_for_more <= more_chance then
            local enemy_roll = math.random(1, #pool)
            local enemy = pool[enemy_roll]
            if encounters[enemy] then
                encounters[enemy] = encounters[enemy] + 1
            else
                encounters[enemy] = 1
            end
            more_chance = math.floor(more_chance * 0.9)
            enemy_count = enemy_count + 1
        else
            more_enemies = false
        end
    end
    
    return encounters
end

function encounter.attempt(field)
    local roll = math.random(1, current_chance)
    if roll == 1 then
        current_chance = initial_chance
        local enemies = encounter.generate()
        field.enter_battle(enemies)
    else
        current_chance = math.max(1, math.floor(current_chance * step_ratio))
    end
end
    

return encounter