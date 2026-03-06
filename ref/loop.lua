local battleState = require('battleState')
local utils = require('utils')
local animationCreator = require('animationCreator')
local actionCreator = require('actionCreator')
local actionData = require('actionData')
local effectCreator = require('effectCreator')
local effectData = require('effectData')
local levelHandler = require('levelHandler')
local gameState = require('gameState')

local loop = {}

local function nextPriorityIndex()
    local result
    local highestSpeed = -1

    for i, action in ipairs(battleState.priorityList) do
        local speed = actionData[action.ref].priority
        if speed > highestSpeed then
            highestSpeed = speed
            result = i
        end
    end

    return result
end

local function redirectTarget(action)
    if #action.targets == 1 and action.targets[1].isDead 
    and actionData[action.ref].aim ~= 'allies' then
        action.targets = {utils.reselectTargetWhenDead(action.targets[1])}
    end

    for i, target in ipairs(action.targets) do
        if not target.isDead and target.isCovered and actionData[action.ref].aim ~= 'allies' then
            if not target.isCovered.coveredBy.isDead then
                action.targets[i] = target.isCovered.coveredBy
            end
        end
    end

    return action
end

local function statusPass(action)
    local result = action
    if action.user.status['SLEEP'] then
        result = actionCreator.new('sleeping', action.user)
    elseif action.user.status['STUN'] then
        result = actionCreator.new('stunned', action.user)
    elseif action.user.status['PARALYSIS'] then
        local roll = math.random(1, 4)
        if roll == 1 then 
            result = actionCreator.new('paralyzed', action.user)
        else
            if action.user.status['CONFUSE'] then
                result = actionCreator.new('confused', action.user)
            end
        end
    elseif action.user.status['CONFUSE'] then
        result = actionCreator.new('confused', action.user)
    end
    return result
end

local function statusApply(action)
    local user = action.user

    if user.status['POISON'] then
        local rand = math.random(5, 20)
        local ratio = rand * 0.01
        local amount = math.floor(user.maxHp * ratio)
        local poisonEffect = effectCreator.new('poisonDamage', user, user, amount)
        table.insert(battleState.effectList, poisonEffect)
    end

    if user.status['CURSE'] then
        local max
        if user.isPartyMember then
            max = 20
        else
            max = 4
        end
        local roll = math.random(1, max)
        if roll == 1 then
            local curseEffect = effectCreator.new('curseEffect', user, user)
            table.insert(battleState.effectList, curseEffect)
        end
    end

    if user.passives['regenerate'] then
        local baseAmount = math.floor(user.maxHp * 0.1)
        local mod = math.floor(baseAmount*0.2)
        local amount = baseAmount + math.random(-mod, mod)
        local recoverEffect = effectCreator.new('recover', user, user, amount)
        table.insert(battleState.effectList, recoverEffect)
    end
end

local function statusClear(user, status, chance)
    local roll = math.random(0, 100)
    if roll <= chance then
        local clear = effectCreator.new('clearStatus', user, user, status)
        table.insert(battleState.effectList, clear)
    end
end

local function countDownStats(user, status)
    if user.status[status].countdown > 0 then
        user.status[status].countdown = user.status[status].countdown - 1;
    elseif user.status[status].countdown <= 0 then
        local clear = effectCreator.new('clearStatus', user, user, status)
        table.insert(battleState.effectList, clear)
    end
end

local function statusClearAll(action)
    local user = action.user

    if user.status['BLIND'] then
        statusClear(user,'BLIND', 10)
    end

    if user.status['SEAL'] then
        statusClear(user,'SEAL', 25)
    end

    if user.status['STUN'] then
        statusClear(user,'STUN', 60)
    end

    if user.status['STEEL'] then
        countDownStats(user, 'STEEL')
    end

    if user.status['FLEET'] then
        countDownStats(user, 'FLEET')
    end

    if user.status['FRAIL'] then
        countDownStats(user, 'FRAIL')
    end

    if user.status['SNARE'] then
        countDownStats(user, 'SNARE')
    end

    if user.status['BARRIER'] then
        countDownStats(user, 'BARRIER')
    end

    if user.status['MIGHT'] then
        countDownStats(user, 'MIGHT')
    end
end

