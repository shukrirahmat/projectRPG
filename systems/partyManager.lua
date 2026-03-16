local expData = require('data.expData')
local learnData = require('data.learnData')
local actionData = require('data.actionData')
local statGain = require('data.statGain')
local textBox = require('systems.textBox')

local partyManager = {}

local function levelUp(member)
    member.lvl = member.lvl + 1;
    
    local data = statGain[member.id]
    local statIndex = math.ceil(member.lvl / 10)
    member.maxHp = member.maxHp + data['hp'][statIndex]
    member.maxMp = member.maxMp + data['mp'][statIndex]
    member.str = member.str + data['str'][statIndex]
    member.vit = member.vit + data['vit'][statIndex]
    member.agi = member.agi + data['agi'][statIndex]
    
    local skillName = nil
    local skillRef = learnData[member.id][member.lvl] or nil
    if skillRef then
        table.insert(member.skills, skillRef)
        skillName = actionData[skillRef].name
    end
    
    return {
        member = member,
        lvl = member.lvl,
        skill = skillName
    }
end

function partyManager.increaseExp(member, exp)
    local lvlUps = {}
    
    member.totalExp = member.totalExp + exp
    
    while member.totalExp >= expData[member.lvl + 1] do
        table.insert(lvlUps, levelUp(member))
    end
    
    return lvlUps;
end


return partyManager