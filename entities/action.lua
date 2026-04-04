local action = {}

function action.new(ref, data, user, targets)
    local self = {}
    self.ref = ref
    self.data = data
    self.user = user
    self.targets = targets
    
    return self
end

return action