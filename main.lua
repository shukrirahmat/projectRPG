require('globals')
local battle = require('battle')
local partyMember = require('partyMember')
local enemy = require('enemy')

function love.load()
    
    local party = { 
        partyMember.new(1), 
        partyMember.new(2), 
        partyMember.new(3), 
        partyMember.new(4)
    }
    
    local enemies = { 
        enemy.new('goblin', 'GOBLIN1'),
        enemy.new('goblin', 'GOBLIN2'),
        enemy.new('goblin', 'GOBLIN3'),
        enemy.new('dragon', 'DRAGON1'),
        enemy.new('skeleton', 'SKELETON1'),
        enemy.new('skeleton', 'SKELETON2')
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