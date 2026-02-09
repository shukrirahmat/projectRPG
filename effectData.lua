local state = require('state')
local utils = require('utils')

local effectData = {}


local function dealDamage(_, target, value)
    local damage = value
    if target.isDefending then
        damage = math.max(math.floor(damage/2), 1)
    end
    target.currentHp = target.currentHp - damage;
    utils.battleLogAdd(''..target.name..' takes '..damage..' damage.');
    if target.currentHp <= 0 then
        target.currentHp = 0;
        table.insert(state.killList, target)
    end
end


effectData['damage'] = { apply = dealDamage }

return effectData