local effect_data = {}

local function empty(self, engine, user, target, value)
    --nothing happens
end

local function deal_damage(self, engine, user, target, value)

    engine.log_effect(''..target.name..' takes '..value..' damage.')
    target:take_damage(value)

    if target.current_hp <= 0 then
        engine.kill_target(target)
    else
        for i, status in ipairs({'SLEEP', 'CONFUSE'}) do
            if target.status[status] then
                local roll = math.random(1,3)
                if roll == 1 then
                    engine.add_instant_effect('clear_status', user, target, status)
                end
            end
        end
    end
end

local function mp_damage(self, engine, user, target, value)

    engine.log_effect(''..target.name..' loses '..value..' MP.')
    target.current_mp = math.max(0, target.current_mp - value)
end

local function no_effect(self, engine, user, target, value)

    engine.log_effect('It had no effect on '..target.name..'.')
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
            target.status[status] = {countdown = math.random(3, 5)}
        end
    elseif status == 'SEAL' then
        if target.status['SEAL'] then
            engine.log_effect(""..target.name.." is already sealed.");
        else
            engine.log_effect(""..target.name.."'s abilities are sealed!");
            target.status[status] = {countdown = math.random(2, 4)}
            
        end
    elseif status == 'STUN' then
        if target.status['STUN'] then
            engine.log_effect(""..target.name.." is already stunned.");
        else
            engine.log_effect(""..target.name.." is stunned!");
            target.current_action = nil
            target.status[status] = {countdown = math.random(1, 3)}
        end
    elseif status == 'WOUND' then
        if target.status['WOUND'] then
            engine.log_effect(""..target.name.." is already wounded");
        else
            engine.log_effect(""..target.name.." is wounded. Healing is reduced!");
            target.status[status] = true;
        end
    elseif status == 'POISON' then
        if target.status['POISON'] then
            engine.log_effect(""..target.name.." is already poisoned.");
        else
            engine.log_effect(""..target.name.." is poisoned!");
            target.status[status] = true;
        end
    elseif status == 'CURSE' then
        if target.status['CURSE'] then
            engine.log_effect(""..target.name.." is already cursed");
        else
            engine.log_effect(""..target.name.." is cursed!");
            target.status[status] = true;
        end
    elseif status == 'PARALYSIS' then
        if target.status['PARALYSIS'] then
            engine.log_effect(""..target.name.." is already paralyzed");
        else
            engine.log_effect(""..target.name.." is paralyzed!");
            target.status[status] = true;
        end
    elseif status == 'SLEEP' then
        if target.status['SLEEP'] then
            engine.log_effect(""..target.name.." is already sleeping");
        else
            engine.log_effect(""..target.name.." is put to sleep!");
            target.current_action = nil
            target.status[status] = true;
        end
    elseif status == 'CONFUSE' then
        if target.status['PARALYSIS'] then
            engine.log_effect(""..target.name.." is already confused");
        else
            engine.log_effect(""..target.name.." is confused!");
            target.current_action = nil
            target.status[status] = true;
        end
    end
end

local function clear_status(self, engine, user, target, status)

    target.status[status] = nil

    if status == 'BLIND' then
        engine.log_effect("Sand has been cleared in "..target.name.."'s eyes.");
    elseif status == 'SEAL' then
        engine.log_effect(""..target.name.."'s abilites is no longer sealed.");
    elseif status == 'STUN' then
        engine.log_effect(""..target.name.." recovered from stun.");
    elseif status == 'WOUND' then
        engine.log_effect(""..target.name.."'s wound has been mended.");
    elseif status == 'POISON' then
        engine.log_effect(""..target.name.." recovered from poison.");
    elseif status == 'CURSE' then
        engine.log_effect("The curse have been lifted from "..target.name..".");
    elseif status == 'PARALYSIS' then
        engine.log_effect(""..target.name.." recovered from paralysis.");
    elseif status == 'SLEEP' then
        engine.log_effect(""..target.name.." has awoken from sleep.");
    elseif status == 'CONFUSE' then
        engine.log_effect(""..target.name.." is no longer confused.");
    end
end

local function cleanse(self, engine, user, target)
    
    local statuses = {'BLIND', 'SEAL', 'STUN', 'WOUND', 'POISON', 'CURSE', 'PARALYSIS', 'SLEEP', 'CONFUSE'}
    
    for i, status in ipairs(statuses) do
        target.status[status] = nil
    end
    
    engine.log_effect(""..target.name.." has been cure from all status effects")
end

local function poison_damage(self, engine, user, target, value)

    engine.log_effect(''..target.name..' loses '..value..' HP to poison.');
    target:take_damage(value)

    if target.current_hp <= 0 then
        engine.kill_target(target)
    end
end

local function curse_effect(self, engine, user, target)
    engine.log_effect(''..target.name..' succumbed to the curse.');
    engine.kill_target(target)
end

local function nothing_happened(self, engine, user, target)
    engine.log_effect('But nothing happened!');
end

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

effect_data['empty'] = { 
    apply = empty
}

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

effect_data['cleanse'] = { 
    apply = cleanse,
}

effect_data['poison_damage'] = { 
    apply = poison_damage,
    party_animation = { type = 'damaged', duration = 0.8 },
    enemy_animation = { type = 'damaged', duration = 1 }
}

effect_data['curse_effect'] = { 
    apply = curse_effect
}

effect_data['nothing_happened'] = { 
    apply = nothing_happened
}

return effect_data