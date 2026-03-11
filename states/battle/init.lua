local gameState = require('gameState')
local battleHud = require('states.battle.battleHud')
local battleSprites = require('states.battle.battleSprites')
local battleMenu = require('states.battle.battleMenu')
local battleLog = require('states.battle.battleLog')
local battleInput = require('states.battle.battleInput')
local battleLoop = require('states.battle.battleLoop')
local battleAnimation = require('states.battle.battleAnimation')
local transitions = require('systems.transitions')

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
    state.actionQueue = {}
    state.priorityQueue = {}
    state.effectQueue = {}
    state.killQueue = {}
    state.followUpQueue = {}
    state.actionTimer = 0
    state.actionSpeed = 1
    state.battleLog = {}
    state.menuHeight = 180
    state.menuItemHeight = (state.menuHeight - 20) / 4
    state.partyDied = false
    state.allEnemyDead = false
    state.battleEnded = false
    state.animation = nil
    state.encounterMessage = {'Enemies encountered!'}
    state.transition = { cat = 'fadeIn', timer = 0, max = 0.5 }
    state.fadesIn = true;
end

function battle.update(dt)
    if state.fadesIn then
        transitions.runFadeIn(state, dt)
    end

    if state.encounterMessage then
        battleLog.showEncounterMessage(state, dt)
    elseif state.battleRunning then
        battleLoop.run(state, dt)
    end

    if state.animation then
        battleAnimation.run(state, dt)
    end
end

function battle.draw()

    battleSprites.draw(state)
    battleHud.draw(state)

    if not state.encounterMessage and not state.battleRunning then
        battleMenu.draw(state)
    end

    if state.transition then
        transitions.draw(state)
    end

    if #state.battleLog > 0 then
        battleLog.draw(state)
    end
end

function battle.keypressed(key)
    if not state.encounterMessage and not state.battleRunning then
        if key == 'up' then
            battleInput.executeUp(state)
        elseif key == 'down' then
            battleInput.executeDown(state)
        elseif key == 'left' then
            battleInput.executeLeft(state)
        elseif key == 'right' then
            battleInput.executeRight(state)
        elseif key == 'z' then
            battleInput.executeConfirm(state)
        elseif key == 'x' then
            battleInput.executeCancel(state)
        end
    end
end

return battle