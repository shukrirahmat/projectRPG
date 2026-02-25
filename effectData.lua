local state = require('state')
local utils = require('utils')
local effectCreator = require('effectCreator')

local effectData = {}


local function dealDamage(_, target, value)
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

local function mpRecovery(_, target, value)
    local amount = math.min(target.maxMp - target.currentMp, value)
    target.currentMp = math.min(target.maxMp, target.currentMp + amount)
    utils.battleLogAdd(''..target.name..' recovers '..amount..' MP.');
end

local function revival(_, target, percentage)

    if percentage < 100 then
        percentage = math.random(1, percentage)
    end

    local hp = math.floor(target.maxHp * percentage * 0.01)
    target.isDead = false
    target.currentHp = hp

    utils.battleLogAdd(''..target.name..' has been revived');
end

local function noEffect(_, target, value)
    utils.battleLogAdd('It had no effect on '..target.name..'');
end

local function skillCanceled(user, target)
    if user.status['SEAL'] then
        utils.battleLogAdd('But '..user.name..' abilities were sealed!');
    else
        utils.battleLogAdd('But '..user.name..' do not have enough mana!');
    end
end

local function instakill(_, target)
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
    elseif status == 'DEFUP' then
        target.status['DEFUP'] = nil
        target.defBuff = nil
        utils.updateStatChange(target, 'def')
        utils.battleLogAdd(""..target.name.."'s defense increase has expired")
    elseif status == 'AGIUP' then
        target.status['AGIUP'] = nil
        target.agiBuff = nil
        utils.updateStatChange(target, 'agi')
        utils.battleLogAdd(""..target.name.."'s agility increase has expired")
    elseif status == 'DEFDOWN' then
        target.status['DEFDOWN'] = nil
        target.defDebuff = nil
        utils.updateStatChange(target, 'def')
        utils.battleLogAdd(""..target.name.."'s defense reduction has expired")
    elseif status == 'AGIDOWN' then
        target.status['AGIDOWN'] = nil
        target.agiDebuff = nil
        utils.updateStatChange(target, 'agi')
        utils.battleLogAdd(""..target.name.."'s agility reduction has expired")
    elseif status == 'MIGHT' then
        target.status['MIGHT'] = nil
        target.atkBuff = nil
        utils.updateStatChange(target, 'atk')
        utils.battleLogAdd(""..target.name.."'s attack power increase has expired")
    elseif status == 'BARRIER' then
        target.status['BARRIER'] = nil
        utils.battleLogAdd(""..target.name.."'s barrier has disappeared")
    end
end

local function addStatChange(_, target, status)

    local text
    if status == 'DEFUP' then
        text = {
            ""..target.name.."'s defensive power is increased",
            ""..target.name.."'s defensive power is increased further",
            ""..target.name.."'s defensive power is at maximum"
        }
    elseif status == 'DEFDOWN' then
        text = {
            ""..target.name.."'s defensive power is reduced",
            ""..target.name.."'s defensive power is reduced further",
            ""..target.name.."'s defensive power cannot be reduced further"
        }
    elseif status == 'AGIUP' then
        text = {
            ""..target.name.."'s agility is increased",
            ""..target.name.."'s agility is increased further",
            ""..target.name.."'s agility is at maximum"
        }
    elseif status == 'AGIDOWN' then
        text = {
            ""..target.name.."'s agility is reduced",
            ""..target.name.."'s agility is reduced further",
            ""..target.name.."'s agility cannot be reduced further"
        }
    elseif status == 'MIGHT' then
        text = {
            ""..target.name.."'s attack power is increased",
            ""..target.name.."'s attack power duration is reinforced"
        }
    end


    if target.status[status] then
        if status == 'MIGHT' then
            target.status[status].countdown = 5
            utils.battleLogAdd(text[2])
        else
            if target.status[status].stack < 2 then
                target.status[status].stack = target.status[status].stack + 1
                target.status[status].countdown = 5
                utils.battleLogAdd(text[2])
            elseif target.status[status].stack >= 2 then
                target.status[status].countdown = 5
                utils.battleLogAdd(text[3])
            end
        end
    else
        target.status[status] = { stack = 1, countdown = 5}
        utils.battleLogAdd(text[1])
    end

    if status == 'DEFUP' then
        target.defBuff = math.floor(target.baseDef * 0.5 * target.status['DEFUP'].stack)
        utils.updateStatChange(target, 'def')
    elseif status == 'DEFDOWN' then
        target.defDebuff = math.floor(target.baseDef * 0.5 * target.status['DEFDOWN'].stack)
        utils.updateStatChange(target, 'def')
    elseif status == 'AGIUP' then
        target.agiBuff = math.floor(target.baseAgi * 0.5 * target.status['AGIUP'].stack)
        utils.updateStatChange(target, 'agi')
    elseif status == 'AGIDOWN' then
        target.agiDebuff = math.floor(target.baseAgi * 0.5 * target.status['AGIDOWN'].stack)
        utils.updateStatChange(target, 'agi')
    elseif status == 'MIGHT' then
        target.atkBuff = math.floor(target.baseAtk * 0.75)
        utils.updateStatChange(target, 'atk')
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
    elseif status == 'BARRIER' then
        if target.status['BARRIER'] then
            target.status['BARRIER'].countdown = 5
            utils.battleLogAdd(""..target.name.."'s barrier duration is reinforced");
        else
            utils.battleLogAdd(""..target.name.." has gained protection from magic damage");
        end
    elseif status == 'GUARDIAN' then
        utils.battleLogAdd(""..target.name.." is engulfed by radiant light and could not move");
    end

    if status == 'BARRIER' then
        target.status['BARRIER'] = {countdown = 5}
    else    
        target.status[status] = true;
    end
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

