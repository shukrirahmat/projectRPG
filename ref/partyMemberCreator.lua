local partyMemberCreator = {}

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
    status = {},
    totalExp = 0
}

function partyMemberCreator.new(ref)
    local data = dataSheet[ref]
    local member = {}
    
    member.name = data.name
    member.lvl = data.lvl
    member.currentHp = data.hp
    member.maxHp = data.hp
    member.currentMp = data.mp
    member.maxMp = data.mp
    member.str = data.str
    member.vit = data.vit
    member.agi = data.agi
    member.skills = data.skills
    member.passiveSkills = data.passiveSkills
    member.status = data.status or {}
    member.strong = data.strong or {}
    member.immune = data.immune or {}
    member.totalExp = data.totalExp
    member.weapon = data.weapon or nil
    member.shield = data.shield or nil
    member.armor = data.armor or nil
    
    return member
end


return partyMemberCreator