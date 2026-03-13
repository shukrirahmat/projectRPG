local battleLog = require('states.battle.battleLog')
local battleHandler = require('states.battle.battleHandler')
local itemManager = require('systems.itemManager')
local gameState = require('gameState')
local effectCreator = require('entities.effectCreator')

local effects = {}

function effects.dealDamage(state, user, target, value)
    local damage = value
    target.currentHp = target.currentHp - damage;
    battleLog.addText(state, ''..target.name..' takes '..damage..' damage.');
    if target.currentHp <= 0 then
        table.insert(state.killQueue, target)
    end

    for _, statusEf in ipairs({'SLEEP', 'CONFUSE'}) do
        if target.status[statusEf] then
            local roll = math.random(1,2)
            if roll == 1 then
                local clearEffect = effectCreator.new('clearStatus', user, target, statusEf)
                table.insert(state.effectQueue, clearEffect)
            end
        end
    end
end

function effects.noEffect(state, user, target)
    battleLog.addText(state,'It had no effect on '..target.name..'');
end

function effects.nothingHappens(state, user, target)
    battleLog.addText(state,'But nothing happens!')
end

function effects.instakill(state, user, target)
    target.currentHp = 0;
    table.insert(state.killQueue, target)
end

function effects.missed(state, user, target)
    battleLog.addText(state, 'It missed '..target.name..'!');
end

function effects.skillCanceled(state, user, target)
    if user.status['SEAL'] then
        battleLog.addText(state, 'But '..user.name..' abilities were sealed!');
    else
        battleLog.addText(state, 'But '..user.name..' do not have enough mana!');
    end
end

function effects.recovery(state, user, target, value)
    local amount = math.min(target.maxHp - target.currentHp, value)
    target.currentHp = math.min(target.maxHp, target.currentHp + amount)
    battleLog.addText(state,''..target.name..' recovers '..amount..' HP.');
end

function effects.dealMPDamage(state, user, target, value)
    local burnAmount = value
    target.currentMp = target.currentMp - burnAmount;
    battleLog.addText(state, ''..target.name..' loses '..burnAmount..' MP.');
    if target.currentMp <= 0 then
        target.currentMp = 0;
    end
end

function effects.poisonDamage(state, user, target, value)
    local damage = value
    target.currentHp = target.currentHp - damage;
    battleLog.addText(state, ''..target.name..' loses '..damage..' HP to poison.');
    if target.currentHp <= 0 then
        table.insert(state.killQueue, target)
    end
end

function effects.curseEffect(state, user, target)
    battleLog.addText(state, ''..target.name..' died from the curse.');
    table.insert(state.killQueue, target)
end

function effects.stealItem(state, user, target, item)
    battleLog.addText(state, ''..user.name..' stole '..item.name..'');
    itemManager.manageItems(item, 1)
    target.stealableItem = nil
end

function effects.stealGold(state, user, target, amount)
    if target.isPartyMember then
        amount = math.min(amount, gameState.partyGold)
        gameState.partyGold = gameState.partyGold - amount;
    elseif not target.isPartyMember then
        amount = math.min(amount, target.stealableGold)
        target.stealableGold = target.stealableGold - amount;
    end

    if user.isPartyMember then
        gameState.partyGold = gameState.partyGold + amount
    elseif not user.isPartyMember then
        user.stealableGold = user.stealableGold + amount
    end

    battleLog.addText(state, ''..user.name..' stole '..amount..' Gold');
end

function effects.addStatus(state, user, target, status)
    if status == 'BLIND' then
        if target.status['BLIND'] then
            battleLog.addText(state, ""..target.name.." is already blinded");
        else
            battleLog.addText(state, "Sand got into "..target.name.."'s eyes!");
        end
    elseif status == 'SEAL' then
        if target.status['SEAL'] then
            battleLog.addText(state, ""..target.name.." is already sealed");
        else
            battleLog.addText(state, ""..target.name.."'s abilities are sealed!");
        end
    elseif status == 'WOUND' then
        if target.status['WOUND'] then
            battleLog.addText(state, ""..target.name.." is already wounded");
        else
            battleLog.addText(state, ""..target.name.." is wounded. Healing is reduced!");
        end
    elseif status == 'POISON' then
        if target.status['POISON'] then
            battleLog.addText(state, ""..target.name.." is already poisoned");
        else
            battleLog.addText(state, ""..target.name.." is poisoned!");
        end
    elseif status == 'CURSE' then
        if target.status['CURSE'] then
            battleLog.addText(state, ""..target.name.." is already cursed");
        else
            battleLog.addText(state, ""..target.name.." is cursed!");
        end
    elseif status == 'PARALYSIS' then
        if target.status['PARALYSIS'] then
            battleLog.addText(state, ""..target.name.." is already paralyzed");
        else
            battleLog.addText(state, ""..target.name.." is paralyzed!");
        end
    elseif status == 'STUN' then
        if target.status['STUN'] then
            battleLog.addText(state, ""..target.name.." is already stunned");
        else
            battleLog.addText(state, ""..target.name.." is stunned!");
        end
    elseif status == 'SLEEP' then
        if target.status['SLEEP'] then
            battleLog.addText(state, ""..target.name.." is already asleep");
        else
            battleLog.addText(state, ""..target.name.." is put to sleep!");
        end
    elseif status == 'CONFUSE' then
        if target.status['CONFUSE'] then
            battleLog.addText(state, ""..target.name.." is already confused");
        else
            battleLog.addText(state, ""..target.name.." is confused!");
        end
    elseif status == 'BARRIER' then
        if target.status['BARRIER'] then
            target.status['BARRIER'].countdown = 5
            battleLog.addText(state, ""..target.name.."'s barrier duration is reinforced");
        else
            battleLog.addText(state, ""..target.name.." has gained protection from magic damage");
        end
    end

    if status == 'BARRIER' then
        target.status['BARRIER'] = {countdown = 5}
    else    
        target.status[status] = true;
    end
