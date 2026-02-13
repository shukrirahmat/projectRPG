local action = require('action')

local dataSheet = {
    {
        name = 'KNIGHT',
        hp = 180,
        mp = 20,
        str = 80,
        def = 70,
        agi = 60,
        critRate = 64,
        skills = {'drain', 'greatDrain', 'dracoBomb', 'greatDracoBomb', 'dispel', 'dispelAll'}
    },
    {
        name = 'FIGHTER',
        hp = 160,
        mp = 35,
        str = 70,
        def = 50,
        agi = 180,
        critRate = 8,
        skills = {'auraBeam', 'greatAuraBeam', 'auraCharge', 'sandstorm', 'greatSandstorm'}
    },
    {
        name = 'PRIEST',
        hp = 140,
        mp = 150,
        str = 60,
        def = 50,
        agi = 80,
        critRate = 64,
        skills = {'healAll', 'greatHealAll', 'neutralize', 'neutralizeAll', 'mend', 'purify', 'purifyAll'}
    }, 
    {
        name = 'MAGE',
        hp = 100,
        mp = 80,
        str = 30,
        def = 40,
        agi = 80,
        critRate = 64,
        skills = {'slumber', 'midSlumber', 'greatSlumber', 'confusion', 'midConfusion', 'greatConfusion'}
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
    p.status = {}
    p.strong = data.strong or {}
    p.immune = data.immune or {}

    return p
end

return P