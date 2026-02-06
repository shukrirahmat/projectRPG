local createAction = require('createAction')

local function createBattle(_party, _enemies)

    local party = _party
    local enemies = _enemies
    local partyDefeated = false
    local enemiesDefeated = false
    local running = false
    local timer = 0
    local speed = 1
    local battleLog = {}

    local actionQueue = {}

    local function getParty()
        return party
    end

    local function getPartyMember(id)
        return party[id]
    end

    local function getEnemies()
        return enemies
    end

    local function setPartyAction()
        for i, member in ipairs(party) do
            if not member.getStat('dead') and member.getCurrentAction() then
                table.insert(actionQueue, member.getCurrentAction())
            end
        end
    end

    local function setEnemyAction()
        --For now just attack
        for i, enemy in ipairs(enemies) do
            if not enemy.getStat('dead') then
                local target = selectTargetRandomly(party)
                local action = createAction('normalAtk', enemy, target)
                table.insert(actionQueue, action)
            end
        end
    end

    local function isRunning()
        return running
    end

    local function getTimer()
        return timer
    end

    local function setTimer(_timer)
        timer = _timer
    end

    local function getSpeed()
        return speed
    end

    local function chooseNextActionIndex()
        local actionIndex
        local highestSpeed = 0
        for i, action in ipairs(actionQueue) do
            local agi = action.getUser().getStat('agi')
            local speed = agi + math.floor(math.random(-agi*0.5, agi*0.5))
            if speed > highestSpeed then
                highestSpeed = speed
                actionIndex = i
            end
        end
        return actionIndex
    end

    local function playAction()
        battleLog = {}
        local nextActionIndex = chooseNextActionIndex()
        local action = actionQueue[nextActionIndex]
        table.remove(actionQueue, nextActionIndex)

        if action.getTarget().getStat('dead') then
            local newTarget
            if action.getTarget().getStat('isPartyMember') then
                newTarget = selectTargetRandomly(party)
                action.setTarget(newTarget)
            else
                newTarget = selectTargetRandomly(enemies)
                action.setTarget(newTarget)
            end
        end
    end

    local function prepareNextRound(menu)
        for i, member in ipairs(party) do
            if member.getCurrentAction() then
                member.setCurrentAction(nil)
            end
        end

        battlelog = {}
        running = false
        menu.nextRound()
    end

    local function playQueue(menu)
        if #actionQueue > 0 then
            playAction()
        else
            prepareNextRound(menu)
        end
    end

    local function run()
        setPartyAction()
        setEnemyAction()
        timer = speed * 0.5
        running = true
    end

    return {
        getParty = getParty,
        getPartyMember = getPartyMember,
        getEnemies = getEnemies,
        run = run,
        isRunning = isRunning,
        getTimer = getTimer,
        setTimer = setTimer,
        getSpeed = getSpeed,
        playQueue = playQueue
    }
end

return createBattle