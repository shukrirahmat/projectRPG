local actionData = require('actionData')
local animationCreator = require('animationCreator')
local utils = require('utils')
local state = require('state')

local actionCreator = {}

function actionCreator.new(ref, user, target)
    local action = {}
    action.ref = ref
    action.user = user
    action.target = target or nil

    return action
end

return actionCreator

