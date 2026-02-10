local dataSheet = {
    {
        name = 'KNIGHT',
        hp = 180,
        mp = 0,
        str = 80,
        def = 70,
        agi = 60,
        critRate = 64
    },
    {
        name = 'FIGHTER',
        hp = 160,
        mp = 0,
        str = 120,
        def = 50,
        agi = 180,
        critRate = 8,
        skills = {'aura', 'midAura', 'greatAura', 'auraBeam', 'greatAuraBeam'}
    },
    {
        name = 'PRIEST',
        hp = 140,
        mp = 50,
        str = 60,
        def = 50,
        agi = 80,
        critRate = 64,
        skills = {'typhoon', 'midTyphoon', 'greatTyphoon', 'chaosIceFrost'}
    }, 
    {
        name = 'MAGE',
        hp = 100,
        mp = 80,
        str = 30,
        def = 40,
        agi = 80,
        critRate = 64,
        skills = {'lightning', 'midLightning', 'greatLightning'}
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
    p.str = data.str
    p.atk = data.str
    p.def = data.def
    p.agi = data.agi
    p.critRate = data.critRate or 128
    p.skills = data.skills or {}

    return p
end

return P