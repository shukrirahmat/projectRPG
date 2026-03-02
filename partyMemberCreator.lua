local weaponCreator = require('weaponCreator')

local statsGain = {}

statsGain['ONE'] = {
    hp = { 
        ['1-10'] = 7,
        ['10-20'] = 8,
        ['20-30'] = 9,
        ['30-40'] = 10,
        ['40-50'] = 11
    },
    mp = {
        ['1-10'] = 2,
        ['10-20'] = 2,
        ['20-30'] = 3,
        ['30-40'] = 3,
        ['40-50'] = 4
    },
    str = {
        ['1-10'] = 3,
        ['10-20'] = 4,
        ['20-30'] = 4,
        ['30-40'] = 4,
        ['40-50'] = 5
    },
    vit = {
        ['1-10'] = 2,
        ['10-20'] = 3,
        ['20-30'] = 3,
        ['30-40'] = 4,
        ['40-50'] = 4
    },
    agi = {
        ['1-10'] = 2,
        ['10-20'] = 3,
        ['20-30'] = 4,
        ['30-40'] = 4,
        ['40-50'] = 5
    }
}

stats['TWO'] = {
    hp = { 
        ['1-10'] =  4,
        ['10-20'] = 5,
        ['20-30'] = 5,
        ['30-40'] = 5,
        ['40-50'] = 6
    },
    mp = {
        ['1-10'] =  5,
        ['10-20'] = 6,
        ['20-30'] = 6,
        ['30-40'] = 7,
        ['40-50'] = 8
    },
    str = {
        ['1-10'] =  1,
        ['10-20'] = 1,
        ['20-30'] = 2,
        ['30-40'] = 2,
        ['40-50'] = 2
    },
    vit = {
        ['1-10'] =  1,
        ['10-20'] = 2,
        ['20-30'] = 2,
        ['30-40'] = 3,
        ['40-50'] = 3
    },
    agi = {
        ['1-10'] =  3,
        ['10-20'] = 3,
        ['20-30'] = 4,
        ['30-40'] = 4,
        ['40-50'] = 4
    }
}

stats['THREE'] = {
    hp = { 
        ['1-10'] = 6,
        ['10-20'] = 7,
        ['20-30'] = 7,
        ['30-40'] = 8,
        ['40-50'] = 8
    },
    mp = {
        ['1-10'] = 3,
        ['10-20'] = 4,
        ['20-30'] = 5,
        ['30-40'] = 5,
        ['40-50'] = 6
    },
    str = {
        ['1-10'] = 2,
        ['10-20'] = 3,
        ['20-30'] = 3,
        ['30-40'] = 3,
        ['40-50'] = 4
    },
    vit = {
        ['1-10'] = 3,
        ['10-20'] = 4,
        ['20-30'] = 4,
        ['30-40'] = 4,
        ['40-50'] = 5
    },
    agi = {
        ['1-10'] = 2,
        ['10-20'] = 2,
        ['20-30'] = 3,
        ['30-40'] = 3,
        ['40-50'] = 3
    }
}

stats['FOUR'] = {
    hp = { 
        ['1-10'] = 8,
        ['10-20'] = 9,
        ['20-30'] = 10,
        ['30-40'] = 10,
        ['40-50'] = 11
    },
    mp = {
        ['1-10'] = 1,
        ['10-20'] = 2,
        ['20-30'] = 2,
        ['30-40'] = 2,
        ['40-50'] = 3
    },
    str = {
        ['1-10'] = 4,
        ['10-20'] = 4,
        ['20-30'] = 5,
        ['30-40'] = 6,
        ['40-50'] = 6
    },
    vit = {
        ['1-10'] = 3,
        ['10-20'] = 3,
        ['20-30'] = 4,
        ['30-40'] = 4,
        ['40-50'] = 5
    },
    agi = {
        ['1-10'] = 1,
        ['10-20'] = 1,
        ['20-30'] = 2,
        ['30-40'] = 2,
        ['40-50'] = 2
    }
}

local dataSheet = {}

dataSheet['ONE'] = {
    name = 'ONE',
    lvl = 1,
    hp = 32,
    mp = 12,
    str = 8,
    vit = 7,
    agi = 7,
    skills = {},
    passives = {},
}

dataSheet['TWO'] = {
    name = 'TWO',
    lvl = 1,
    hp = 29,
    mp = 15,
    str = 6,
    vit = 6,
    agi = 8,
    skills = {},
    passives = {},
}

dataSheet['THREE'] = {
    name = 'THREE',
    lvl = 1,
    hp = 31,
    mp = 13,
    str = 7,
    vit = 8,
    agi = 7,
    skills = {},
    passives = {},
}

dataSheet['FOUR'] = {
    name = 'FOUR',
    lvl = 1,
    hp = 33,
    mp = 11,
    str = 9,
    vit = 8,
    agi = 6,
    skills = {},
    passives = {},
}


local P = {}

function P.new(ref)
    local data = dataSheet[ref]
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
    p.weapon = data.weapon or nil
    p.baseAtk = data.str + (p.weapon.atkPower or 0)
    p.atk = p.baseAtk
    p.baseDef = data.vit
    p.def = data.baseDef
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

    if p.passives['lightWielder'] and p.weapon and p.weapon.weight == 'LIGHTWEIGHT' then
        p.baseAtk = p.baseAtk * 1.5
        p.atk = p.baseAtk
    end

    if p.passives['heavyWielder'] and p.weapon and p.weapon.weight == 'HEAVYWEIGHT' then
        p.baseAtk = p.baseAtk * 1.5
        p.atk = p.baseAtk
    end

    return p
end

return P