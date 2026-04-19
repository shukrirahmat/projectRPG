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

    for i, ref in pairs(data.passive_skills) do
        self.passives[ref] = true
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
        local base = self.str
        local buff = 0
        if self.status['MIGHT'] then
            buff = math.floor(0.8 * base)
        end
        
        return base + buff
    end

    function self:get_def()
        local base = self.vit
        
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
        if self.passives['artful_dodger'] then return 4 end        
        return 0
    end

    return self
end

return battler