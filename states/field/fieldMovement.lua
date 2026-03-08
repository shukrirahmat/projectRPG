local gameState = require('gameState')
local sprites = require('graphics.sprites')

local fieldMovement = {}

local directions = {
    up = {
        dx = 0, dy = -1,
        axis = "y",
        sprite = sprites.player_back,
        boundCheck = function() return gameState.playerPos.y > 1 end
    },
    down = {
        dx = 0, dy = 1,
        axis = "y",
        sprite = sprites.player_front,
        boundCheck = function() return gameState.playerPos.y < gameState.currentMap.size.y end
    },
    left = {
        dx = -1, dy = 0,
        axis = "x",
        sprite = sprites.player_left,
        boundCheck = function() return gameState.playerPos.x > 1 end
    },
    right = {
        dx = 1, dy = 0,
        axis = "x",
        sprite = sprites.player_right,
        boundCheck = function() return gameState.playerPos.x < gameState.currentMap.size.x end
    }
}

local function getNextMove(currentMove)
    --[[if owState.onMenu then
        return nil
    end]]

    if currentMove == 'up' then
        if love.keyboard.isDown('up') then return 'up'
        elseif love.keyboard.isDown('right') then return 'right'
        elseif love.keyboard.isDown('left') then return 'left'
        elseif love.keyboard.isDown('down') then return 'down'
        end
    elseif currentMove == 'down' then
        if love.keyboard.isDown('down') then return 'down'
        elseif love.keyboard.isDown('left') then return 'left'
        elseif love.keyboard.isDown('right') then return 'right'
        elseif love.keyboard.isDown('up') then return 'up'
        end
    elseif currentMove == 'right' then
        if love.keyboard.isDown('right') then return 'right'
        elseif love.keyboard.isDown('down') then return 'down'
        elseif love.keyboard.isDown('up') then return 'up'
        elseif love.keyboard.isDown('left') then return 'left'
        end
    elseif currentMove == 'left' then
        if love.keyboard.isDown('left') then return 'left'
        elseif love.keyboard.isDown('up') then return 'up'
        elseif love.keyboard.isDown('down') then return 'down'
        elseif love.keyboard.isDown('right') then return 'right'
        end
    end

    return nil
end

local function handlePostMovement(state)
    
    local spotCoordinate = ''..gameState.playerPos.x..','..gameState.playerPos.y..''
    local spot = gameState.currentMap.spots[spotCoordinate]
    if spot then
        state.currentMove = nil
        if spot.category == 'gates' then
            local nextMap = require('maps.'..spot.to..'')
            state.transition = {cat = 'fadeOut', timer = 0, max = 0.5 }
            state.isEntering = nextMap
            return
        end
    end
    
    if state.encounterChance then
        local roll = math.random(1, state.encounterChance)
        if roll == 1 then
            state.currentMove = nil
            state.encounterChance = gameState.currentMap.encounterRate
            state.transition = {cat = 'enemyEncounter', timer = 0, max = 1 }
            state.isEncountering = true;
            return
        else
            state.encounterChance = math.floor(state.encounterChance * 0.8)
        end
    end

    state.currentMove = getNextMove(state.currentMove)
end


function fieldMovement.movePlayer(dt, state)
    local dir = directions[state.currentMove]
    state.moveTimer = state.moveTimer - dt
    gameState.playerSprite = dir.sprite[1]

    if not dir.boundCheck() then
        state.currentMove = getNextMove(state.currentMove)
        state.moveTimer = state.moveSpeed
        return
    end

    local progress = state.moveTimer / state.moveSpeed
    local shiftAmount = (1 - progress) * state.tileSize

    if state.moveTimer > 0 then
        state.mapShift[dir.axis] = dir.dy ~= 0 and dir.dy * shiftAmount or dir.dx * shiftAmount
        local step = math.abs(state.mapShift[dir.axis]) / state.tileSize
        if step <= 0.25 then
            gameState.playerSprite = dir.sprite[2]
        elseif step <= 0.5 then
            gameState.playerSprite = dir.sprite[1]
        elseif step <= 0.75 then
            gameState.playerSprite = dir.sprite[3]
        end
    else
        state.mapShift[dir.axis] = 0
        gameState.playerPos.x = gameState.playerPos.x + dir.dx
        gameState.playerPos.y = gameState.playerPos.y + dir.dy
        state.camera.x = state.camera.x - dir.dx * state.tileSize
        state.camera.y = state.camera.y - dir.dy * state.tileSize
        state.moveTimer = state.moveSpeed
        handlePostMovement(state)
    end
end

function fieldMovement.changeLocation(dt, state)
    
    state.transition.timer = state.transition.timer + dt
    if state.transition.timer >= state.transition.max then
        state.transition = nil
        local nextMap = state.isEntering;
        gameState.currentMap = nextMap
        gameState.playerPos = nextMap.startPos
        gameState.playerSprite = sprites.player_front[1]
        state.manager.switch('field', {fadesIn = true})
    end
end

function fieldMovement.encounterEnemies(dt, state)
    
    state.transition.timer = state.transition.timer + dt
    if state.transition.timer >= state.transition.max then
        --state.transition = nil
        --state.transitionTimer = state.transitionSpeed
    end
end

function fieldMovement.doFadeIn(dt, state)
    state.transition.timer = state.transition.timer + dt
    if state.transition.timer >= state.transition.max then
        state.transition = nil
        state.fadesIn = nil
    end
end

function fieldMovement.handleHoldMovement(dt, state)
    if state.currentMove then return end

    if love.keyboard.isDown("up") then
        state.currentMove = 'up'
    elseif love.keyboard.isDown("down") then
        state.currentMove = 'down'
    elseif love.keyboard.isDown("left") then
        state.currentMove = 'left'
    elseif love.keyboard.isDown("right") then
        state.currentMove = 'right'
    end
end

return fieldMovement