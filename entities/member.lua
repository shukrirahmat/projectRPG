local member = {}

function member.new(data)
    local self = {}
    
    self.id = data.id
    self.name = data.name
    self.lvl = data.lvl
    self.current_hp = data.hp
    self.max_hp = data.hp
    self.current_mp = data.mp
    self.max_mp = data.mp
    self.str = data.str
    self.vit = data.vit
    self.agi = data.agi
    self.skills = data.skills
    self.passive_skills = data.passive_skills
    self.status = data.status
    self.total_exp = data.total_exp
    self.strong = data.strong or {}
    self.immune = data.immune or {}
    self.sprite = data.sprite
    self.is_alive = true
    
    function self:is_alive()
        return self.is_alive
    end
    
    return self
end

return member