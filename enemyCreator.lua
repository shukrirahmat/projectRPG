utils = require('utils')
state = require('state')

local dataSheet = {
    ['goblin'] = {
        lvl = 12,
        hp = 60,
        mp = 20,
        str = 80,
        def = 60,
        agi = 80,
        sprite = goblin_sprite,
        spriteHeight = monsterSpriteDimension/4,
        strong = {},
        immune = {},
        skills = {'toxinII'},
        passives = {['pincher'] = true},
        gold = 300
    },

    ['skeleton'] = {
        lvl = 18,
        hp = 100,
        mp = 40,
        str = 100,
        def = 70,
        agi = 60,
        sprite = skeleton_sprite,
        spriteHeight = 0,
        strong = {},
        immune = {},
        specialType = 'UNDEAD',
        skills = {},
        gold = 50
    },

    ['dragon'] = {
        lvl = 25,
        hp = 250,
        mp = 20,
        str = 120,
        def = 100,
        agi = 50,
        sprite = dragon_sprite,
        spriteHeight = 0,
        strong = {},
        immune = {},
        specialType = 'DRAGON',
        skills = {},
        gold = 250
    }
}

local enemyCreator = {}

function enemyCreator.new(species, name)

    local data = dataSheet[species]
    local e = {}

    e.isDead = false

    e.species = species
    e.name = name
    e.lvl = data.lvl
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
    e.dodgeRate = data.dodgeRate or 0
    e.sprite = data.sprite
    e.spriteHeight = data.spriteHeight
    e.strong = data.strong or {}
    e.immune = data.immune or {}
    e.specialType = data.specialType
    e.status = {}
    e.skills = data.skills or {} 
    e.passives = data.passives or {}
    e.stealableGold = data.gold or 0
    e.droppedGold = data.gold or 0
    
    if e.passives['keenEye+'] then
        e.critRate = 8
    elseif e.passives['keenEye'] then
        e.critRate = 16
    end
    
    if e.passives['evasion+'] then
        e.dodgeRate = 2
    elseif e.passives['evasion'] then
        e.dodgeRate = 4
    end
    
    if e.passives['immunity'] then
        for i, element in ipairs(e.passives['immunity']) do
            e.immune[element] = true
        end
    end
    
    if e.passives['arcaneProtection'] then
        e.strong['FIRE'] = true
        e.strong['ICE'] = true
        e.strong['BOLT'] = true
        e.strong['WIND'] = true
    end
    
    if e.passives['celestialProtection'] then
        e.strong['LIGHT'] = true
        e.strong['VOID'] = true
    end

    return e
end

return enemyCreator
