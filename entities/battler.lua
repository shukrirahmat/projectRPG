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
    self.dodge_rate = data.dodge_rate or 0
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

    function self:is_alive()
        return not self.is_dead
    end

    function self:update(dt)
        if not self.animation then return end

        self.animation.timer = self.animation.timer + dt
        if self.animation.timer >= self.animation.duration then
            self.animation.timer = 0
            self.animation = nil
        end
    end

    function self:take_damage(damage)
        self.current_hp = self.current_hp - damage
    end

    function self:dies()
        self.current_hp = 0
        self.is_dead = true
    end

    function self:cannot_act()
        return self.status['STUN'] or self.status['SLEEP'] or self.status['CONFUSE']
    end

    function self:get_atk()
        return self.str
    end

    function self:get_def()
        return self.vit
    end

    function self:get_spd()
        return self.agi
    end

    return self
end

return battler