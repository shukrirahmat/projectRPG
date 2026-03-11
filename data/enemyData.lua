local sprites = require('graphics.sprites')
local itemCreator = require('entities.itemCreator')

local enemyData = {}

enemyData['slime'] = {
    lvl = 1,
    hp = 88,
    mp = 0,
    str = 16,
    vit = 1,
    agi = 5,
    sprite = sprites['slime'],
    spriteHeight = monsterSpriteDimension/2.2,
    gold = 50,
    exp = 150,
    passiveSkills = {'counter'}
    
}

enemyData['goblin'] = {
    lvl = 2,
    hp = 99,
    mp = 0,
    str = 18,
    vit = 1,
    agi = 8,
    sprite = sprites['goblin'],
    spriteHeight = monsterSpriteDimension/4,
    gold = 80,
    exp = 150,
    passiveSkills = {'counter'}
}

return enemyData;