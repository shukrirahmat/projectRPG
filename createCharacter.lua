local function createCharacter(data, _name)
    
    local name = _name or data.name
    local partyMember = data.partyMember
    local maxHp = data.hp
    local currentHp = data.hp
    local maxMp = data.mp
    local currentMp = data.mp
    local atk = data.atk
    local def = data.def
    local agi = data.agi
    local critRate = data.critRate or 128
    local sprite = data.sprite
    local spriteHeight = data.spriteHeight
    local dead = data.dead or false
    
    return {
        name = name,
        partyMember = partyMember,
        maxHp = maxHp,
        currentHp = currentHp,
        maxMp = maxMp,
        currentMp = currentMp,
        atk = atk,
        def = def,
        agi = agi,
        critRate = critRate,
        sprite = sprite,
        spriteHeight = spriteHeight,
        dead = dead
    }
        
end

return createCharacter;