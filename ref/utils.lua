local battleState = require('battleState')
local gameState = require('gameState')

local U = {}

-----MENU RELATED HELPERS-----

function U.drawMenuIndicator(x, y, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon(
        'fill',
        x,
        y + (height/2) - 10,
        x,
        y + (height/2) + 10,
        x + 10,
        y + (height/2)
    )
end

function U.shortenStatusName(status)
    if status == 'POISON' then return 'POSN'
    elseif status == 'CURSE' then return 'CRSE'
    elseif status == 'WOUND' then return 'WOUN'
    elseif status == 'BLIND' then return 'BLND'
    elseif status == 'PARALYSIS' then return 'PRLS'
    elseif status == 'SLEEP' then return 'SLPT'
    elseif status == 'CONFUSE' then return 'CNFS'
    elseif status == 'STEEL' then return 'DEF+'
    elseif status == 'FLEET' then return 'AGI+'
    elseif status == 'FRAIL' then return 'DEF-'
    elseif status == 'SNARE' then return 'AGI-'
    elseif status == 'BARRIER' then return 'BARR'
    elseif status == 'MIGHT' then return 'MGHT'
    elseif status == 'GUARDIAN' then return 'GRDN'
    else return status
    end
end

function U.updateTargetMenu(prevMenu, group)
    local targetList = {}
    for _, target in ipairs(group) do
        if not target.isDead then
            table.insert(targetList, target)
        end
    end
    battleState.targetMenu.list = targetList
    battleState.targetMenu.prevMenu = prevMenu
end

function U.updateDeadTargetMenu(prevMenu, group)
    local targetList = {}
    for _, target in ipairs(group) do
        if target.isDead then
            table.insert(targetList, target)
        end
    end
    battleState.targetMenu.list = targetList
    battleState.targetMenu.prevMenu = prevMenu
end

function U.updateSkillMenu(user)
    local skillList = {}
    if user.skills and #user.skills > 0 then
        for _, skill in ipairs(user.skills) do
            table.insert(skillList, skill)
        end
    end
    battleState.skillMenu.user = user
    battleState.skillMenu.list = skillList
end

function U.updateItemMenu(user)
    local itemList = {}
    for k, v in pairs(gameState.partyItems) do
        table.insert(itemList, {item= v.item, amount = v.amount })
    end

    table.sort(itemList, function(a, b) return a.item.id < b.item.id end)
    battleState.itemMenu.user = user
    battleState.itemMenu.list = itemList
end

function U.menuReset(menu)
    menu.position = 1
end

function U.menuUp(menu)
    menu.position = menu.position - 1
end

function U.menuDown(menu)
    menu.position = menu.position + 1
end

function U.getAbleCharID(currentID, where)
    local nextID
    local found = false
    local outOfBound

    if where == 'next' then
        nextID = currentID + 1
        outOfBound = nextID > #battleState.party 
    elseif where == 'prev' then
        nextID = currentID - 1
        outOfBound = nextID < 1
    end

    while not found and not outOfBound do
        local char = battleState.party[nextID]
        if not char.isDead 
        and not char.status['STUN']
        and not char.status['SLEEP']
        and not char.status['CONFUSE'] then
            found = true
        else
            if where == 'next' then
                nextID = nextID + 1
                outOfBound = nextID > #battleState.party 
            elseif where == 'prev' then
                nextID = nextID - 1
                outOfBound = nextID < 1
            end
        end
    end

    if found then
        return nextID
    else
        return nil
    end
end

------------HANDLING BATTLES----------------

function U.battleLogAdd(text)
    if #battleState.battleLog >= 8 then
        table.remove(battleState.battleLog, 1)
    end

    table.insert(battleState.battleLog, text)
end

function U.selectTargetRandomly(group)
    local availableTargets = {}

    for _, target in ipairs(group) do
        if not target.isDead then
            table.insert(availableTargets, target)
        end
    end

    local selectedTarget
    local i = 1

    while not selectedTarget do
        if i == #availableTargets then
            selectedTarget = availableTargets[i]
        else
            local chance = math.random(1, 10)
            if chance < 5 then
                i = i + 1
            else
                selectedTarget = availableTargets[i]
            end
        end
    end

    return selectedTarget
end

function U.chooseNextActionIndex()
    local actionIndex
    local highestSpeed = -1
    for index, action in ipairs(battleState.actionList) do
        local agi = action.user.agi
        local mod = math.floor(agi*0.5)
        local speed = agi + (math.random(-mod, mod))
        if speed > highestSpeed then
            highestSpeed = speed
            actionIndex = index
        end
    end
    return actionIndex
end

function U.reselectTargetWhenDead(selectedTarget)
    local target
    if selectedTarget.isPartyMember then
        target = U.selectTargetRandomly(battleState.party)
    else
        target = U.selectTargetRandomly(battleState.enemies)
    end
    return target
end

local function checkIfAllDead(group)
    local totalDead = 0
    for _, member in ipairs(group) do
        if member.isDead then
            totalDead = totalDead + 1
        end
    end
    return totalDead == #group;
end

function U.removeAction(user)
    for index, action in ipairs(battleState.actionList) do
        if action.user == user then
            table.remove(battleState.actionList, index)
        end
    end

    for index, action in ipairs(battleState.priorityList) do
        if action.user == user then
            table.remove(battleState.priorityList, index)
        end
    end
end

function U.handleDeath(target)
    target.currentHp = 0
    target.isDead = true
    target.status = {}
    U.battleLogAdd(''..target.name..' defeated.')
    U.removeAction(target)

    if target.isPartyMember and checkIfAllDead(battleState.party) then
        battleState.partyDied = true
    elseif not target.isPartyMember and checkIfAllDead(battleState.enemies) then
        battleState.allEnemyDead = true
    end
end

function U.clearTemporaryStatus()

    battleState.followUp = {}

    for _, group in ipairs({battleState.party, battleState.enemies}) do
        for _, character in ipairs(group) do

            if character.isDefending then
                character.isDefending = false
            end

            if character.isAuraCharged then
                character.isAuraCharged.counter = character.isAuraCharged.counter - 1
                if character.isAuraCharged.counter <= 0 then
                    character.isAuraCharged = nil
                end
            end

            if character.isFocused then
                character.isFocused.counter = character.isFocused.counter - 1
                if character.isFocused.counter <= 0 then
                    character.isFocused = nil
                end
            end

            if character.status['GUARDIAN'] then
                character.status['GUARDIAN'] = nil
            end

            if character.isCovered then
                character.isCovered = nil
            end
            
            if character.usingItem then
                U.manageItems(character.usingItem, 1)
                character.usingItem = nil
            end
        end
    end
end

function U.updateStatChange(target, stat)
    if stat == 'def' then
        local buff = target.defBuff or 0
        local debuff = target.defDebuff or 0
        target.def = target.baseDef + buff - debuff
    elseif stat == 'agi' then
        local buff = target.agiBuff or 0
        local debuff = target.agiDebuff or 0
        target.agi = target.baseAgi + buff - debuff
    elseif stat == 'atk' then
        local buff = target.atkBuff or 0
        target.atk = target.baseAtk + buff
    end
end

function U.manageItems(item, mod)
    if gameState.partyItems[item.ref] then
        gameState.partyItems[item.ref].amount = gameState.partyItems[item.ref].amount + mod
    elseif not gameState.partyItems[item.ref] and mod > 0 then
        gameState.partyItems[item.ref] = {item = item , amount = mod}
    end

    if gameState.partyItems[item.ref].amount < 1 then
        gameState.partyItems[item.ref] = nil
    end
end

---------------CALCULATOR----------------

function U.calculateAttackDamage(attacker, target)    

    local pierce = 1
    if target.specialType == 'ARMORED' and attacker.passives['piercer'] then
        pierce = 2
    end

    local damage = math.floor(attacker.atk/2) - math.floor(target.def/(3 * pierce))
    local mod = math.floor(damage*0.2)
    damage = damage + math.floor(math.random(-mod, mod))
    return math.max(damage, 1)
end

function U.calculateCritDamage(attacker, target)

    local pierce = 1
    if target.specialType == 'ARMORED' and attacker.passives['piercer'] then
        pierce = 2
    end

    local damage = math.floor(attacker.atk/2 * 3) - math.floor(target.def/(6 * pierce))
    local mod = math.floor(damage*0.2)
    damage = damage + math.floor(math.random(-mod, mod))
    return math.max(damage, 1)
end

function U.checkResistance(element, target)
    if target.immune[element] then return 2 end
    if target.strong[element] then return 1 end
    return 0
end

function U.checkCannotMove(target)
    if target.status['STUN'] then return true end
    if target.status['SLEEP'] then return true end
    if target.status['CONFUSE'] then return true end
    return false
end



return U