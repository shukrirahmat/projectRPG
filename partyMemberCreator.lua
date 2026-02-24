local weaponCreator = require('weaponCreator')

local dataSheet = {
    {
        name = 'KNIGHT',
        lvl = 20,
        hp = 180,
        mp = 20,
        str = 60,
        def = 70,
        agi = 80,
        skills = {'cover', 'flameStrike', 'focus', 'ram', 'desperation'},
        passives = {['counter'] = true, ['piercer'] = true, ['lastStand'] = true, 
            ['immunity'] = {'BLIND'} , ['iceCombo'] = true},
        weapon = weaponCreator.new('rustedAxe')
    },
    {
        name = 'FIGHTER',
        lvl = 20,
        hp = 160,
        mp = 35,
        str = 80,
        def = 50,
        agi = 120,
        skills = {'deathIII', 'voidStrike', 'ram', 'desperation', 'undo'},
        passives = {['keenEye+'] = true, ['dualWield'] = true, 
            ['snatcher'] = true, ['counter'] = true},
        weapon = weaponCreator.new('leatherFist')
    },
    {
        name = 'PRIEST',
        lvl = 20,
        hp = 140,
        mp = 150,
        str = 30,
        def = 50,
        agi = 100,
        skills = {'typhoonI', 'luminaII', 'healAllI', 'drainII'},
        passives = {['echoMagic'] = true, ['immunity'] = {'SEAL'}, ['manaSaver'] = true},
        weapon = weaponCreator.new('woodenStaff')
    }, 
    {
        name = 'MAGE',
        lvl = 20,
        hp = 100,
        mp = 80,
        str = 24,
        def = 40,
        agi = 90,
        skills = {'lightningI', 'luminaII', 'voidIII', 'drainII', 'tremorI', 'woundII', 'hiddenBlades'},
        passives = {['echoMagic'] = true, ['immunity'] = {'SEAL'}, ['manaSaver'] = true},
        weapon = weaponCreator.new('smallDagger')
    }
}

local P = {}

function P.new(index)
    local data = dataSheet[index]
    local p = {}

    p.isPartyMember = true
    p.isDead = data.isDead or false

    p.name = data.name
    p.lvl = data.lvl
    p.maxHp = data.hp
    p.currentHp = data.hp
    p.maxMp = data.mp
    p.currentMp = data.mp
    p.str = data.str
    p.weapon = data.weapon
    p.baseAtk = data.str + (p.weapon.atkPower or 0)
    p.atk = p.baseAtk
    p.baseDef = data.def
    p.def = data.def
    p.baseAgi = data.agi
    p.agi = data.agi
    p.critRate = data.critRate or 64
    p.dodgeRate = data.dodgeRate or 0
    p.skills = data.skills or {}
    p.status = {}
    p.strong = data.strong or {}
    p.immune = data.immune or {}
    p.passives = data.passives or {}
    
    if p.passives['keenEye+'] then
        p.critRate = 8
    elseif p.passives['keenEye'] then
        p.critRate = 16
    end
    
    if p.passives['evasion+'] then
        p.dodgeRate = 2
    elseif p.passives['evasion'] then
        p.dodgeRate = 4
    end
    
    if p.passives['immunity'] then
        for i, element in ipairs(p.passives['immunity']) do
            p.immune[element] = true
        end
    end
    
    if p.passives['arcaneProtection'] then
        p.strong['FIRE'] = true
        p.strong['ICE'] = true
        p.strong['BOLT'] = true
        p.strong['WIND'] = true
    end
    
    if p.passives['celestialProtection'] then
        p.strong['LIGHT'] = true
        p.strong['VOID'] = true
    end
    
    if p.passives['lightWielder'] and p.weapon.weight == 'LIGHTWEIGHT' then
        p.baseAtk = p.baseAtk * 1.5
        p.atk = p.baseAtk
    end
    
    if p.passives['heavyWielder'] and p.weapon.weight == 'HEAVYWEIGHT' then
        p.baseAtk = p.baseAtk * 1.5
        p.atk = p.baseAtk
    end

    return p
end

return P