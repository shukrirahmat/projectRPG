local battleLog = require('states.battle.battleLog')

local effects = {}

local function dealDamage(state, user, target, value)
    local damage = value
    if target.isDefending then
        damage = math.max(math.floor(damage/2), 1)
    end

    if target.passives['lastStand'] then
        if damage >= target.currentHp and target.currentHp > 1 then
            damage = target.currentHp - 1;
        end
    end
    
    target.currentHp = target.currentHp - damage;
    battleLog.addText(state, ''..target.name..' takes '..damage..' damage.');
    if target.currentHp <= 0 then
        target.currentHp = 0;
        table.insert(state.killQueue, target)
    end

    for _, statusEf in ipairs({'SLEEP', 'CONFUSE'}) do
        if target.status[statusEf] then
            local roll = math.random(1,4)
            if roll == 1 then
                local clearEffect = effectCreator.new('clearStatus', user, target, statusEf)
                table.insert(state.effectQueue, clearEffect)
            end
        end
    end
end

return effects