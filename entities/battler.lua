local battler = {}

function battler.new(data)

    local self = {}

    self.lvl = data.lvl
    self.current_hp = data.current_hp or data.hp
    self.max_hp = data.max_hp or data.hp
    self.current_mp = data.current_mp or data.mp
    self.max_mp = data.max_mp or data.mp
    self.str = data.str
    self.vit = data.vit
    self.agi = data.agi
    self.skills = data.skills or {}
    self.passive_skills = data.passive_skills or {}
    self.passives = {}
    self.status = data.status or {}
    self.strong = data.strong or {}
    self.immune = data.immune or {}
    self.is_dead = false
    self.weapon = data.weapon or nil
    self.armor = data.armor or nil
    self.shield = data.shield or nil

    for i, ref in pairs(data.passive_skills) do
        self.passives[ref] = true
    end

    if self.weapon and self.weapon.passives then
        for i, ref in ipairs(self.weapon.passives) do
            self.passives[ref] = true
        end
    end

    if self.armor and self.armor.passives then
        for i, ref in ipairs(self.armor.passives) do
            self.passives[ref] = true
        end
    end

    if self.shield and self.shield.passives then
        for i, ref in ipairs(self.shield.passives) do
            self.passives[ref] = true
        end
    end

    if self.passives['arcane_protection'] then
        self.strong['FIRE'] = true
        self.strong['ICE'] = true
        self.strong['BOLT'] = true
        self.strong['WIND'] = true
    end

    if self.passives['celestial_protection'] then
        self.strong['LIGHT'] = true
        self.strong['VOID'] = true
    end

    if self.passives['last_stand'] then
        self.last_stand_chance = 100
    end
    
    for k, v in pairs(self.passives) do
        if k:sub(1, 8) == 'mastery:' then
            if k and self.weapon.class == k:sub(9) then
                self.weapon_mastery = true
            end
        end
        
        if k:sub(1, 7) == 'strong:' then
            if k then self.strong[k:sub(8)] = true end
        end

        if k:sub(1, 7) == 'immune:' then
            if k then self.immune[k:sub(8)] = true end
        end
    end

    function self:take_damage(damage)
        self.current_hp = self.current_hp - damage
    end

    function self:dies()
        self.current_hp = 0
        self.is_dead = true
    end

    function self:is_alive()
        return not self.is_dead
    end

    function self:cannot_act()
        return self.status['STUN'] or self.status['SLEEP'] or self.status['CONFUSE']
    end

    function self:get_atk()
        local weapon_atk = 0
        if self.weapon then weapon_atk = self.weapon.atk_power end
        local mastery_buff = 1
        if self.weapon_mastery then mastery_buff = 1.5 end
        
        local base = (self.str + weapon_atk) * mastery_buff
        local buff = 0
        if self.status['MIGHT'] then
            buff = math.floor(0.8 * base)
        end

        return base + buff
    end

    function self:get_def()
        local armor_def = 0
        if self.armor then armor_def = self.armor.def_power end
        local shield_def = 0
        if self.shield then shield_def = self.shield.def_power end
        
        local base = self.vit + armor_def + shield_def

        local buff = 0
        if self.status['STEEL'] then
            buff = math.floor((0.4 * self.status['STEEL'].stack) * base)
        end

        local debuff = 0
        if self.status['FRAIL'] then
            debuff = math.floor((0.4 * self.status['FRAIL'].stack) * base)
        end

        return math.max(1, base + buff - debuff)
    end

    function self:get_spd()
        local base = self.agi
        local buff = 0
        if self.status['HASTE'] then
            buff = math.floor((0.4 * self.status['HASTE'].stack) * base)
        end

        local debuff = 0
        if self.status['SLOW'] then
            debuff = math.floor((0.4 * self.status['SLOW'].stack) * base)
        end

        return math.max(1, base + buff - debuff)
    end

    function self:get_dodge_rate()
        if self:cannot_act() then return 0 end        
        if self.passives['evasion_II'] then 
            return 4
        elseif self.passives['evasion_I'] then 
            return 8
        end        
        return 0
    end

    function self:get_crit_rate()       
        if self.passives['precision_II'] then 
            return 8
        elseif self.passives['precision_I'] then 
            return 16
        end    

        return self.crit_rate
    end

    return self
end

return battler