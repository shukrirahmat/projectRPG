local party = {
    {
        name = 'KNIGHT',
        hp = 200,
        mp = 0,
        atk = 80,
        def = 80,
        agi = 60,
        critRate = 64
    },
    {
        name = 'FIGHTER',
        hp = 180,
        mp = 0,
        atk = 70,
        def = 50,
        agi = 100,
        critRate = 8
    },
    {
        name = 'PRIEST',
        hp = 160,
        mp = 50,
        atk = 60,
        def = 50,
        agi = 80,
        critRate = 64,
        skills = {1}
    },

    {
        name = 'MAGE',
        hp = 120,
        mp = 150,
        atk = 30,
        def = 40,
        agi = 80,
        critRate = 64,
        skills = { 2, 3 }
    }
}

local goblin_sprite = love.graphics.newImage('images/goblin.png')
local skeleton_sprite = love.graphics.newImage('images/skeleton.png')

local monsters = {

    ['goblin'] = {
        name = 'GOBLIN',
        hp = 30,
        mp = 0,
        atk = 60,
        def = 40,
        agi = 60,
        sprite = goblin_sprite,
        spriteHeight = monsterSpriteDimension/4
    },

    ['skeleton'] = {
        name = 'SKELETON',
        hp = 50,
        mp = 0,
        atk = 90,
        def = 50,
        agi = 40,
        sprite = skeleton_sprite,
        spriteHeight = 0,
        strongAgainst = {'FIRE'}
    }
}

return {
    party = party,
    monsters = monsters
    }