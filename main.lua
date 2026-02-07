require('globals')

function love.load()
    
    local partyData = require('partyData')
    local enemyData = require('enemyData')
    local party = {
        createCharacter(partyData[1]),
        createCharacter(partyData[2]),
        createCharacter(partyData[3]),
        createCharacter(partyData[4])
    }
    local enemies = {
        createCharacter(enemyData['goblin'], 'GOBLIN1'),
        createCharacter(enemyData['goblin'], 'GOBLIN2'),
        createCharacter(enemyData['goblin'], 'GOBLIN3'),
        createCharacter(enemyData['skeleton'], 'SKELETON1'),
        createCharacter(enemyData['skeleton'], 'SKELETON2')
    }
    battle = createBattle(party, enemies)
    controller = createController(battle)
end

function love.update(dt)
    
end

function love.draw()
    battle.draw()
end

function love.keypressed(key)
    controller.execute(key)
end