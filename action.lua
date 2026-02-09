local actionData = require('actionData')

local action = {}

function action.new(ref, user, target)
    local a = {}
    a.ref = ref
    a.user = user
    a.target = target or nil

    function a.execute()
        local action = actionData[a.ref]
        action.execute(a.user, a.target)
    end
    
    function a.checkPriority()
        local action = actionData[a.ref]
        return action.priority
    end

    return a
end

return action

