local sprites = require('graphics.sprites')

local enemyData = {}

enemyData['slime'] = {
    lvl = 1,
    hp = 9999,
    mp = 50,
    str = 100,
    vit = 80,
    agi = 150,
    sprite = sprites['slime'],
    spriteHeight = monsterSpriteDimension/2.2,
    gold = 50,
    exp = 150,
    skills = {'hexIII'},
    passiveSkills = {}
    
}

enemyData['goblin'] = {
    lvl = 2,
    hp = 9999,
    mp = 50,
    str = 100,
    vit = 80,
    agi = 150,
    sprite = sprites['goblin'],
    spriteHeight = monsterSpriteDimension/4,
    gold = 80,
    exp = 150,
    skills = {'paralyzeIII'},
    passiveSkills = {}
    
}

return enemyData;