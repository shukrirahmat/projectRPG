local actionData = require('actionData')
local utils = require('utils')

local action = {}

function action.new(ref, user, target)
    local a = {}
    a.ref = ref
    a.user = user
    a.target = target or nil

    function a.execute()
        local followUp = actionData[a.ref].execute(a.user, a.target)
        
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

