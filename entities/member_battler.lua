local battler = require('entities.battler')

local member_battler = {}

function member_battler.new(data)
    local self = battler.new(data)

    self.name = data.name
    self.is_party_member = true
    self.id = data.id
    self.party_ref = data
    self.crit_rate = 64
    self.total_exp = data.total_exp
    self.sprite = data.sprite

    return self
end

return member_battler