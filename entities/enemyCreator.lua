local battlerCreator = require('entities.battlerCreator')
local enemyData = require('data.enemyData')

local enemyCreator = {}

function enemyCreator.new(species, name)

    local data = enemyData[species]
    
    enemy = {}
    enemy.name = name
    enemy.lvl = data.lvl
    enemy.maxHp = data.hp
    enemy.currentHp = data.hp
    enemy.maxMp = data.mp
    enemy.currentMp = data.mp
    enemy.str = data.str
    enemy.vit = data.vit
    enemy.agi = data.agi
    enemy.critRate = 128
    enemy.skill = data.skills or {}
    enemy.passiveSkills = data.passiveSkills or {}
    enemy.status = data.status or {}
    enemy.strong = data.strong or {}
    enemy.immune = data.immune or {}
    
    local battler = battlerCreator.new(enemy)
    battler.isPartyMember = false;
    battler.species = species
    battler.sprite = data.sprite
    battler.spriteHeight = data.spriteHeight
    battler.specialType = data.specialType
    battler.stealableItem = data.stealableItem or nil
    battler.stealableGold = data.gold or 0
    battler.droppedGold = data.gold or 0
    battler.exp = data.exp or 0

    return battler
end

return enemyCreator