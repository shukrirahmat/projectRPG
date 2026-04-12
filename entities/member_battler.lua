local party_sprites = require('graphics.party_sprites')
local battler = require('entities.battler')

local member_battler = {}

function member_battler.new(data)
    local self = battler.new(data)

    self.name = data.name
    self.is_party_member = true
    self.member_id = data.id
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

return member_battler