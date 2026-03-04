utils = require('utils')
itemCreator = require('itemCreator')

local dataSheet = {
    ['slime'] = {
        lvl = 1,
        hp = 8,
        mp = 0,
        str = 6,
        def = 1,
        agi = 3,
        sprite = slime_sprite,
        spriteHeight = monsterSpriteDimension/2,
        gold = 5
    },
    ['goblin'] = {
        lvl = 2,
        hp = 12,
        mp = 0,
        str = 8,
        def = 1,
        agi = 8,
        sprite = goblin_sprite,
        spriteHeight = monsterSpriteDimension/4,
        gold = 8
    },
    
    ['armoredGoblin'] = {
        lvl = 22,
        hp = 160,
        mp = 120,
        str = 90,
        def = 180,
        agi = 80,
        sprite = armored_goblin_sprite,
        spriteHeight = monsterSpriteDimension/4,
        strong = {},
        immune = {},
        specialType = 'ARMORED',
        skills = {},
        passives = {},
        gold = 300,
        stealableItem = { item = itemCreator.new('healingTonic'), rate = 8 }
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
        skills = {'hexII'},
        passives = {},
        gold = 50,
        stealableItem = { item = itemCreator.new('holyWater'), rate = 16}
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
        strong = {['FIRE'] = true},
        immune = {},
        specialType = 'DRAGON',
        skills = {},
        passives = {},
        gold = 250,
        stealableItem = { item = itemCreator.new('prismTonic'), rate = 32 }
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
    e.stealableItem = data.stealableItem or nil
    e.stealableGold = data.gold or 0
    e.droppedGold = data.gold or 0
    
    for k, v in pairs(e.passives) do
        if k:sub(1, 7) == 'strong:' then
            if k then e.strong[k:sub(8)] = true end
        end
        
        if k:sub(1, 7) == 'immune:' then
            if k then e.immune[k:sub(8)] = true end
        end
    end
    
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
