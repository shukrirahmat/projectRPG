local dataSheet = {
    ['goblin'] = {
        maxHp = 30,
        currentHp = 30,
        currentMp = 0,
        maxMp = 0,
        attack = 60,
        defense = 40,
        agility = 60,
        sprite = goblin_sprite,
        spriteHeight = monsterSpriteDimension/4
    },

    ['skeleton'] = {
        maxHp = 50,
        currentHp = 50,
        currentMp = 0,
        maxMp = 0,
        attack = 90,
        defense = 50,
        agility = 40,
        sprite = skeleton_sprite,
        spriteHeight = 0,
    }
}

local enemy = {}

function enemy.new(species, name)
    
    local data = dataSheet[species]
    local e = {}

    e.isDead = false

    e.name = name
    e.maxHp = data.hp
    e.currentHp = data.hp
    e.maxMp = data.mp
    e.currentMp = data.mp
    e.atk = data.atk
    e.def = data.def
    e.agi = data.agi
    e.critRate = data.critRate or 128
    e.sprite = data.sprite
    e.spriteHeight = data.spriteHeight
    
    return e
end

return enemy
    