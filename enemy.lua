local dataSheet = {
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
    