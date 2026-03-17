local gameState = require('gameState')
local encounter = require('states.field.encounter')
local sprites = require('graphics.sprites')

local movement = {}

local move = {}

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

local function handlePostMovement(state)
    local spotCoordinate = ''..gameState.playerPos.x..','..gameState.playerPos.y..''
    local spot = gameState.currentMap.spots[spotCoordinate]
    if spot then
        move.active = false
        if spot.category == 'gates' then
            move.nextMap = require('maps.'..spot.to..'')
            move.isChangingLocation = true
            return
        end
    end

    if state.encounterChance then
        local roll = math.random(1, state.encounterChance)
        if roll == 1 then
            move.active = false
            state.encounterChance = gameState.currentMap.encounterRate
            encounter.start();
            return
        else
            state.encounterChance = math.floor(state.encounterChance * 0.8)
        end
    end

    move.active = false
end

function movement.checkHold()
    if move.active then return end

    if love.keyboard.isDown('up') then
        movement.start('up')
    elseif love.keyboard.isDown('down') then
        movement.start('down')
    elseif love.keyboard.isDown('left') then
        movement.start('left')
    elseif love.keyboard.isDown('right') then
        movement.start('right')
    end
end

function movement.start(key)
    move.active = true
    move.key = key
    move.timer = 0
    move.speed = 0.3
    move.nextMap = nil
    move.isChangingLocation = false
    move.isEncountering = false
end

function movement.isActive()
    return move.active
end

function movement.isChangingLocation()
    return move.isChangingLocation
end

function movement.changeLocation()
    gameState.currentMap = move.nextMap
    gameState.playerPos = move.nextMap.startPos
    gameState.playerSprite = sprites.player_front[1]
    
    move.nextMap = nil
    move.isChangingLocation = false
end

function movement.update(dt, state)
    move.timer = move.timer + dt

    local dir = directions[move.key]
    gameState.playerSprite = dir.sprite[1]

    if not dir.boundCheck() then
        move.active = false;
        move.timer = 0
        return
    end

    local progress = move.timer / move.speed
    local shiftAmount = progress * state.tileSize

    if move.timer < move.speed then
        state.mapShift[dir.axis] = math.floor(dir.dy ~= 0 and dir.dy * shiftAmount or dir.dx * shiftAmount)
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
        move.timer = 0
        handlePostMovement(state)
    end
end

return movement