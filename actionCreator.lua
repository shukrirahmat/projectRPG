local actionCreator = {}

function actionCreator.new(ref, user, target)
    local action = {}
    action.ref = ref
    action.user = user
    action.target = target or nil

    return action
end

return actionCreator

