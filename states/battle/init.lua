local gameState = require('gameState')
local battleHud = require('states.battle.battleHud')

local battle = {}

local state = {}

function battle.load(stateManager, var)
    state.manager = stateManager
    state.party = var.party
    state.enemies = var.enemies
    state.mainMenu = {position = 1, list = {'FIGHT', 'FLEE'}}
    state.characterMenu = {position = 1, list = {'ATTACK', 'SKILL', 'DEFEND', 'ITEM'}, charID = 1}
    state.targetMenu = {position = 1}
    state.skillMenu = {position = 1}
    state.itemMenu = {position = 1}
    state.currentMenu = state.mainMenu
    state.battleRunning = false
    state.actionList = {}
    state.priorityList = {}
    state.effectList = {}
    state.killList = {}
    state.followUp = {}
    state.textTimer = 0
    state.textSpeed = 1
    state.battleLog = {'Enemy encountered!'}
    state.bottomMenuHeight = 180
    state.partyDied = false
    state.allEnemyDead = false
    state.battleEnded = false
    state.animation = nil
    state.encounterMessage = true;
end

function battle.update(dt)
end

function battle.draw()
    battleHud.draw(state)
end

function battle.keypressed(key)
end

return battle