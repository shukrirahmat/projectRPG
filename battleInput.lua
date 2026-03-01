local battleState = require('battleState')
local utils = require('utils')
local actionCreator = require('actionCreator')
local actionData = require('actionData')

local battleInput = {}

function battleInput.sendActionIntoQueue(action)
    local actionDetails = actionData[action.ref]    
    if actionDetails.priority then
        table.insert(battleState.priorityList, action)
    else
        table.insert(battleState.actionList, action)
    end
end

local function setPartyAction()
    for _, member in ipairs(battleState.party) do
        if not member.isDead then
            local action
            if member.status['STUN'] or member.status['SLEEP'] or member.status['CONFUSE'] then
                local target = utils.selectTargetRandomly(battleState.enemies)
                action = actionCreator.new('normalAtk', member, {target})
            elseif member.currentAction then
                action = member.currentAction
            end
            battleInput.sendActionIntoQueue(action)
            member.currentAction = nil
        end
    end
end

local function setEnemyAction()
    for _, enemy in ipairs(battleState.enemies) do
        if not enemy.isDead then
            local action
            if enemy.status['STUN'] or enemy.status['SLEEP'] or enemy.status['CONFUSE'] then
                local target = utils.selectTargetRandomly(battleState.party)
                action = actionCreator.new('normalAtk', enemy, {target})
            else
                local choices = {unpack(enemy.skills)}
                local target = utils.selectTargetRandomly(battleState.party)

                local rand = math.random(0, #choices or 0)
                if rand == 0 then
                    action = actionCreator.new('normalAtk', enemy, {target})
                else
                    local skillRef = choices[rand]
                    local skill = actionData[skillRef]
                    local targets;
                    if skill.aim == 'allies' then 
                        targets = battleState.enemies
                    elseif skill.aim == 'enemies' then
                        targets = battleState.party
                    end
                    if skill.scope == 'single' then
                        local target = utils.selectTargetRandomly(targets)
                        action = actionCreator.new(skillRef, enemy, {target})
                    elseif skill.scope == 'all' then
                        action = actionCreator.new(skillRef, enemy, {unpack(targets)})
                    elseif skill.scope == 'self' then
                        action = actionCreator(skillRef, enemy, {enemy})
                    end
                end
            end
            battleInput.sendActionIntoQueue(action)
        end
    end
end

local function runBattle()
    setPartyAction()
    setEnemyAction()
    battleState.battleRunning = true
    battleState.textTimer = 0.5
end

local function nextCharacter(currentID)
    local nextID = utils.getAbleCharID(currentID, 'next')
    if nextID then
        battleState.currentMenu = battleState.characterMenu
        battleState.characterMenu.charID = nextID
        utils.menuReset(battleState.characterMenu)
    else
        runBattle()
    end
end

local function addAttackAction(target)
    local user = battleState.party[battleState.characterMenu.charID]
    local action = actionCreator.new('normalAtk', user, {target})
    user.currentAction = action
end

function battleInput.executeLeft()
    if battleState.currentMenu == battleState.skillMenu or battleState.currentMenu == battleState.itemMenu then
        if battleState.currentMenu.position % 2 == 0
        and battleState.currentMenu.position - 1 >= 1 then
            utils.menuUp(battleState.currentMenu)
        end
    end
end

function battleInput.executeRight()
    if battleState.currentMenu == battleState.skillMenu or battleState.currentMenu == battleState.itemMenu then
        if battleState.currentMenu.position % 2 ~= 0
        and battleState.currentMenu.position + 1 <= #battleState.currentMenu.list then
            utils.menuDown(battleState.currentMenu)
        end
    end
end

function battleInput.executeDown()
    if battleState.currentMenu == battleState.skillMenu or battleState.currentMenu == battleState.itemMenu then
        if battleState.currentMenu.position + 2 <= #battleState.currentMenu.list then
            utils.menuDown(battleState.currentMenu)
            utils.menuDown(battleState.currentMenu)
        elseif battleState.currentMenu.position + 1 == #battleState.currentMenu.list then
            utils.menuDown(battleState.currentMenu)
        end
    else
        if battleState.currentMenu.position < #battleState.currentMenu.list then
            utils.menuDown(battleState.currentMenu)
        end
    end
end

function battleInput.executeUp()
    if battleState.currentMenu == battleState.skillMenu or battleState.currentMenu == battleState.itemMenu then
        if battleState.currentMenu.position - 2 >= 1 then
            utils.menuUp(battleState.currentMenu)
            utils.menuUp(battleState.currentMenu)
        end
    else
        if battleState.currentMenu.position > 1 then
            utils.menuUp(battleState.currentMenu)
        end
    end
end

function battleInput.executeConfirm()
    if battleState.currentMenu == battleState.mainMenu then
        nextCharacter(0)
    elseif battleState.currentMenu == battleState.characterMenu then
        local char = battleState.party[battleState.characterMenu.charID]
        if battleState.characterMenu.position == 1 then
            utils.updateTargetMenu(battleState.characterMenu, battleState.enemies)
            if #battleState.targetMenu.list == 1 then
                local target = battleState.enemies[1]
                addAttackAction(target)
                local currentID = battleState.characterMenu.charID
                nextCharacter(currentID)
            elseif #battleState.targetMenu.list > 1 then
                battleState.currentMenu = battleState.targetMenu
                utils.menuReset(battleState.targetMenu)
            end
        elseif battleState.characterMenu.position == 2 and not char.status['SEAL'] then
            utils.updateSkillMenu(char)
            battleState.currentMenu = battleState.skillMenu
            utils.menuReset(battleState.skillMenu)
        elseif battleState.characterMenu.position == 3 then
            local user = char
            user.currentAction = actionCreator.new('defend', user)
            local currentID = battleState.characterMenu.charID
            nextCharacter(currentID)
        elseif battleState.characterMenu.position == 4 then
            utils.updateItemMenu(char)
            battleState.currentMenu = battleState.itemMenu
            utils.menuReset(battleState.itemMenu)
        end
    elseif battleState.currentMenu == battleState.skillMenu
    and #battleState.skillMenu.list > 0 then
        local ref = battleState.skillMenu.list[battleState.skillMenu.position]
        local data = actionData[ref]
        if battleState.skillMenu.user.currentMp >= data.cost then
            local group
            if data.aim == 'enemies' then
                group = battleState.enemies
            elseif data.aim == 'allies' then
                group = battleState.party
            end
            if data.scope == 'single' then
                utils.updateTargetMenu(battleState.skillMenu, group)
                if #battleState.targetMenu.list == 1 then
                    local target = group[1]
                    local user = battleState.party[battleState.characterMenu.charID]
                    local ref = battleState.skillMenu.list[battleState.skillMenu.position]
                    local action = actionCreator.new(ref, user, {target})
                    user.currentAction = action
                    local currentID = battleState.characterMenu.charID
                    nextCharacter(currentID)
                elseif #battleState.targetMenu.list > 1 then
                    battleState.currentMenu = battleState.targetMenu
                    utils.menuReset(battleState.targetMenu)
                end
            elseif data.scope == 'dead' then
                utils.updateDeadTargetMenu(battleState.skillMenu, group)
                battleState.currentMenu = battleState.targetMenu
                utils.menuReset(battleState.targetMenu)
            elseif data.scope == 'all' then
                local user = battleState.party[battleState.characterMenu.charID]
                local ref = battleState.skillMenu.list[battleState.skillMenu.position]
                local action = actionCreator.new(ref, user, {unpack(group)})
                user.currentAction = action
                local currentID = battleState.characterMenu.charID
                nextCharacter(currentID)
            elseif data.scope == 'self' then
                local user = battleState.party[battleState.characterMenu.charID]
                local ref = battleState.skillMenu.list[battleState.skillMenu.position]
                local action = actionCreator.new(ref, user, {user})
                user.currentAction = action
                local currentID = battleState.characterMenu.charID
                nextCharacter(currentID)
            end
        end
    elseif battleState.currentMenu == battleState.itemMenu
    and #battleState.itemMenu.list > 0 then
        local item = battleState.itemMenu.list[battleState.itemMenu.position].item
        local data = actionData[item.ref]
            local group
            if data.aim == 'enemies' then
                group = battleState.enemies
            elseif data.aim == 'allies' then
                group = battleState.party
            end
            if data.scope == 'single' then
                utils.updateTargetMenu(battleState.itemMenu, group)
                if #battleState.targetMenu.list == 1 then
                    local target = group[1]
                    local user = battleState.party[battleState.characterMenu.charID]
                    local ref = item.ref
                    local action = actionCreator.new(ref, user, {target})
                    user.currentAction = action
                    user.usingItem = item
                    utils.manageItems(item, -1)
                    local currentID = battleState.characterMenu.charID
                    nextCharacter(currentID)
                elseif #battleState.targetMenu.list > 1 then
                    battleState.currentMenu = battleState.targetMenu
                    utils.menuReset(battleState.targetMenu)
                end
            elseif data.scope == 'dead' then
                utils.updateDeadTargetMenu(battleState.itemMenu, group)
                battleState.currentMenu = battleState.targetMenu
                utils.menuReset(battleState.targetMenu)
            elseif data.scope == 'all' then
                local user = battleState.party[battleState.characterMenu.charID]
                local ref = item.ref
                local action = actionCreator.new(ref, user, {unpack(group)})
                user.currentAction = action
                user.usingItem = item
                utils.manageItems(item, -1)
                local currentID = battleState.characterMenu.charID
                nextCharacter(currentID)
            elseif data.scope == 'self' then
                local user = battleState.party[battleState.characterMenu.charID]
                local ref = item.ref
                local action = actionCreator.new(ref, user, {user})
                user.currentAction = action
                user.usingItem = item
                utils.manageItems(item, -1)
                local currentID = battleState.characterMenu.charID
                nextCharacter(currentID)
            end
    elseif battleState.currentMenu == battleState.targetMenu and #battleState.targetMenu.list > 0 then
        if battleState.targetMenu.prevMenu == battleState.characterMenu then
            local target = battleState.targetMenu.list[battleState.targetMenu.position]
            addAttackAction(target)
        elseif battleState.targetMenu.prevMenu == battleState.skillMenu then
            local target = battleState.targetMenu.list[battleState.targetMenu.position]
            local user = battleState.party[battleState.characterMenu.charID]
            local ref = battleState.skillMenu.list[battleState.skillMenu.position]
            local action = actionCreator.new(ref, user, {target})
            user.currentAction = action
        elseif battleState.targetMenu.prevMenu == battleState.itemMenu then
            local target = battleState.targetMenu.list[battleState.targetMenu.position]
            local user = battleState.party[battleState.characterMenu.charID]
            local item = battleState.itemMenu.list[battleState.itemMenu.position].item
            local ref = item.ref
            local action = actionCreator.new(ref, user, {target})
            user.currentAction = action
            user.usingItem = item
            utils.manageItems(item, -1)
        end
        local currentID = battleState.characterMenu.charID
        nextCharacter(currentID)
    end
end

function battleInput.executeCancel()
    if battleState.currentMenu == battleState.characterMenu then
        local currentID = battleState.characterMenu.charID
        local prevID = utils.getAbleCharID(currentID, 'prev')
        if prevID then
            battleState.characterMenu.charID = prevID
            utils.menuReset(battleState.characterMenu)
            local user = battleState.party[battleState.characterMenu.charID]
            if user.usingItem then
                utils.manageItems(user.usingItem, 1)
                user.usingItem = nil
            end
        else
            battleState.currentMenu = battleState.mainMenu
            utils.menuReset(battleState.mainMenu)
        end
    elseif battleState.currentMenu == battleState.targetMenu then
        battleState.currentMenu  = battleState.targetMenu.prevMenu
    elseif battleState.currentMenu == battleState.skillMenu then
        battleState.currentMenu = battleState.characterMenu
        battleState.characterMenu.position = 2
    elseif battleState.currentMenu == battleState.itemMenu then
        battleState.currentMenu = battleState.characterMenu
        battleState.characterMenu.position = 4
    end
end

return battleInput