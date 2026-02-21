utils = require('utils')
state = require('state')

local dataSheet = {
    ['goblin'] = {
        hp = 60,
        mp = 20,
        str = 80,
        def = 60,
        agi = 80,
        sprite = goblin_sprite,
        spriteHeight = monsterSpriteDimension/4,
        strong = {['VOID'] = true},
        immune = {},
        skills = {}
    },

    ['skeleton'] = {
        hp = 100,
        mp = 40,
        str = 100,
        def = 70,
        agi = 60,
        sprite = skeleton_sprite,
        spriteHeight = 0,
        strong = {['FIRE'] = true},
        immune = {['VOID'] = true},
        specialType = 'UNDEAD',
        skills = {}
    },

    ['dragon'] = {
        hp = 250,
        mp = 20,
        str = 120,
        def = 100,
        agi = 50,
        sprite = dragon_sprite,
        spriteHeight = 0,
        strong = {},
        immune = {['FIRE'] = true},
        specialType = 'DRAGON',
        skills = {}
    }
}

local enemyCreator = {}

function enemyCreator.new(species, name)

    local data = dataSheet[species]
    local e = {}

    e.isDead = false

    e.species = species
    e.name = name
    e.maxHp = data.hp
    e.currentHp = data.hp
    e.maxMp = data.mp
    e.currentMp = data.mp
    e.str = data.str
    e.baseAtk = data.str
    e.baseDef = data.def
    e.baseAgi = data.agi
    e.atk = data.str
    e.def = data.def
    e.agi = data.agi
    e.critRate = data.critRate or 128
    e.sprite = data.sprite
    e.spriteHeight = data.spriteHeight
    e.strong = data.strong or {}
    e.immune = data.immune or {}
    e.specialType = data.specialType
    e.status = {}
    e.skills = data.skills or {} 

    return e
end

return enemyCreator