function executeAction(action, isFollowUp)
    local toAct = actionData[action.ref]
    local canAct = true

    if toAct.magic or toAct.tech then
        if action.user.status['SEAL'] then
            canAct = false
        elseif isFollowUp then
            canAct = true
        elseif action.user.currentMp >= toAct.cost then
            action.user.currentMp = action.user.currentMp - toAct.cost
        else
            canAct = false
        end
    end

    if canAct then

        if action.combo then
            toAct.execute(toAct, action.user, action.targets, {combo = true})
        else
            toAct.execute(toAct, action.user, action.targets)
        end

        if action.user.usingItem then
            action.user.usingItem = nil
        end

        if not action.user.isPartyMember and toAct.enemyAnimation then
            local aniData = toAct.enemyAnimation
            local animation = animationCreator.new(
                action.user, aniData.ref, aniData.maxTick, aniData.speed
            )
            battleState.animation = animation
        elseif action.user.isPartyMember and action.ref == 'counterAtk' then
            local aniData = toAct.partyAnimation
            local animation = animationCreator.new(
                action.targets[1], aniData.ref, aniData.maxTick, aniData.speed
            )
            battleState.animation = animation
        end

        if toAct.magic then
            if action.user.passives['echoMagic'] and not isFollowUp then
                local roll = math.random(1, 4)
                if roll == 1 then
                    table.insert(battleState.followUp, action)
                end
            end
            if action.user.passives['manaSaver'] and not isFollowUp then
                local roll = math.random(1, 4)
                if roll == 1 then
                    local effect = effectCreator.new('mpRecover', action.user, action.user, toAct.cost)
                    table.insert(battleState.effectList, effect)
                end
            end
        end

    else
        local skillCanceled = actionData['skillCanceled']
        skillCanceled.execute(skillCanceled, action.user, action.targets, toAct)
    end
end

function applyEffect(effect)

    if effect.target.status and effect.target.status['GUARDIAN'] then
        effectData['immune'].apply(effect.user, effect.target, effect.value)
        return
    end

    effectData[effect.ref].apply(effect.user, effect.target, effect.value)

    if effect.target and effect.target.isPartyMember and effectData[effect.ref].partyAnimation then
        local data = effectData[effect.ref].partyAnimation
        local animation = animationCreator.new(
            effect.target, data.ref, data.maxTick, data.speed, effect.value
        )
        battleState.animation = animation
    elseif effect.target 
    and not effect.target.isPartyMember and effectData[effect.ref].enemyAnimation then
        local data = effectData[effect.ref].enemyAnimation
        local animation = animationCreator.new(
            effect.target, data.ref, data.maxTick, data.speed, effect.value
        )
        battleState.animation = animation
    end
end

--------------------------------------------

