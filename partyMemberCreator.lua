local equipmentCreator = require('equipmentCreator')

local statsGain = {}

--[[

one
hp  95 175 265 365 475  = 1190
mp  30 60  90  120 160
str 35 75  115 155 205
vit 25 55  85  125 165
agi 25 55  95  135 185

two
hp  65 115 165 215 275 = 1000
mp  60 120 180 250 330
str 15 25  45  65  85
vit 15 35  55  85  115
agi 35 65  105 145 195

three
hp  85 155 225 305 385 = 1090
mp  40 80  130 180 240
str 25 55  85  115 155
vit 35 65  105 145 185
agi 25 45  65  95  125

four
hp  105 195 295 395 505 = 1150
mp  20  40  60  80  110
str 45  85  135 195 255
vit 35  65  105 145 195
agi 15  25  45  65  85
]]

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
        ['10-20'] = 3,
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

statsGain['TWO'] = {
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
        ['40-50'] = 5
    }
}

statsGain['THREE'] = {
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
        ['10-20'] = 3,
        ['20-30'] = 4,
        ['30-40'] = 4,
        ['40-50'] = 4
    },
    agi = {
        ['1-10'] = 2,
        ['10-20'] = 2,
        ['20-30'] = 2,
        ['30-40'] = 3,
        ['40-50'] = 3
    }
}

statsGain['FOUR'] = {
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
    p.baseAtk = data.str
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
    p.weapon = data.weapon or nil
    p.armor = data.armor or nil
    p.shield = data.shield or nil

    if p.weapon then
        p.baseAtk = p.baseAtk + p.weapon.atkPower;
        p.atk = p.baseAtk
        if p.weapon.passives then
            for k, v in pairs(p.weapon.passives) do
                p.passives[k] = true
            end
        end
    end

    if p.armor then
        p.baseDef= p.baseDef + p.armor.defPower;
        p.def = p.baseDef
        if p.armor.passives then
            for k, v in pairs(p.armor.passives) do
                p.passives[k] = true
            end
        end
    end

    if p.shield then
        p.baseDef= p.baseDef + p.shield.defPower;
        p.def = p.baseDef
        if p.shield.passives then
            for k, v in pairs(p.shield.passives) do
                p.passives[k] = true
            end
        end
    end
    
    for k, v in ipairs(p.passives) do
        if k:sub(1, 7) == 'strong:' then
            if k then p.strong[k:sub(8)] = true end
        end
        
        if k:sub(1, 7) == 'immune:' then
            if k then p.immune[k:sub(8)] = true end
        end
    end

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

    if p.passives['lightWielder'] and p.weapon and p.weapon.weaponWeight == 'LIGHTWEIGHT' then
        p.baseAtk = p.baseAtk * 1.5
        p.atk = p.baseAtk
    end

    if p.passives['heavyWielder'] and p.weapon and p.weapon.weaponWeight == 'HEAVYWEIGHT' then
        p.baseAtk = p.baseAtk * 1.5
        p.atk = p.baseAtk
    end

    return p
end

return P