local effect_data = {}

local function deal_damage(self, executor, user, target, value)
    
    executor.log_effect(''..target.name..' takes '..value..' damage.')
    target:take_damage(value)
    
    if target.current_hp <= 0 then
        executor.kill_target(target)
    end
end

local function kill(self, executor, user, target, value)
    
    target:dies()
    target.status = {}
    
    executor.log_effect(''..target.name..' defeated.')
    executor.remove_active_battler(target)
end


effect_data['damage'] = { 
    apply = deal_damage , 
}

effect_data['kill'] = { 
    apply = kill,
}

return effect_data