local encounter = {}

local initial_chance = nil
local current_chance = nil
local step_ratio = 0.8


function encounter.load(current_map)
    initial_chance = current_map.encounter_chance
    current_chance = initial_chance
end

function encounter.attempt(field)
    local roll = math.random(1, current_chance)
    if roll == 1 then
        current_chance = initial_chance
        field.enter_battle()
    else
        current_chance = math.max(1, math.floor(current_chance * step_ratio))
    end
end
    

return encounter