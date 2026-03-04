local equipmentCreator = require('equipmentCreator')

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
    passiveSkills = {},
    totalExp = 0,
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
    passiveSkills = {},
    totalExp = 0
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
    passiveSkills = {},
    totalExp = 0
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
    passiveSkills = {},
    totalExp = 0
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
    p.vit = data.vit
    p.baseDef = data.vit
    p.def = p.baseDef
    p.baseAgi = data.agi
    p.agi = data.agi
    p.critRate = data.critRate or 64
    p.dodgeRate = data.dodgeRate or 0
    p.skills = data.skills or {}
    p.passiveSkills = data.passiveSkills or {}
    p.status = {}
    p.strong = data.strong or {}
    p.immune = data.immune or {}
    p.passives = {}
    p.totalExp = data.totalExp
    p.weapon = data.weapon or nil
    p.armor = data.armor or nil
    p.shield = data.shield or nil
    
    for i, ref in ipairs(p.passiveSkills) do
        p.passives[ref] = true
    end

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
    
    for k, v in pairs(p.passives) do
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