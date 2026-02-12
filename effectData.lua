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
    local amount = math.min(target.maxHp - target.currentHp, value)
    
    if target.status['WOUND'] then
        amount = math.floor(amount * 0.5)
    end
    
    target.currentHp = math.min(target.maxHp, target.currentHp + amount)
    utils.battleLogAdd(''..target.name..' recovers '..amount..' HP.');
end

local function noEffect(_, target, value)
    utils.battleLogAdd('It had no effect on '..target.name..'');
end

local function skillCanceled(user)
    if user.status['SEAL'] then
        utils.battleLogAdd('But '..user.name..' abilities were sealed!');
    else
        utils.battleLogAdd('But '..user.name..' do not have enough mana!');
    end
end

local function instakill(_, target)
    utils.battleLogAdd(''..target.name..' is instantly killed!');
    target.currentHp = 0;
    table.insert(state.killList, target)
end

local function missed(_, target)
    utils.battleLogAdd('It missed '..target.name..'!');
end

local function clearStatus(user, target, status)
    if status == 'BLIND' then
        user.status['BLIND'] = nil
        utils.battleLogAdd(""..target.name.." cleared the sand from their eyes")
    elseif status == 'SEAL' then
        user.status['SEAL'] = nil
        utils.battleLogAdd(""..target.name.." abilites is no longer sealed")
    elseif status == 'STUN' then
        user.status['STUN'] = nil
        utils.battleLogAdd(""..target.name.." is no longer stunned")
    end
end

local function addStatus(_, target, status)
    if status == 'BLIND' then
        if target.status['BLIND'] then
            utils.battleLogAdd(""..target.name.." is already blinded");
        else
            utils.battleLogAdd("Sand got into "..target.name.."'s eyes!");
        end
    elseif status == 'SEAL' then
        if target.status['SEAL'] then
            utils.battleLogAdd(""..target.name.." is already sealed");
        else
            utils.battleLogAdd(""..target.name.."'s abilities are sealed!");
        end
    elseif status == 'STUN' then
        if target.status['STUN'] then
            utils.battleLogAdd(""..target.name.." is already stunned");
        else
            utils.battleLogAdd(""..target.name.." is stunned!");
        end
    elseif status == 'WOUND' then
        if target.status['WOUND'] then
            utils.battleLogAdd(""..target.name.." is already wounded");
        else
            utils.battleLogAdd(""..target.name.." is wounded. Healing is reduced!");
        end
    elseif status == 'POISON' then
        if target.status['POISON'] then
            utils.battleLogAdd(""..target.name.." is already poisoned");
        else
            utils.battleLogAdd(""..target.name.." is poisoned!");
        end
    elseif status == 'CURSE' then
        if target.status['CURSE'] then
            utils.battleLogAdd(""..target.name.." is already cursed");
        else
            utils.battleLogAdd(""..target.name.." is cursed!");
        end
    end

    target.status[status] = true;
end

local function poisonDamage(_, target, value)
    local damage = value
    target.currentHp = target.currentHp - damage;
    utils.battleLogAdd(''..target.name..' loses '..damage..' HP to poison.');
    if target.currentHp <= 0 then
        target.currentHp = 0;
        table.insert(state.killList, target)
    end
end

local function curseEffect(_, target)
    utils.battleLogAdd(''..target.name..' died from the curse');
    target.currentHp = 0;
    table.insert(state.killList, target)
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

effectData['skillCanceled'] = { 
    apply = skillCanceled , 
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

effectData['addStatus'] = { 
    apply = addStatus , 
}

effectData['clearStatus'] = {
    apply = clearStatus
}

effectData['poisonDamage'] = { 
    apply = poisonDamage , 
    partyAnimation = {ref='partyDamaged', maxTick=10, speed=0.05},
    enemyAnimation = {ref='enemyDamaged', maxTick=10, speed=0.08}
}

effectData['curseEffect'] = { 
    apply = curseEffect
}

return effectData