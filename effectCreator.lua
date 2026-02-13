local effectData = require('effectData')
local animationCreator = require('animationCreator')

local effectCreator = {}

function effectCreator.new(ref, user, target, value)

    local effect = {}
    effect.ref = ref
    effect.user = user
    effect.target = target
    effect.value = value
    
    return effect
end

return effectCreator