local function stealItem(user, target, item)
    utils.battleLogAdd(''..user.name..' stole '..item.name..'');
    utils.manageItems(item, 1)
    target.stealableItem = nil
end

local function stealGold(user, target, amount)
    if target.isPartyMember then
        amount = math.min(amount, state.partyGold)
        state.partyGold = state.partyGold - amount;
    elseif not target.isPartyMember then
        amount = math.min(amount, target.stealableGold)
        target.stealableGold = target.stealableGold - amount;
    end

    if user.isPartyMember then
        state.partyGold = state.partyGold + amount
    elseif not user.isPartyMember then
        user.stealableGold = user.stealableGold + amount
    end

    utils.battleLogAdd(''..user.name..' stole '..amount..' Gold');
end

effectData['damage'] = { 
    apply = dealDamage , 
    partyAnimation = {ref='partyDamaged', maxTick=10, speed=0.05},
    enemyAnimation = {ref='enemyDamaged', maxTick=10, speed=0.08},
}

effectData['resisted'] = { 
    apply = dealDamage , 
    partyAnimation = {ref='partyDamaged', maxTick=10, speed=0.05},
    enemyAnimation = {ref='enemyResisted', maxTick=10, speed=0.08},
}
effectData['immune'] = { 
    apply = noEffect , 
    enemyAnimation = {ref='enemyImmune', maxTick=10, speed=0.08},
}

effectData['skillCanceled'] = { 
    apply = skillCanceled , 
}

effectData['recover'] = {
    apply = recovery,
}

effectData['mpRecover'] = {
    apply = mpRecovery,
}

effectData['revive'] = {
    apply = revival,
}

effectData['mpDamage'] = {
    apply = dealMPDamage,
    enemyAnimation = {ref='enemyManaBurned', maxTick=10, speed=0.08},
}

effectData['mpResisted'] = {
    apply = dealMPDamage,
    enemyAnimation = {ref='enemyManaBurned', maxTick=10, speed=0.08},
}

effectData['instakill'] = { 
    apply = instakill , 
}

effectData['missed'] = { 
    apply = missed , 
    enemyAnimation = {ref='enemyDodged', maxTick=10, speed=0.08},
}

effectData['missedResist'] = { 
    apply = missed , 
    enemyAnimation = {ref='enemyDodgedResist', maxTick=10, speed=0.08},
}

effectData['addStatus'] = { 
    apply = addStatus,
}

effectData['addStatChange'] = { 
    apply = addStatChange,
}

effectData['clearStatus'] = {
    apply = clearStatus,
}

effectData['poisonDamage'] = { 
    apply = poisonDamage , 
    partyAnimation = {ref='partyDamaged', maxTick=10, speed=0.05},
    enemyAnimation = {ref='enemyDamaged', maxTick=10, speed=0.08},
}

effectData['curseEffect'] = { 
    apply = curseEffect,
}

effectData['stealGold'] = { 
    apply = stealGold,
}

effectData['stealItem'] = { 
    apply = stealItem,
}

return effectData