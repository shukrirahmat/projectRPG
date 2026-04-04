local effect = {}

function effect.new(ref, data, user, target, value)

    local self = {}
    self.ref = ref
    self.data = data
    self.user = user
    self.target = target
    self.value = value
    
    return self
end

return effect