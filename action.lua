local actionData = require('actionData')
local animation = require('animation')
local utils = require('utils')

local action = {}

function action.new(ref, user, target)
    local a = {}
    a.ref = ref
    a.user = user
    a.target = target or nil

    function a.execute()
        local toAct = actionData[a.ref]
        
        if toAct.cost then
            a.user.currentMp = a.user.currentMp - toAct.cost
        end
        
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
    end

    function a.checkPriority()
        local toCheck = actionData[a.ref]
        return toCheck.priority
    end

    return a
end

return action

