utils = require('utils')
action = require('action')
state = require('state')

local dataSheet = {
    ['goblin'] = {
        hp = 60,
        mp = 0,
        atk = 80,
        def = 60,
        agi = 80,
        sprite = goblin_sprite,
        spriteHeight = monsterSpriteDimension/4
    },

    ['skeleton'] = {
        hp = 100,
        mp = 0,
        atk = 100,
        def = 70,
        agi = 60,
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
    
    function e.chooseAction(self)
        local target = utils.selectTargetRandomly(state.party)
        local action = action.new('normalAtk', self, target)
        return action
    end
    
    return e
end

return enemy
    