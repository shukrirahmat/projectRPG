local function createBattle(_party, _enemies)

    local party = _party
    local enemies = _enemies
    local partyDefeated = false
    local enmiesDefeated = false
    
    local function getParty()
        return party
    end
    
    local function getPartyMember(id)
        return party[id]
    end
    
    local function getEnemies()
        return enemies
    end

    return {
        getParty = getParty,
        getPartyMember = getPartyMember,
        getEnemies = getEnemies,
    }
end

return createBattle