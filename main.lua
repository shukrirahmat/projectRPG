require('globals')
require('helperFunction')
local createTopWindow = require('createTopWindow')
local createEnemySprites = require('createEnemySprites')
local createMenu = require('createMenu')
local createController = require('createController')
local characterSheet = require('characterSheet')
local createCharacter = require('createCharacter')
local createBattle = require('createBattle')

function love.load()

    local partySheet = characterSheet.party
    local monsterSheet = characterSheet.monsters

    local partyMembers = {}
    for i, sheet in ipairs(partySheet) do
        local member = createCharacter(sheet.name, true, sheet)
        table.insert(partyMembers, member)
    end

    local enemies = {}
    local goblinSheet = monsterSheet['goblin']
    local skeletonSheet = monsterSheet['skeleton']
    table.insert(enemies, createCharacter(''..goblinSheet.name..'1', false, goblinSheet))
    table.insert(enemies, createCharacter(''..goblinSheet.name..'2', false, goblinSheet))
    table.insert(enemies, createCharacter(''..skeletonSheet.name..'1', false, skeletonSheet))
    table.insert(enemies, createCharacter(''..skeletonSheet.name..'2', false, skeletonSheet))
    table.insert(enemies, createCharacter(''..skeletonSheet.name..'3', false, skeletonSheet))

    battle = createBattle(partyMembers, enemies)
    topWindow = createTopWindow(battle.getParty())
    enemySprites = createEnemySprites(battle.getEnemies())
    menu = createMenu(battle)
    controller = createController(menu)
end

function love.update(dt)
    
    if battle.isRunning() then
        battle.setTimer(battle.getTimer() + dt)
    end
    
    if battle.getTimer() > battle.getSpeed() then
        battle.playQueue(menu)
        battle.setTimer(0)
    end

end

function love.draw()

    ---------------------------------TOP-----------------------------------

    topWindow.draw()

    --------------------------------MIDDLE---------------------------------

    enemySprites.draw()

    --------------------------------BOTTOM---------------------------------
    
    if not battle.isRunning() then
        menu.draw()
    end
end

function love.keypressed(key)
    controller.execute(key)
end