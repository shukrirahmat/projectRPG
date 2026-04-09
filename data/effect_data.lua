local effect_data = {}

local function deal_damage(self, engine, user, target, value)
    
    engine.log_effect(''..target.name..' takes '..value..' damage.')
    target:take_damage(value)
    
    if target.current_hp <= 0 then
        engine.kill_target(target)
    end
end

local function no_effect(self, engine, user, target, value)
    
    engine.log_effect('It had no effect on '..target.name..'')
end

local function kill(self, engine, user, target, value)
    
    target:dies()
    target.status = {}
    
    engine.log_effect(''..target.name..' defeated.')
    engine.remove_active_battler(target)
    engine.clear_temporary_status(target)
end

local function defend(self, engine, user, target)
    target.is_defending = true
end


effect_data['damage'] = { 
    apply = deal_damage , 
    party_animation = { type = 'damaged', duration = 0.8 },
    enemy_animation = { type = 'damaged', duration = 1 }
}

effect_data['resist'] = { 
    apply = deal_damage,
    party_animation = { type = 'damaged', duration = 0.8 },
    enemy_animation = { type = 'resisted', duration = 1 }
}

effect_data['immune'] = { 
    apply = no_effect,
    enemy_animation = { type = 'immune', duration = 1 }
}

effect_data['kill'] = { 
    apply = kill,
    enemy_animation = { type = 'death', duration = 0.5 }
}

effect_data['defend'] = { 
    apply = defend, 
}

return effect_data