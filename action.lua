local actionData = require('actionData')
local animation = require('animation')
local utils = require('utils')
local effect = require('effect')
local state = require('state')

local action = {}

function action.setPartyAction()
    for _, member in ipairs(state.party) do
        if not member.isDead then
            local toAct
            if member.status['STUN'] or member.status['SLEEP'] or member.status['CONFUSE'] then
                local target = utils.selectTargetRandomly(state.enemies)
                toAct = action.new('normalAtk', member, target)
            elseif member.currentAction then
                toAct = member.currentAction
            end
            utils.sentActionIntoQueue(toAct)
            member.currentAction = nil
        end
    end
end

function action.setEnemyAction()
    for _, enemy in ipairs(state.enemies) do
        if not enemy.isDead then
            local toAct
            if enemy.status['STUN'] or enemy.status['SLEEP'] or enemy.status['CONFUSE'] then
                local target = utils.selectTargetRandomly(state.party)
                toAct = action.new('normalAtk', enemy, target)
            else
                local choices = {unpack(enemy.skills)}
                local target = utils.selectTargetRandomly(state.party)

                local rand = math.random(0, #choices or 0)
                if rand == 0 then
                    toAct = action.new('normalAtk', enemy, target)
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
                        toAct = action.new(skillRef, enemy, target)
                    elseif skill.scope == 'all' then
                        toAct = action.new(skillRef, enemy, targetGroup)
                    elseif skill.scope == 'self' then
                        toAct = action.new(skillRef, enemy, enemy)
                    end
                end
            end
            utils.sentActionIntoQueue(toAct)
        end
    end
end

function action.new(ref, user, target)
    local a = {}
    a.ref = ref
    a.user = user
    a.target = target or nil

    function a.execute()
        local toAct = actionData[a.ref]
        local canAct = true

        if toAct.magic or toAct.tech then
            if a.user.currentMp >= toAct.cost and not a.user.status['SEAL'] then
                a.user.currentMp = a.user.currentMp - toAct.cost
            else
                canAct = false
            end
        end

        if canAct then
            local followUp = toAct.execute(toAct, a.user, a.target)
            if not a.user.isPartyMember and toAct.enemyAnimation then
                local data = toAct.enemyAnimation
                local animation = animation.new(a.user, data.ref, data.maxTick, data.speed)
                state.animation = animation
            end
            if followUp then
                local newAction = action.new(followUp, a.user, a.target)
                utils.sentActionIntoQueue(newAction)
            end
        else
            local skillCanceled = actionData['skillCanceled']
            skillCanceled.execute(skillCanceled, a.user, a.target, toAct)
        end
    end

    function a.checkPriority()
        local toCheck = actionData[a.ref]
        return toCheck.priority
    end

    return a
end

return action

