local battler = require('entities.battler')
local enemy_sprites = require('graphics.enemy_sprites')
local fonts = require('fonts')

local enemy_battler = {}

function enemy_battler.new(data, name)

    local self = battler.new(data)

    self.ref = data.ref
    self.name = name
    self.crit_rate = 128
    self.sprite_height = data.sprite_height
    self.exp_drop = data.exp_drop
    self.gold_drop = data.gold_drop
    self.sprite = enemy_sprites.get_sprite(data.ref)
    self.species = data.species or nil

    return self
end

return enemy_battler