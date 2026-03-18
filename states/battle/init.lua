local gameState = require('gameState')
local battleHud = require('states.battle.battleHud')
local battleSprites = require('states.battle.battleSprites')
local battleMenu = require('states.battle.battleMenu')
local battleLog = require('states.battle.battleLog')
local battleInput = require('states.battle.battleInput')
local battleLoop = require('states.battle.battleLoop')
local battleHandler = require('states.battle.battleHandler')
local battleAnimation = require('states.battle.battleAnimation')
local testingDetails = require('states.battle.testingDetails')
local transition = require('systems.transition')

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
    state.exitBattle = false;
    
    transition.load({ref = 'fadeIn', speed = 0.5})
    state.phase = 'intro'
end

function battle.update(dt)
    
    if state.phase == 'intro' then
        transition.update(dt)
        battleLog.showEncounterMessage(state, dt)
        if not transition.isActive() and not state.encounterMessage then
            state.phase = 'menuInput'
        end
    end
    
    if state.phase == 'menuInput' then
        if state.battleRunning then
            state.phase = 'battleRunning'
        end
    end
    
    if state.phase == 'battleRunning' then
        battleLoop.run(state, dt)
        if state.animation then
            battleAnimation.run(state, dt)
        end
        
        if not state.battleRunning then
            if state.exitBattle then
                state.phase = 'exiting'
            else
                state.phase = 'menuInput'
            end
        end
    end
    
    if state.phase == 'exiting' then
        battleHandler.exitBattle(state, dt)
    end
    
    --[[if state.fadesIn then
        transitions.runFadeIn(state, dt)
    end

    if state.encounterMessage then
        battleLog.showEncounterMessage(state, dt)
    elseif state.exitBattle then
        battleHandler.exitBattle(state, dt)
    elseif state.battleRunning then
        battleLoop.run(state, dt)
        if state.animation then
            battleAnimation.run(state, dt)
        end
    end]]
end

function battle.draw()

    battleSprites.draw(state)
    battleHud.draw(state)

    if state.phase == 'menuInput' then
        battleMenu.draw(state)
    end

    if transition.isActive() then
        transition.draw()
    end

    if #state.battleLog > 0 then
        battleLog.draw(state)
    end
    
    --TEMPORARY
    testingDetails.draw(state)
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