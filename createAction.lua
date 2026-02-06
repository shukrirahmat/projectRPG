local function createAction(_name, _user, _target)

    local name = _name
    local user = _user
    local target = _target

    local function getName()
        return name
    end
    
    local function getUser()
        return user
    end
    
    local function getTarget()
        return target
    end
    
    local function setTarget(_target)
        target = _target
    end

    return {
        getName = getName,
        getUser = getUser,
        getTarget = getTarget
    }
end

return createAction