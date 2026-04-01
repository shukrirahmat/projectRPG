local enemy_sprites = require('graphics.enemy_sprites')
local party_sprites = require('graphics.party_sprites')

local battler = {}

function battler.new_member(data)
    local self = battler.new(data)

    self.name = data.name
    self.is_party_member = true
    self.member_id = data.id
    self.current_hp = data.current_hp
    self.max_hp = data.max_hp
    self.current_mp = data.current_mp
    self.max_mp = data.current_mp
    self.crit_rate = 64
    self.total_exp = data.total_exp
    self.sprite = party_sprites.get_sprite(data.sprite)
    
    function self:draw(x, y)
        local sprite = self.sprite
        
        if not self:is_alive() then
            sprite = party_sprites.get_sprite('coffin')
        end
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(sprite, x, y)
    end

    return self
end

function battler.new_enemy(data, name)
    
    local self = battler.new(data)

    self.name = name
    self.current_hp = data.hp
    self.max_hp = data.hp
    self.current_mp = data.mp
    self.max_mp = data.mp
    self.crit_rate = 128
    self.sprite_height = data.sprite_height
    self.exp_drop = data.exp_drop
    self.gold_drop = data.gold_drop
    self.sprite = enemy_sprites.get_sprite(data.sprite)
    
    function self:draw(x, y)
        if not self:is_alive() then return end

        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.sprite, x, y)
    end

    return self
end

function battler.new(data)
    
    local self = {}

    self.lvl = data.lvl
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

    for i, ref in pairs(data.passive_skills) do
        self.passives[ref] = true
    end

    function self:is_alive()
        return self.current_hp > 0
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