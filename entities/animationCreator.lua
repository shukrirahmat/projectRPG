local animationCreator = {}

function animationCreator.new(user, ref, speed, value)
    local animation = {}
    
    animation.user = user
    animation.ref = ref
    animation.speed = speed
    animation.value = value

    return animation
end

return animationCreator