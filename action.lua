local actionData = require('actionData')
local animation = require('animation')
local utils = require('utils')
local effect = require('effect')
local state = require('state')

local action = {}

function action.new(ref, user, target)
    local a = {}
    a.ref = ref
    a.user = user
    a.target = target or nil

    local function clearStatus(status, chance)
        local roll = math.random(0, 100)
        if roll <= chance then
            local clear = effect.new('clearStatus', a.user, a.user, status)
            table.insert(state.effectList, clear)
        end
    end

    function a.execute()
        local toAct = actionData[a.ref]
        local canAct = true
        local stunned = false

        if a.user.status['STUN'] then
            canAct = false
            stunned = true
        end

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
        elseif stunned then
            local stunAct = actionData['stunned']
            stunAct.execute(skillCanceled, a.user, a.target)
        else
            local skillCanceled = actionData['skillCanceled']
            skillCanceled.execute(skillCanceled, a.user, a.target, toAct)
        end

        if a.user.status['BLIND'] then
            clearStatus('BLIND', 20)
        end
        
        if a.user.status['SEAL'] then
            clearStatus('SEAL', 20)
        end
        
        if a.user.status['STUN'] then
            clearStatus('STUN', 50)
        end
    end

    function a.checkPriority()
        local toCheck = actionData[a.ref]
        return toCheck.priority
    end

    return a
end

return action

