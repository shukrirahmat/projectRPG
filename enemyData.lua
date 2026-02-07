local goblin_sprite = love.graphics.newImage('images/goblin.png')
local skeleton_sprite = love.graphics.newImage('images/skeleton.png')

local enemyData = {
    ['goblin'] = {
        hp = 30,
        mp = 0,
        atk = 60,
        def = 40,
        agi = 60,
        sprite = goblin_sprite,
        spriteHeight = monsterSpriteDimension/4
    },
    ['skeleton'] = {
        hp = 50,
        mp = 0,
        atk = 90,
        def = 50,
        agi = 40,
        sprite = skeleton_sprite,
        spriteHeight = 0,
    }
}

return enemyData
