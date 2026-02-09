local effectData = require('effectData')
local animation = require('animation')

local effect = {}

function effect.new(ref, user, target, value)

    local e = {}
    e.ref = ref
    e.user = user
    e.target = target
    e.value = value

    function e.apply()
        effectData[e.ref].apply(user, target, value)
        
        if e.target.isPartyMember and effectData[e.ref].partyAnimation then
            local data = effectData[e.ref].partyAnimation
            local animation = animation.new(e.target, data.ref, data.maxTick, data.speed, e.value)
            state.animation = animation
        end
    end
    
    return e
end

return effect