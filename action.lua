local action = {}

function action.new(ref, user, target, priority)
    local a = {}
    a.ref = ref
    a.user = user
    a.target = target or nil
    a.priority = priority or false

    return a
end

return action

