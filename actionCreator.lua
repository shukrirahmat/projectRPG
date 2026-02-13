local actionData = require('actionData')
local animationCreator = require('animationCreator')
local utils = require('utils')
local state = require('state')

local actionCreator = {}

function actionCreator.setPartyAction()
    for _, member in ipairs(state.party) do
        if not member.isDead then
            local action
            if member.status['STUN'] or member.status['SLEEP'] or member.status['CONFUSE'] then
                local target = utils.selectTargetRandomly(state.enemies)
                action = actionCreator.new('normalAtk', member, target)
            elseif member.currentAction then
                action = member.currentAction
            end
            utils.sentActionIntoQueue(action)
            member.currentAction = nil
        end
    end
end

function actionCreator.setEnemyAction()
    for _, enemy in ipairs(state.enemies) do
        if not enemy.isDead then
            local action
            if enemy.status['STUN'] or enemy.status['SLEEP'] or enemy.status['CONFUSE'] then
                local target = utils.selectTargetRandomly(state.party)
                action = actionCreator.new('normalAtk', enemy, target)
            else
                local choices = {unpack(enemy.skills)}
                local target = utils.selectTargetRandomly(state.party)
                
                local min = (#choices or 0) * -1

                local rand = math.random(min, #choices or 0)
                if rand <= 0 then
                    action = actionCreator.new('normalAtk', enemy, target)
                else
                    local skillRef = choices[rand]
                    local skill = actionData[skillRef]
                    local targetGroup;
                    if skill.aim == 'allies' then 
                        targetGroup = state.enemies
                    elseif skill.aim == 'enemies' then
                        targetGroup = state.party
                    end
                    if skill.scope == 'single' then
                        local target = utils.selectTargetRandomly(targetGroup)
                        action = actionCreator.new(skillRef, enemy, target)
                    elseif skill.scope == 'all' then
                        action = actionCreator.new(skillRef, enemy, targetGroup)
                    elseif skill.scope == 'self' then
                        action = actionCreator(skillRef, enemy, enemy)
                    end
                end
            end
            utils.sentActionIntoQueue(action)
        end
    end
end

function actionCreator.new(ref, user, target)
    local action = {}
    action.ref = ref
    action.user = user
    action.target = target or nil

    function action.execute()
        local toAct = actionData[action.ref]
        local canAct = true

        if toAct.magic or toAct.tech then
            if action.user.currentMp >= toAct.cost and not action.user.status['SEAL'] then
                action.user.currentMp = action.user.currentMp - toAct.cost
            else
                canAct = false
            end
        end

        if canAct then
            local followUp = toAct.execute(toAct, action.user, action.target)
            if not action.user.isPartyMember and toAct.enemyAnimation then
                local aniData = toAct.enemyAnimation
                local animation = animationCreator.new(
                    action.user, aniData.ref, aniData.maxTick, aniData.speed)
                state.animation = animation
            end
            if followUp then
                local action = actionCreator.new(followUp, action.user, action.target)
                utils.sentActionIntoQueue(action)
            end
        else
            local skillCanceled = actionData['skillCanceled']
            skillCanceled.execute(skillCanceled, action.user, action.target, toAct)
        end
    end

    function action.checkPriority()
        local toCheck = actionData[action.ref]
        return toCheck.priority
    end

    return action
end

return actionCreator

