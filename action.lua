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
        local followUp = actionData[a.ref].execute(a.user, a.target)
        
        if not a.user.isPartyMember and actionData[a.ref].enemyAnimation then
            local data = actionData[a.ref].enemyAnimation
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

