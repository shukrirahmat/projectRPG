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
    battler.vit = member.vit
    battler.agi = member.agi
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

    for i, ref in ipairs(battler.passiveSkills) do
        battler.passives[ref] = true
    end

    if battler.weapon then
        if battler.weapon.passives then
            for k, v in pairs(battler.weapon.passives) do
                battler.passives[k] = true
            end
        end
    end

    if battler.armor then
        if battler.armor.passives then
            for k, v in pairs(battler.armor.passives) do
                battler.passives[k] = true
            end
        end
    end

    if battler.shield then
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

    function battler:getAtk()
        local atk = self.str
        if self.weapon then
            atk = atk + self.weapon.atkPower
            if self.weapon.class == 'LIGHTWEIGHT' and self.passives['lightwielder'] then
                atk = atk * 1.5
            elseif self.weapon.class == 'HEAVYWEIGHT' and self.passives['heavyWielder'] then
                atk = atk * 1.5
            end
        end
        return atk
    end

    function battler:getDef()
        local def = self.vit
        if self.armor then
            def = def + self.armor.defPower
        end
        if self.shield then
            def = def + self.shield.defPower
        end
        return def
    end
    
    function battler:getAgi()
        local agi = self.agi
        return agi
    end


    function battler:cannotAct()
        return self.status['STUN'] or self.status['SLEEP'] or self.status['CONFUSE']
    end

    return battler
end

return battlerCreator