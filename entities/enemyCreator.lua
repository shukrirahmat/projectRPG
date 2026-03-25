local battlerCreator = require('entities.battlerCreator')
local enemyData = require('data.enemyData')

local enemyCreator = {}

function enemyCreator.new(species, name)

    local data = enemyData[species]
    
    local enemy = {}
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
    enemy.dodgeRate = data.dodgeRate or 0
    enemy.skills = data.skills or {}
    enemy.passiveSkills = data.passiveSkills or {}
    enemy.status = {}
    enemy.strong = data.strong or {}
    enemy.immune = data.immune or {}
    enemy.sprite = data.sprite
    
    if data.status then
        for k, v in pairs(data.status) do
            enemy.status[k] = v
        end
    end
    
    local battler = battlerCreator.new(enemy)
    battler.isPartyMember = false;
    battler.species = species
    battler.spriteHeight = data.spriteHeight
    battler.specialType = data.specialType
    battler.stealableItem = {}
    battler.stealableGold = data.gold or 0
    battler.goldDrop = data.gold or 0
    battler.itemDrop = data.itemDrop or nil
    battler.exp = data.exp or 0
    battler.actionFunc = data.actionFunc
    
    if data.stealableItem then
        for k, v in pairs(data.stealableItem) do
            battler.stealableItem[k] = v
        end
    end
    
    function battler:getEnemyAction()
        return self.actionFunc.get()
    end

    return battler
end

return enemyCreator