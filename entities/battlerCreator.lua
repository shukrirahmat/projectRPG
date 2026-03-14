local battlerCreator = {}

function battlerCreator.new(member)
    local battler = {}

    battler.isPartyMember = true
    battler.isDead = member.isDead or false

    battler.id = member.id
    battler.name = member.name
    battler.lvl = member.lvl
    battler.maxHp = member.maxHp
    battler.currentHp = member.currentHp
    battler.maxMp = member.maxMp
    battler.currentMp = member.currentMp
    battler.str = member.str
    battler.baseAtk = member.str
    battler.atk = battler.baseAtk
    battler.vit = member.vit
    battler.baseDef = member.vit
    battler.def = battler.baseDef
    battler.baseAgi = member.agi
    battler.agi = battler.baseAgi
    battler.critRate = member.critRate or 64
    battler.dodgeRate = member.dodgeRate or 0
    battler.skills = member.skills or {}
    battler.passiveSkills = member.passiveSkills or {}
    battler.status = member.status or {}
    battler.strong = member.strong or {}
    battler.immune = member.immune or {}
    battler.passives = {}
    battler.totalExp = member.totalExp or 0
    battler.weapon = member.weapon or nil
    battler.armor = member.armor or nil
    battler.shield = member.shield or nil
    battler.sprite = member.sprite
    battler.nextExp = member.nextExp or nil
    
    for i, ref in ipairs(battler.passiveSkills) do
        battler.passives[ref] = true
    end

    if battler.weapon then
        battler.baseAtk = battler.baseAtk + battler.weapon.atkPower;
        battler.atk = battler.baseAtk
        if battler.weapon.passives then
            for k, v in pairs(battler.weapon.passives) do
                battler.passives[k] = true
            end
        end
    end

    if battler.armor then
        battler.baseDef = battler.baseDef + battler.armor.defPower;
        battler.def = battler.baseDef
        if battler.armor.passives then
            for k, v in pairs(battler.armor.passives) do
                battler.passives[k] = true
            end
        end
    end

    if battler.shield then
        battler.baseDef = battler.baseDef + battler.shield.defPower;
        battler.def = battler.baseDef
        if battler.shield.passives then
            for k, v in pairs(battler.shield.passives) do
                battler.passives[k] = true
            end
        end
    end
    
    for k, v in pairs(battler.passives) do
        if k:sub(1, 7) == 'strong:' then
            if k then battler.strong[k:sub(8)] = true end
        end
        
        if k:sub(1, 7) == 'immune:' then
            if k then battler.immune[k:sub(8)] = true end
        end
    end

    if battler.passives['keenEyeII'] then
        battler.critRate = 8
    elseif battler.passives['keenEyeI'] then
        battler.critRate = 16
    end

    if battler.passives['evasionII'] then
        battler.dodgeRate = 2
    elseif battler.passives['evasionI'] then
        battler.dodgeRate = 4
    end

    if battler.passives['arcaneProtection'] then
        battler.strong['FIRE'] = true
        battler.strong['ICE'] = true
        battler.strong['BOLT'] = true
        battler.strong['WIND'] = true
    end

    if battler.passives['celestialProtection'] then
        battler.strong['LIGHT'] = true
        battler.strong['VOID'] = true
    end

    if battler.passives['lightWielder'] 
    and battler.weapon and battler.weapon.class == 'LIGHTWEIGHT' then
        battler.baseAtk = battler.baseAtk * 1.5
        battler.atk = battler.baseAtk
    end

    if battler.passives['heavyWielder'] 
    and battler.weapon and battler.weapon.class == 'HEAVYWEIGHT' then
        battler.baseAtk = battler.baseAtk * 1.5
        battler.atk = battler.baseAtk
    end

    return battler
end

return battlerCreator