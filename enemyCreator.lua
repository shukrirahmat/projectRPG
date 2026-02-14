utils = require('utils')
state = require('state')

local dataSheet = {
    ['goblin'] = {
        hp = 60,
        mp = 20,
        atk = 80,
        def = 60,
        agi = 80,
        sprite = goblin_sprite,
        spriteHeight = monsterSpriteDimension/4,
        strong = { ['FIRE'] = true, ['DEATH'] = true},
        immune = {},
        skills = {}
    },

    ['skeleton'] = {
        hp = 100,
        mp = 40,
        atk = 100,
        def = 70,
        agi = 60,
        sprite = skeleton_sprite,
        spriteHeight = 0,
        strong = {['BLIND'] = true},
        immune = { ['ICE'] = true , ['DEATH'] = true },
        specialType = 'UNDEAD',
        skills = {'midFire', 'fireBlast'}
    },

    ['dragon'] = {
        hp = 250,
        mp = 20,
        atk = 120,
        def = 100,
        agi = 50,
        sprite = dragon_sprite,
        spriteHeight = 0,
        strong = {['FIRE'] = true, ['ICE'] = true, ['BOLT'] = true, ['WIND'] = true},
        immune = {['STUN'] = true},
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
    e.baseAtk = data.atk
    e.baseDef = data.def
    e.baseAgi = data.agi
    e.atk = data.atk
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
