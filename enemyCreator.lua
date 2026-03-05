local utils = require('utils')
local battlerCreator = require('battlerCreator')

local dataSheet = {
    ['slime'] = {
        lvl = 1,
        hp = 8,
        mp = 0,
        str = 6,
        vit = 1,
        agi = 3,
        sprite = slime_sprite,
        spriteHeight = monsterSpriteDimension/2.2,
        gold = 5
    },
    ['goblin'] = {
        lvl = 2,
        hp = 12,
        mp = 0,
        str = 8,
        vit = 1,
        agi = 8,
        sprite = goblin_sprite,
        spriteHeight = monsterSpriteDimension/4,
        gold = 8
    },
}

local enemyCreator = {}

function enemyCreator.new(species, name)

    local data = dataSheet[species]
    
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

    return battler
end

return enemyCreator
