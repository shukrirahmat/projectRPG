local sprites = require('graphics.sprites')
local itemCreator = require('entities.itemCreator')

local enemyData = {}

enemyData['slime'] = {
    lvl = 1,
    hp = 9999,
    mp = 20,
    str = 60,
    vit = 1,
    agi = 5,
    sprite = sprites['slime'],
    spriteHeight = monsterSpriteDimension/2.2,
    gold = 50,
    exp = 150,
    skills = {'woundII'},
    passiveSkills = {}
    
}

enemyData['goblin'] = {
    lvl = 2,
    hp = 9999,
    mp = 20,
    str = 60,
    vit = 1,
    agi = 8,
    sprite = sprites['goblin'],
    spriteHeight = monsterSpriteDimension/4,
    gold = 80,
    exp = 150,
    skills = {'woundII'},
    passiveSkills = {}
    
}

return enemyData;