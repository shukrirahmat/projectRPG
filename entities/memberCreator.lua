local memberStats = require('data.memberStats')
local expData = require('data.expData')

local memberCreator = {}

function memberCreator.new(id)
    
    local data = memberStats[id]
    
    local member = {}
    
    member.id = data.id
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
    member.sprite = data.sprite
    
    local nextExp = expData[member.lvl + 1] - member.totalExp
    member.nextExp = nextExp
    
    return member
end

return memberCreator