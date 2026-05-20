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
    self.status = {}
    self.strong = {}
    self.immune = {}
    self.is_dead = data.is_dead or false
    self.weapon = data.weapon or nil
    self.armor = data.armor or nil
    self.headgear = data.headgear or nil
    self.other_eq = data.other_eq or nil

    for i, ref in pairs(data.passive_skills) do
        self.passives[ref] = true
    end
    
    if data.status then
        for k, v in pairs(data.status) do
            self.status[k] = v
        end
    end
    
    if data.strong then
        for k, v in pairs(data.strong) do
            self.strong[k] = v
        end
    end
    
    if data.immune then
        for k, v in pairs(data.immune) do
            self.immune[k] = v
        end
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

    if self.headgear and self.headgear.passives then
        for i, ref in ipairs(self.headgear.passives) do
            self.passives[ref] = true
        end
    end
    
    if self.other_eq and self.other_eq.passives then
        for i, ref in ipairs(self.other_eq.passives) do
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
    
    if self.passives['head_start'] then
        self.status['HASTE'] = { stack = 2, countdown = 6 }
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
    
    function self:get_str()
        local base_str = self.str
        local eq_bonus = 0
        for i, slot in pairs({self.weapon, self.armor, self.headgear, self.other_eq}) do
            if slot and slot.stat.str then
                eq_bonus = eq_bonus + slot.stat.str
            end
        end
        return base_str + eq_bonus
    end
    
    function self:get_vit()
        local base_vit = self.vit
        local eq_bonus = 0
        for i, slot in pairs({self.weapon, self.armor, self.headgear, self.other_eq}) do
            if slot and slot.stat.vit then
                eq_bonus = eq_bonus + slot.stat.vit
            end
        end
        return base_vit + eq_bonus
    end
    
    function self:get_agi()
        local base_agi = self.agi
        local eq_bonus = 0
        for i, slot in pairs({self.weapon, self.armor, self.headgear, self.other_eq}) do
            if slot and slot.stat.agi then
                eq_bonus = eq_bonus + slot.stat.agi
            end
        end
        return base_agi + eq_bonus
    end

    function self:get_atk()
        local eq_bonus = 0
        for i, slot in pairs({self.weapon, self.armor, self.headgear, self.other_eq}) do
            if slot and slot.stat.atk then
                eq_bonus = eq_bonus + slot.stat.atk
            end
        end
        local mastery_buff = 1
        if self.weapon_mastery then mastery_buff = 1.5 end
        
        local base = (self:get_str() + eq_bonus) * mastery_buff
        local buff = 0
        if self.status['MIGHT'] then
            buff = math.floor(0.8 * base)
        end

        return base + buff
    end

    function self:get_def()
        local eq_bonus = 0
        for i, slot in pairs({self.weapon, self.armor, self.headgear, self.other_eq}) do
            if slot and slot.stat.def then
                eq_bonus = eq_bonus + slot.stat.def
            end
        end
        
        local base = self:get_vit() + eq_bonus

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
        local base = self:get_agi()
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