local gameState = require('gameState')
local transition = require('systems.transition')
local movement = require('states.field.movement')
local encounter = require('states.field.encounter')
local mapper = require('states.field.mapper')

local field = {}

local state = {}

function field.load(stateManager, var)
    state.manager = stateManager;
    mapper.load()
    encounter.load()
    transition.load({ref = 'fadeIn', speed = 0.5})
    
    state.phase = 'fadeIn'
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
                transition.load({ref = 'fadeOut', speed = 0.5})
            elseif encounter.isEncountering() then
                state.phase = 'battleTransition'
                transition.load({ref = 'battle', speed = 1})
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
end

function field.draw()
    mapper.draw()

    if transition.isActive then
        transition.draw()
    end
end

function field.keypressed(key) 
    if state.phase == 'idle'
    and (key == 'up' or key == 'down' or key == 'left' or key == 'right')  then
        movement.load(key)
    end
end

return field