end

function effects.addStatChange(state, user, target, status)

    local text
    if status == 'STEEL' then
        text = {
            ""..target.name.."'s defensive power is increased",
            ""..target.name.."'s defensive power is increased further",
            ""..target.name.."'s defensive power is at maximum"
        }
    elseif status == 'FRAIL' then
        text = {
            ""..target.name.."'s defensive power is reduced",
            ""..target.name.."'s defensive power is reduced further",
            ""..target.name.."'s defensive power cannot be reduced further"
        }
    elseif status == 'FLEET' then
        text = {
            ""..target.name.."'s agility is increased",
            ""..target.name.."'s agility is increased further",
            ""..target.name.."'s agility is at maximum"
        }
    elseif status == 'SNARE' then
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
            battleLog.addText(state, text[2])
        else
            if target.status[status].stack < 2 then
                target.status[status].stack = target.status[status].stack + 1
                target.status[status].countdown = 5
                battleLog.addText(state, text[2])
            elseif target.status[status].stack >= 2 then
                target.status[status].countdown = 5
                battleLog.addText(state, text[3])
            end
        end
    else
        target.status[status] = { stack = 1, countdown = 5}
        battleLog.addText(state, text[1])
    end

    if status == 'STEEL' then
        target.defBuff = math.floor(target.baseDef * 0.4 * target.status['STEEL'].stack)
        battleHandler.updateStatChange(target, 'def')
    elseif status == 'FRAIL' then
        target.defDebuff = math.floor(target.baseDef * 0.4 * target.status['FRAIL'].stack)
        battleHandler.updateStatChange(target, 'def')
    elseif status == 'FLEET' then
        target.agiBuff = math.floor(target.baseAgi * 0.4 * target.status['FLEET'].stack)
        battleHandler.updateStatChange(target, 'agi')
    elseif status == 'SNARE' then
        target.agiDebuff = math.floor(target.baseAgi * 0.4 * target.status['SNARE'].stack)
        battleHandler.updateStatChange(target, 'agi')
    elseif status == 'MIGHT' then
        target.atkBuff = math.floor(target.baseAtk * 0.8)
        battleHandler.updateStatChange(target, 'atk')
    end
end

function effects.clearStatus(state, user, target, status)
    if status == 'BLIND' then
        target.status['BLIND'] = nil
        battleLog.addText(state, "Sand has been cleared in "..target.name.."'s eyes.")
    elseif status == 'SEAL' then
        target.status['SEAL'] = nil
        battleLog.addText(state, ""..target.name.." abilites is no longer sealed.")
    elseif status == 'STUN' then
        target.status['STUN'] = nil
        battleLog.addText(state, ""..target.name.." is no longer stunned.")
    elseif status == 'WOUND' then
        target.status['WOUND'] = nil
        battleLog.addText(state, ""..target.name.."'s wound has been mended.")
    elseif status == 'PARALYSIS' then
        target.status['PARALYSIS'] = nil
        battleLog.addText(state, ""..target.name.." is no longer paralyzed.")
    elseif status == 'SLEEP' then
        target.status['SLEEP'] = nil
        battleLog.addText(state, ""..target.name.." is woken from sleep.")
    elseif status == 'CONFUSE' then
        target.status['CONFUSE'] = nil
        battleLog.addText(state, ""..target.name.." is not confused anymore.")
    elseif status == 'POISON' then
        target.status['POISON'] = nil
        for i, effect in ipairs(state.effectQueue) do
            if effect.ref == 'poisonDamage' then
                table.remove(state.effectQueue, i)
            end
        end
        battleLog.addText(state, ""..target.name.." recovered from poisoned.")
    elseif status == 'CURSE' then
        target.status['CURSE'] = nil
        for i, effect in ipairs(state.effectQueue) do
            if effect.ref == 'curseEffect' then
                table.remove(state.effectQueue, i)
            end
        end
        battleLog.addText(state, "The curse have been lifted from "..target.name..".")
    elseif status == 'STEEL' then
        target.status['STEEL'] = nil
        target.defBuff = nil
        battleHandler.updateStatChange(target, 'def')
        battleLog.addText(state, ""..target.name.."'s defense increase has expired.")
    elseif status == 'FLEET' then
        target.status['FLEET'] = nil
        target.agiBuff = nil
        battleHandler.updateStatChange(target, 'agi')
        battleLog.addText(state, ""..target.name.."'s agility increase has expired.")
    elseif status == 'FRAIL' then
        target.status['FRAIL'] = nil
        target.defDebuff = nil
        battleHandler.updateStatChange(target, 'def')
        battleLog.addText(state, ""..target.name.."'s defense reduction has expired")
    elseif status == 'SNARE' then
        target.status['SNARE'] = nil
        target.agiDebuff = nil
        utils.updateStatChange(target, 'agi')
        battleLog.addText(state, ""..target.name.."'s agility reduction has expired.")
    elseif status == 'MIGHT' then
        target.status['MIGHT'] = nil
        target.atkBuff = nil
        battleHandler.updateStatChange(target, 'atk')
        battleLog.addText(state, ""..target.name.."'s attack power increase has expired.")
    elseif status == 'BARRIER' then
        target.status['BARRIER'] = nil
        battleLog.addText(state, ""..target.name.."'s barrier has disappeared.")
    end
end

return effects