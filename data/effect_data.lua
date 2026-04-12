local effect_data = {}

local function deal_damage(self, engine, user, target, value)
    
    engine.log_effect(''..target.name..' takes '..value..' damage.')
    target:take_damage(value)
    
    if target.current_hp <= 0 then
        engine.kill_target(target)
    end
end

local function mp_damage(self, engine, user, target, value)
    
    engine.log_effect(''..target.name..' loses '..value..' MP.')
    target.current_mp = math.max(0, target.current_mp - value)
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

local function skill_cancelled(self, engine, user, target)
    if target.status['SEAL'] then
        engine.log_effect("But "..target.name.."'s abilities are sealed!")
    else
        engine.log_effect("But "..target.name.." did not have enough MP!")
    end
end

local function aura_charge(self, engine, user, target)
    target.is_aura_charged = { countdown = 2 }
end

local function recover(self, engine, user, target, value)
    target.current_hp = math.min(target.max_hp, target.current_hp + value)
    engine.log_effect(''..target.name..' recovers '..value..' HP.');
end

local function missed(self, engine, user, target)
    engine.log_effect('It missed '..target.name..'!');
end

local function add_status(self, engine, user, target, status)
    if status == 'BLIND' then
        if target.status['BLIND'] then
            engine.log_effect( ""..target.name.." is already blinded.")
        else
            engine.log_effect("Sand got into "..target.name.."'s eyes!")
        end
    elseif status == 'SEAL' then
        if target.status['SEAL'] then
            engine.log_effect(""..target.name.." is already sealed.");
        else
            engine.log_effect(""..target.name.."'s abilities are sealed!");
        end
    elseif status == 'STUN' then
        if target.status['SEAL'] then
            engine.log_effect(""..target.name.." is already stunned.");
        else
            engine.log_effect(""..target.name.." is stunned!");
        end
    elseif status == 'WOUND' then
        if target.status['WOUND'] then
            engine.log_effect(""..target.name.." is already wounded");
        else
            engine.log_effect(""..target.name.." is wounded. Healing is reduced!");
        end
    end
    
    target.status[status] = true;
end

local function clear_status(self, engine, user, target, status)
    
    target.status[status] = nil
    
    if status == 'BLIND' then
        engine.log_effect("Sand has been cleared in "..target.name.."'s eyes.");
    elseif status == 'SEAL' then
        engine.log_effect(""..target.name.."'s abilites is no longer sealed.");
    elseif status == 'STUN' then
        engine.log_effect(""..target.name.." is no longer stunned.");
    end
end

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

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

effect_data['mp_damage'] = { 
    apply = mp_damage , 
    party_animation = { type = 'damaged', duration = 0.8 },
    enemy_animation = { type = 'mp_damaged', duration = 1 }
}

effect_data['mp_resist'] = { 
    apply = mp_damage,
    party_animation = { type = 'damaged', duration = 0.8 },
    enemy_animation = { type = 'mp_resisted', duration = 1 }
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

effect_data['skill_cancelled'] = { 
    apply = skill_cancelled, 
}

effect_data['aura_charge'] = { 
    apply = aura_charge, 
}

effect_data['recover'] = { 
    apply = recover, 
}

effect_data['missed'] = { 
    apply = missed, 
    enemy_animation = { type = 'missed', duration = 1 }
}

effect_data['missed_resist'] = { 
    apply = missed, 
    enemy_animation = { type = 'missed_resist', duration = 1 }
}

effect_data['add_status'] = { 
    apply = add_status,
}

effect_data['clear_status'] = { 
    apply = clear_status,
}

return effect_data