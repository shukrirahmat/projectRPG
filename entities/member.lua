local exp_data = require('data.exp_data')
local learn_data = require('data.learn_data')
local action_data = require('data.action_data')
local stat_gain = require('data.stat_gain')
local party_sprites = require('graphics.party_sprites')

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
    self.status = {}
    self.total_exp = data.total_exp
    self.strong = data.strong or {}
    self.immune = data.immune or {}
    self.sprite = party_sprites.get_sprite(data.sprite)
    self.is_dead = false
    self.weapon = data.weapon or nil
    self.armor = data.armor or nil
    self.shield = data.shield or nil
    self.can_equip = data.can_equip or {}

    function self:is_alive()
        return not self.is_dead
    end

    function self:level_up()
        self.lvl = self.lvl + 1;

        local data = stat_gain[self.id]
        local stat_index = math.ceil(self.lvl / 10)
        self.max_hp = self.max_hp + data['hp'][stat_index]
        self.max_mp = self.max_mp + data['mp'][stat_index]
        self.str = self.str + data['str'][stat_index]
        self.vit = self.vit + data['vit'][stat_index]
        self.agi = self.agi + data['agi'][stat_index]

        local skill_name = nil
        local skill_ref = learn_data[self.id][self.lvl] or nil
        if skill_ref then
            table.insert(self.skills, skill_ref)
            skill_name = action_data[skill_ref].name
        end

        return {
            member = self,
            lvl = self.lvl,
            skill = skill_name
        }
    end

    function self:increase_exp(exp)
        local level_ups = {}

        self.total_exp = self.total_exp + exp

        while self.total_exp >= exp_data[self.lvl + 1] do
            table.insert(level_ups, self:level_up())
        end

        return level_ups;
    end

    return self
end

return member