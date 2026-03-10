local animationCreator = {}

function animationCreator.new(user, ref, speed, value)
    local animation = {}
    
    animation.user = user
    animation.ref = ref
    animation.timer = 0
    animation.speed = speed
    animation.value = value

    return animation
end

return animationCreator