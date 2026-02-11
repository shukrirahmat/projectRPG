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

local function dealMPDamage(_, target, value)
    local burnAmount = value
    target.currentMp = target.currentMp - burnAmount;
    utils.battleLogAdd(''..target.name..' loses '..burnAmount..' MP.');
    if target.currentMp <= 0 then
        target.currentMp = 0;
    end
end

local function recovery(_, target, value)
    target.currentHp = math.min(target.maxHp, target.currentHp + value)
    utils.battleLogAdd(''..target.name..' recovers '..value..' HP.');
end

local function noEffect(_, target, value)
    utils.battleLogAdd('It had no effect on '..target.name..'');
end

local function noMp(user)
    utils.battleLogAdd('But '..user.name..' do not have enough mana!');
end

local function instakill(_, target)
    utils.battleLogAdd(''..target.name..' is instantly killed!');
    target.currentHp = 0;
    table.insert(state.killList, target)
end

local function missed(_, target)
    utils.battleLogAdd('It missed '..target.name..'!');
end


effectData['damage'] = { 
    apply = dealDamage , 
    partyAnimation = {ref='partyDamaged', maxTick=10, speed=0.05},
    enemyAnimation = {ref='enemyDamaged', maxTick=10, speed=0.08}
}

effectData['resisted'] = { 
    apply = dealDamage , 
    partyAnimation = {ref='partyDamaged', maxTick=10, speed=0.05},
    enemyAnimation = {ref='enemyResisted', maxTick=10, speed=0.08}
}
effectData['immune'] = { 
    apply = noEffect , 
    enemyAnimation = {ref='enemyImmune', maxTick=10, speed=0.08}
}

effectData['noMp'] = { 
    apply = noMp , 
}

effectData['recover'] = {
    apply = recovery
}

effectData['mpDamage'] = {
    apply = dealMPDamage,
    enemyAnimation = {ref='enemyManaBurned', maxTick=10, speed=0.08}
}

effectData['mpResisted'] = {
    apply = dealMPDamage,
    enemyAnimation = {ref='enemyManaBurned', maxTick=10, speed=0.08}
}

effectData['instakill'] = { 
    apply = instakill , 
}

effectData['missed'] = { 
    apply = missed , 
    enemyAnimation = {ref='enemyDodged', maxTick=10, speed=0.08}
}

return effectData