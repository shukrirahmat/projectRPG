local function createCharacter(_name, _isPartyMember, sheet)
    
    local stats = {
    name = _name,
    isPartyMember = _isPartyMember,
    maxHp = sheet.hp,
    currentHp = sheet.hp,
    maxMp = sheet.maxMp,
    currentMp = sheet.mp,
    atk = sheet.atk,
    def = sheet.def,
    agi = sheet.agi,
    critRate = sheet.critRate or 128,
    dead = sheet.dead or false,
    sprite = sheet.sprite,
    spriteHeight = sheet.spriteHeight
    }

    local currentAction

    local function getStat(string)
        return stats[string]
    end
    
    local function setCurrentAction(action)
        currentAction = action
    end
    
    local function getCurrentAction()
        return currentAction
    end

    return {
        getStat = getStat,
        setCurrentAction = setCurrentAction,
        getCurrentAction = getCurrentAction
    }

end

return createCharacter;
