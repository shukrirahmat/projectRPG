local animationCreator = {}

function animationCreator.new(user, ref, maxTick, speed, value)
    
    local animation = {
        
        timer= 0,
        tick= 0,
        user = user or nil,
        ref = ref,
        maxTick = maxTick,
        speed = speed,
        value = value
    }
    
    return animation
end

return animationCreator