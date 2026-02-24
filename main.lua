require('globals')
local battle = require('battle')
local partyMemberCreator = require('partyMemberCreator')
local enemyCreator = require('enemyCreator')
local itemCreator = require('itemCreator')

function love.load()
    math.randomseed(os.time())
    
    local party = { 
        partyMemberCreator.new(1), 
        partyMemberCreator.new(2), 
        partyMemberCreator.new(3), 
        partyMemberCreator.new(4)
    }
    
    local enemies = { 
        enemyCreator.new('goblin', 'GOBLIN1'),
        enemyCreator.new('goblin', 'GOBLIN2'),
        enemyCreator.new('armoredGoblin', 'ARMGOB1'),
        enemyCreator.new('dragon', 'DRAGON1'),
        enemyCreator.new('skeleton', 'SKELETON1'),
        enemyCreator.new('skeleton', 'SKELETON2')
    }
    
    local items = {
        ['healingTonic'] = { item = itemCreator.new('healingTonic'), amount = 10 },
        ['holyWater'] = { item = itemCreator.new('holyWater'), amount = 5 }
        }
    
    battle.load(party, enemies, 2500, items)
end

function love.update(dt)
    battle.update(dt)
end

function love.draw()
    battle.draw()
end

function love.keypressed(key)
    battle.keypressed(key)
end