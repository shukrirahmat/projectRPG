local effectData = require('effectData')
local animationCreator = require('animationCreator')

local effectCreator = {}

function effectCreator.new(ref, user, target, value)

    local effect = {}
    effect.ref = ref
    effect.user = user
    effect.target = target
    effect.value = value

    function effect.apply()
        effectData[effect.ref].apply(user, target, value)
        
        if effect.target and effect.target.isPartyMember and effectData[effect.ref].partyAnimation then
            local data = effectData[effect.ref].partyAnimation
            local animation = animationCreator.new(
                effect.target, data.ref, data.maxTick, data.speed, effect.value
                )
            state.animation = animation
        elseif effect.target 
        and not effect.target.isPartyMember and effectData[effect.ref].enemyAnimation then
            local data = effectData[effect.ref].enemyAnimation
            local animation = animationCreator.new(
                effect.target, data.ref, data.maxTick, data.speed, effect.value
                )
            state.animation = animation
        end
    end
    
    return effect
end

return effectCreator