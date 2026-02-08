local actionData = require('actionData')

local action = {}

function action.new(ref, user, target, priority)
    local a = {}
    a.ref = ref
    a.user = user
    a.target = target or nil
    a.priority = priority or false

    function a.execute()
        local action = actionData[a.ref]
        action.execute(a.user, a.target)
    end

    return a
end

return action

