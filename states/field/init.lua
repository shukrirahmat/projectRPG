local gameState = require('gameState')
local fieldMapper = require('states.field.fieldMapper')
local fieldMovement = require('states.field.fieldMovement')
local transition = require('systems.transition')
local movement = require('states.field.movement')
local encounter = require('states.field.encounter')

local field = {}

local state = {
    tileSize = 64
}

function field.load(stateManager, var)
    state.manager = stateManager;
    state.camera = {}
    state.camera.x = windowWidth/2 - (gameState.playerPos.x - 0.5) * state.tileSize
    state.camera.y = windowHeight/2 - (gameState.playerPos.y - 0.5) * state.tileSize
    state.mapShift = { x = 0, y = 0 }
    state.isEntering = nil
    state.isEncountering = nil
    state.currentMove = nil
    state.encounterChance = gameState.currentMap.encounterRate

    state.phase = 'fadeIn'
    transition.start({ref = 'fadeIn', speed = 0.5})
end

function field.update(dt)
    if state.phase == 'fadeIn' then
        transition.update(dt)
        if not transition.isActive() then
            state.phase = 'idle'
        end
    end

    if state.phase == 'idle' then
        if movement.isActive() then
            state.phase = 'movement'
        else
            movement.checkHold()
        end
    end

    if state.phase == 'movement' then
        movement.update(dt, state)
        if not movement.isActive() then
            if movement.isChangingLocation() then
                state.phase = 'movementTransition'
                transition.start({ref = 'fadeOut', speed = 0.5})
            elseif encounter.isEncountering() then
                state.phase = 'battleTransition'
                transition.start({ref = 'battle', speed = 1})
            else
                state.phase = 'idle'
            end
        end
    end

    if state.phase == 'movementTransition' then
        transition.update(dt)
        if not transition.isActive() then
            state.phase = 'toNextMap'
        end
    end

    if state.phase == 'toNextMap' then
        movement.changeLocation()
        state.manager.switch('field')
    end

    if state.phase == 'battleTransition' then
        transition.update(dt)
        if not transition.isActive() then
            state.phase = 'toBattle'
        end
    end

    if state.phase == 'toBattle' then
        local battlers = encounter.setup()
        state.manager.switch('battle', battlers)
    end


    --[[if state.fadesIn then
        transitions.runFadeIn(state, dt)
    elseif state.isEntering then
        fieldMovement.changeLocation(state, dt)
    elseif state.isEncountering then
        fieldMovement.encounterEnemies(state, dt)
    elseif state.currentMove then
        fieldMovement.movePlayer(state, dt)
    elseif not state.currentMove then
        fieldMovement.handleHoldMovement(state, dt)
    end]]
end

function field.draw()
    fieldMapper.drawTiles(state)
    fieldMapper.drawSpots(state)
    fieldMapper.drawPlayer(state)

    if transition.isActive then
        transition.draw()
    end
end

function field.keypressed(key) 
    if state.phase == 'idle'
    and (key == 'up' or key == 'down' or key == 'left' or key == 'right')  then
        movement.start(key)
    end
end

return field