local sprites = require('graphics.sprites')

local enemyData = {}

enemyData['slime'] = {
    lvl = 1,
    hp = 8,
    mp = 0,
    str = 10,
    vit = 1,
    agi = 2,
    sprite = sprites['slime'],
    spriteHeight = monsterSpriteDimension/2.2,
    gold = 5,
    exp = 28,
    skills = {},
    passiveSkills = {}
    
}

enemyData['goblin'] = {
    lvl = 2,
    hp = 15,
    mp = 0,
    str = 15,
    vit = 2,
    agi = 4,
    sprite = sprites['goblin'],
    spriteHeight = monsterSpriteDimension/4,
    gold = 12,
    exp = 36,
    skills = {},
    passiveSkills = {}
    
}

return enemyData;