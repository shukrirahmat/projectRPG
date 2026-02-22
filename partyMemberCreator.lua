local dataSheet = {
    {
        name = 'KNIGHT',
        hp = 180,
        mp = 20,
        str = 130,
        def = 70,
        agi = 80,
        skills = {'cover', 'flameStrike', 'focus', 'ram', 'desperation'},
        passives = {['dualWield'] = true}
    },
    {
        name = 'FIGHTER',
        hp = 160,
        mp = 35,
        str = 80,
        def = 50,
        agi = 120,
        skills = {'deathIII', 'voidStrike', 'ram', 'desperation'},
        passives = {['keenEye'] = true, ['keenEye+'] = true, ['dualWield'] = true}
    },
    {
        name = 'PRIEST',
        hp = 140,
        mp = 150,
        str = 60,
        def = 50,
        agi = 100,
        skills = {'typhoonIII', 'luminaIII', 'healAllII', 'drainII'},
        passives = {['windLord'] = true}
    }, 
    {
        name = 'MAGE',
        hp = 100,
        mp = 80,
        str = 30,
        def = 40,
        agi = 90,
        skills = {'lightningIII', 'luminaIII', 'voidIII', 'drainII'},
        passives = {['thunderLord'] = true, ['leechLord'] = true}
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
    p.critRate = data.critRate or 64
    p.skills = data.skills or {}
    p.status = {}
    p.strong = data.strong or {}
    p.immune = data.immune or {}
    p.passives = data.passives or {}
    
    if p.passives['keenEye+'] then
        p.critRate = 4
    elseif p.passives['keenEye'] then
        p.critRate = 16
    end

    return p
end

return P