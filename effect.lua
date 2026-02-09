local effectData = require('effectData')

local effect = {}

function effect.new(ref, user, target, value)

    local e = {}
    e.ref = ref
    e.user = user
    e.target = target
    e.value = target

    function e.apply()
        effectData[ref].apply(user, target, value)
    end
    
    return e
end

return effect