function loop.run()

    if battleState.battleEnded and #battleState.rewardQueue > 0 then
        local aliveMember = {}
        for i, member in ipairs(battleState.party) do
            if not member.isDead then
                table.insert(aliveMember, member)
            end
        end
        if battleState.rewardQueue[1] == 'gainExp' then
            local gainedExp = 0
            for i, enemy in ipairs(battleState.enemies) do
                gainedExp = gainedExp + enemy.exp;
            end
            for i, member in ipairs(aliveMember) do
                member.totalExp = member.totalExp + math.ceil(gainedExp / #aliveMember)
            end
            battleState.battleLog = {}
            utils.battleLogAdd('The party gained '..gainedExp..' EXP')
            table.remove(battleState.rewardQueue, 1)
            battleState.textTimer = 0
        elseif battleState.rewardQueue[1] == 'levelUp' then
            local hasLevelUp = false;
            for i, member in ipairs(aliveMember) do
                if member.totalExp >= levelHandler.expNeeded[member.lvl + 1] then
                    member.lvl = member.lvl + 1;
                    battleState.battleLog = {}
                    utils.battleLogAdd(''..member.name..' has leveled up to LVL'..member.lvl..'')

                    local gainRef = math.ceil(member.lvl/10)
                    member.maxHp = member.maxHp + levelHandler.statsGain[member.name]['hp'][gainRef]
                    utils.battleLogAdd('HP + '..levelHandler.statsGain[member.name]['hp'][gainRef]..'')
                    member.maxMp = member.maxMp + levelHandler.statsGain[member.name]['mp'][gainRef]
                    utils.battleLogAdd('MP + '..levelHandler.statsGain[member.name]['mp'][gainRef]..'')
                    member.str = member.str + levelHandler.statsGain[member.name]['str'][gainRef]
                    utils.battleLogAdd(
                        'STRENGTH + '..levelHandler.statsGain[member.name]['str'][gainRef]..'')
                    member.vit = member.vit + levelHandler.statsGain[member.name]['vit'][gainRef]
                    utils.battleLogAdd(
                        'VITALITY + '..levelHandler.statsGain[member.name]['vit'][gainRef]..'')
                    member.agi = member.agi + levelHandler.statsGain[member.name]['agi'][gainRef]
                    utils.battleLogAdd(
                        'AGILITY + '..levelHandler.statsGain[member.name]['agi'][gainRef]..'')

                    hasLevelUp = true
                    break
                end
            end
            if hasLevelUp then
                battleState.textTimer = 0
            else
                table.remove(battleState.rewardQueue, 1)
                battleState.textTimer = battleState.textSpeed
            end
        elseif battleState.rewardQueue[1] == 'gainGold' then
            local gainedGold = 0
            for i, enemy in ipairs(battleState.enemies) do
                gainedGold = gainedGold + enemy.droppedGold;
            end
            gameState.partyGold = gameState.partyGold + gainedGold
            battleState.battleLog = {}
            utils.battleLogAdd('The enemies dropped '..gainedGold..' gold')
            table.remove(battleState.rewardQueue, 1)
            battleState.textTimer = 0
        elseif battleState.rewardQueue[1] == 'quitBattle' then
            battleState.battleLog = {}
            battleState.textTimer = 0
        end
    elseif battleState.battleEnded then
        battleState.battleLog = {}
        if battleState.partyDied then
            utils.battleLogAdd('Party has been defeated')
        elseif battleState.allEnemyDead then
            utils.battleLogAdd('All enemy has been defeated')
        end
        battleState.rewardQueue = {'gainExp', 'levelUp', 'gainGold', 'quitBattle'}
        battleState.textTimer = 0
    elseif #battleState.killList > 0 then
        local toKill = battleState.killList[1]
        table.remove(battleState.killList, 1)
        utils.handleDeath(toKill)

        if not toKill.isPartyMember then
            battleState.animation = animationCreator.new(toKill, 'enemyDied', 8, 0.05)
        end

        if (battleState.partyDied or battleState.allEnemyDead) and #battleState.effectList == 0 then
            battleState.battleEnded = true
        end
        battleState.textTimer = 0

    elseif #battleState.effectList > 0 then
        local effect = battleState.effectList[1]
        table.remove(battleState.effectList, 1)

        if not effect.target.isDead or effect.ref == 'revive' 
        or effect.ref == 'stealGold' or effect.ref == 'stealItem' then
            applyEffect(effect)
            if effect.ref == 'instakill' then
                battleState.textTimer = 5
            else
                battleState.textTimer = 0
            end
        else
            battleState.textTimer = 5
        end        
    elseif #battleState.followUp > 0 then
        local action = battleState.followUp[1]
        table.remove(battleState.followUp, 1)

        local skip;

        if action.ref == 'secondAtk' or action.ref == 'counterAtk' then
            if action.targets[1].isDead or utils.checkCannotMove(action.targets[1]) then
                skip = true
            else
                battleState.battleLog = {};
                executeAction(action, true)
            end
        else
            battleState.battleLog = {};
            action = redirectTarget(action)
            executeAction(action, true)
        end

        if #battleState.followUp == 0 then
            statusApply(action)
            statusClearAll(action)
        end

        if skip then
            battleState.textTimer = 5
        else
            battleState.textTimer = 0
        end

    elseif #battleState.priorityList > 0 then
        battleState.battleLog = {};

        local actionIndex = nextPriorityIndex()
        local action = battleState.priorityList[actionIndex]
        table.remove(battleState.priorityList, actionIndex)

        action = redirectTarget(action)
        action = statusPass(action)
        executeAction(action)

        if #battleState.followUp == 0 then
            statusApply(action)
            statusClearAll(action)
        end
        battleState.textTimer = 0

    elseif #battleState.actionList > 0 then
        battleState.battleLog = {};
        local nextActionIndex = utils.chooseNextActionIndex()
        local action = battleState.actionList[nextActionIndex]
        table.remove(battleState.actionList, nextActionIndex)

        action = redirectTarget(action)
        action = statusPass(action)
        executeAction(action)

        if #battleState.followUp == 0 then
            statusApply(action)
            statusClearAll(action)
        end
        battleState.textTimer = 0

    else
        utils.clearTemporaryStatus()
        battleState.battleRunning = false
        battleState.battleLog = {}
        battleState.currentMenu = battleState.mainMenu
        battleState.mainMenu.position = 1
        battleState.textTimer = 0
    end
end

return loop