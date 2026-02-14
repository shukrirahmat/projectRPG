local state = require('state')
local utils = require('utils')
local effectCreator = require('effectCreator')

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

    for _, statusEf in ipairs({'SLEEP', 'CONFUSE'}) do
        if target.status[statusEf] then
            local roll = math.random(1,4)
            if roll == 1 then
                local clearEffect = effectCreator.new('clearStatus', user, target, statusEf)
                table.insert(state.effectList, clearEffect)
            end
        end
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
        target.status['BLIND'] = nil
        utils.battleLogAdd("Sand has been cleared in "..target.name.."'s eyes")
    elseif status == 'SEAL' then
        target.status['SEAL'] = nil
        utils.battleLogAdd(""..target.name.." abilites is no longer sealed")
    elseif status == 'STUN' then
        target.status['STUN'] = nil
        utils.battleLogAdd(""..target.name.." is no longer stunned")
    elseif status == 'WOUND' then
        target.status['WOUND'] = nil
        utils.battleLogAdd(""..target.name.."'s wound has been mended")
    elseif status == 'PARALYSIS' then
        target.status['PARALYSIS'] = nil
        utils.battleLogAdd(""..target.name.." is no longer paralyzed")
    elseif status == 'SLEEP' then
        target.status['SLEEP'] = nil
        utils.battleLogAdd(""..target.name.." is woken from sleep")
    elseif status == 'CONFUSE' then
        target.status['CONFUSE'] = nil
        utils.battleLogAdd(""..target.name.." is not confused anymore")
    elseif status == 'POISON' then
        target.status['POISON'] = nil
        for i, effect in ipairs(state.effectList) do
            if effect.ref == 'poisonDamage' then
                table.remove(state.effectList, i)
            end
        end
        utils.battleLogAdd(""..target.name.." recovered from poisoned")
    elseif status == 'CURSE' then
        target.status['CURSE'] = nil
        for i, effect in ipairs(state.effectList) do
            if effect.ref == 'curseEffect' then
                table.remove(state.effectList, i)
            end
        end
        utils.battleLogAdd("The curse have been removed from "..target.name.."")
    end
end

local function addStatChange(_, target, status)
    if status == 'DEFUP' then
        if target.status['DEFUP'] then
            if target.status['DEFUP'].stack < 2 then
                target.status['DEFUP'].stack = target.status['DEFUP'].stack + 1
                target.status['DEFUP'].countdown = 5
                utils.battleLogAdd(""..target.name.."'s defensive power is increased further");
            elseif target.status['DEFUP'].stack >= 2 then
                target.status['DEFUP'].countdown = 5
                utils.battleLogAdd(""..target.name.."'s defensive power is at maximum");
            end
        else
            target.status['DEFUP'] = { stack = 1, countdown = 5}
            utils.battleLogAdd(""..target.name.."'s defensive power is increased");
        end
        utils.updateStatChange(target, status)
    elseif status == 'AGIUP' then
        if target.status['AGIUP'] then
            if target.status['AGIUP'].stack < 2 then
                target.status['AGIUP'].stack = target.status['AGIUP'].stack + 1
                target.status['AGIUP'].countdown = 5
                utils.battleLogAdd(""..target.name.."'s agility is increased further");
            elseif target.status['AGIUP'].stack >= 2 then
                target.status['AGIUP'].countdown = 5
                utils.battleLogAdd(""..target.name.."'s agility is at maximum");
            end
        else
            target.status['AGIUP'] = { stack = 1, countdown = 5}
            utils.battleLogAdd(""..target.name.."'s agility is increased");
        end
        utils.updateStatChange(target, status)
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
    elseif status == 'PARALYSIS' then
        if target.status['PARALYSIS'] then
            utils.battleLogAdd(""..target.name.." is already paralyzed");
        else
            utils.battleLogAdd(""..target.name.." is paralyzed!");
        end
    elseif status == 'STUN' then
        if target.status['STUN'] then
            utils.battleLogAdd(""..target.name.." is already stunned");
        else
            utils.battleLogAdd(""..target.name.." is stunned!");
        end
    elseif status == 'SLEEP' then
        if target.status['SLEEP'] then
            utils.battleLogAdd(""..target.name.." is already asleep");
        else
            utils.battleLogAdd(""..target.name.." is put to sleep!");
        end
    elseif status == 'CONFUSE' then
        if target.status['CONFUSE'] then
            utils.battleLogAdd(""..target.name.." is already confused");
        else
            utils.battleLogAdd(""..target.name.." is confused!");
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

effectData['missedResist'] = { 
    apply = missed , 
    enemyAnimation = {ref='enemyDodgedResist', maxTick=10, speed=0.08}
}

effectData['addStatus'] = { 
    apply = addStatus
}

effectData['addStatChange'] = { 
    apply = addStatChange
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