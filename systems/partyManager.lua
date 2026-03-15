local expData = require('data.expData')
local statGain = require('data.statGain')

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
    
    return {lvl = member.lvl}
end
    

function partyManager.getNextExp(member)
    return expData[member.lvl + 1] - member.totalExp
end

function partyManager.increaseExp(member, exp)
    member.totalExp = member.totalExp + exp
    if member.totalExp >= expData[member.lvl + 1] then
        return levelUp(member)
    end
end


return partyManager