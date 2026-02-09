local dataSheet = {
    {
        name = 'KNIGHT',
        hp = 180,
        mp = 0,
        atk = 80,
        def = 70,
        agi = 60,
        critRate = 64
    },
    {
        name = 'FIGHTER',
        hp = 160,
        mp = 0,
        atk = 70,
        def = 50,
        agi = 100,
        critRate = 4
    },
    {
        name = 'PRIEST',
        hp = 140,
        mp = 50,
        atk = 60,
        def = 50,
        agi = 80,
        critRate = 64,
    }, 
    {
        name = 'MAGE',
        hp = 100,
        mp = 150,
        atk = 30,
        def = 40,
        agi = 80,
        critRate = 64,
    }
}

local P = {}

function P.new(index)
    local data = dataSheet[index]
    local p = {}

    p.isPartyMember = true
    p.isDead = false

    p.name = data.name
    p.maxHp = data.hp
    p.currentHp = data.hp
    p.maxMp = data.mp
    p.currentMp = data.mp
    p.atk = data.atk
    p.def = data.def
    p.agi = data.agi
    p.critRate = data.critRate or 128

    return p
end

return P