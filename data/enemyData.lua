local sprites = require('graphics.sprites')

local enemyData = {}

enemyData['slime'] = {
    lvl = 1,
    hp = 8,
    mp = 0,
    str = 6,
    vit = 1,
    agi = 3,
    sprite = sprites['slime'],
    spriteHeight = monsterSpriteDimension/2.2,
    gold = 5,
    exp = 150
}

enemyData['goblin'] = {
    lvl = 2,
    hp = 12,
    mp = 0,
    str = 8,
    vit = 1,
    agi = 8,
    sprite = sprites['goblin'],
    spriteHeight = monsterSpriteDimension/4,
    gold = 8,
    exp = 150
}

return enemyData;