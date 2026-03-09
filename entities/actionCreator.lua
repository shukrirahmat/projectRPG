local actionCreator = {}

function actionCreator.new(ref, user, targets)
    local action = {}
    action.ref = ref
    action.user = user
    action.targets = targets or {}

    return action
end

return actionCreator