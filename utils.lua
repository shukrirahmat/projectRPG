local state = require('state')

local U = {}

-----MENU RELATED HELPERS-----

function U.shortenStatusName(status)
    if status == 'POISON' then return 'POSN'
    elseif status == 'CURSE' then return 'CRSE'
    elseif status == 'WOUND' then return 'WOUN'
    elseif status == 'BLIND' then return 'BLND'
    elseif status == 'PARALYSIS' then return 'PRLS'
    elseif status == 'SLEEP' then return 'SLPT'
    elseif status == 'CONFUSE' then return 'CNFS'
    elseif status == 'DEFUP' then return 'DEF+'
    elseif status == 'AGIUP' then return 'AGI+'
    elseif status == 'DEFDOWN' then return 'DEF-'
    elseif status == 'AGIDOWN' then return 'AGI-'
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
    state.targetMenu.list = targetList
    state.targetMenu.prevMenu = prevMenu
end

function U.updateSkillMenu(user)
    local skillList = {}
    if user.skills and #user.skills > 0 then
        for _, skill in ipairs(user.skills) do
            table.insert(skillList, skill)
        end
    end
    state.skillMenu.user = user
    state.skillMenu.list = skillList
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
        outOfBound = nextID > #state.party 
    elseif where == 'prev' then
        nextID = currentID - 1
        outOfBound = nextID < 1
    end

    while not found and not outOfBound do
        local char = state.party[nextID]
        if not char.isDead 
        and not char.status['STUN']
        and not char.status['SLEEP']
        and not char.status['CONFUSE'] then
            found = true
        else
            if where == 'next' then
                nextID = nextID + 1
                outOfBound = nextID > #state.party 
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
    if #state.battleLog >= 8 then
        table.remove(state.battleLog, 1)
    end

    table.insert(state.battleLog, text)
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
    for index, action in ipairs(state.actionList) do
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
        target = U.selectTargetRandomly(state.party)
    else
        target = U.selectTargetRandomly(state.enemies)
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

local function removeAction(user)
    for index, action in ipairs(state.actionList) do
        if action.user == user then
            table.remove(state.actionList, index)
        end
    end

    for index, action in ipairs(state.priorityList) do
        if action.user == user then
            table.remove(state.priorityList, index)
        end
    end
end

function U.handleDeath(target)
    target.currentHp = 0
    target.isDead = true
    target.status = {}
    U.battleLogAdd(''..target.name..' defeated.')
    removeAction(target)

    if target.isPartyMember and checkIfAllDead(state.party) then
        state.partyDied = true
    elseif not target.isPartyMember and checkIfAllDead(state.enemies) then
        state.allEnemyDead = true
    end
end

function U.clearTemporaryStatus()

    state.followUp = nil

    for _, group in ipairs({state.party, state.enemies}) do
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
    end
end

---------------CALCULATOR----------------

function U.calculateAttackDamage(attacker, target)
    local damage = math.floor(attacker.atk/2) - math.floor(target.def/3)
    local mod = math.floor(damage*0.2)
    damage = damage + math.floor(math.random(-mod, mod))
    return math.max(damage, 1)
end

function U.calculateCritDamage(attacker, target)
    local damage = math.floor(attacker.atk/2 * 3) - math.floor(target.def/6)
    local mod = math.floor(damage*0.2)
    damage = damage + math.floor(math.random(-mod, mod))
    return math.max(damage, 1)
end

function U.checkResistance(element, target)
    if target.immune[element] then return 2 end
    if target.strong[element] then return 1 end
    return 0
end

return U