local state = require('state')
local utils = require('utils')

local effectData = {}


local function dealDamage(_, target, value)
    target.currentHp = target.currentHp - value;
    utils.battleLogAdd(''..target.name..' takes '..value..' damage.');
    if target.currentHp <= 0 then
        target.currentHp = 0;
        table.insert(state.killList, target)
    end
end


effectData['damage'] = { apply = dealDamage }

return effectData