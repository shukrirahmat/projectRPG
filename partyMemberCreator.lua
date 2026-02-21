local dataSheet = {
    {
        name = 'KNIGHT',
        hp = 180,
        mp = 20,
        str = 130,
        def = 70,
        agi = 80,
        critRate = 64,
        skills = {'cover', 'flameStrike', 'focus', 'ram', 'desperation'}
    },
    {
        name = 'FIGHTER',
        hp = 160,
        mp = 35,
        str = 80,
        def = 50,
        agi = 120,
        critRate = 64,
        skills = {'deathIII', 'voidStrike', 'ram', 'desperation'},
    },
    {
        name = 'PRIEST',
        hp = 140,
        mp = 150,
        str = 60,
        def = 50,
        agi = 100,
        critRate = 64,
        skills = {'blizzardI', 'blizzardII', 'blizzardIII', 'blizzardX', 'healAllII'}
    }, 
    {
        name = 'MAGE',
        hp = 100,
        mp = 80,
        str = 30,
        def = 40,
        agi = 90,
        critRate = 64,
        skills = {'flameI', 'flameII', 'flameIII', 'flameX'}
    }
}

local P = {}

function P.new(index)
    local data = dataSheet[index]
    local p = {}

    p.isPartyMember = true
    p.isDead = data.isDead or false

    p.name = data.name
    p.maxHp = data.hp
    p.currentHp = data.hp
    p.maxMp = data.mp
    p.currentMp = data.mp
    p.str = data.str
    p.baseAtk = data.str
    p.atk = data.str
    p.baseDef = data.def
    p.def = data.def
    p.baseAgi = data.agi
    p.agi = data.agi
    p.critRate = data.critRate or 128
    p.skills = data.skills or {}
    p.status = {}
    p.strong = data.strong or {}
    p.immune = data.immune or {}

    return p
end

return P