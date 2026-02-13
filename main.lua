require('globals')
local battle = require('battle')
local partyMemberCreator = require('partyMemberCreator')
local enemyCreator = require('enemyCreator')

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
        enemyCreator.new('goblin', 'GOBLIN3'),
        enemyCreator.new('dragon', 'DRAGON1'),
        enemyCreator.new('skeleton', 'SKELETON1'),
        enemyCreator.new('skeleton', 'SKELETON2')
    }
    battle.load(party, enemies)
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