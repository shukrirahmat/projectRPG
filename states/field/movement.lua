local gameState = require('gameState')
local encounter = require('states.field.encounter')
local mapper = require('states.field.mapper')
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
        if spot.category == 'gates' then
            move.nextMap = require('maps.'..spot.to..'')
            move.isChangingLocation = true
        end
    end

    if not spot and encounter.hasEncounter() then
        encounter.attempt()
    end

    move.active = false
end

function movement.checkHold()
    if move.active then return end

    if love.keyboard.isDown('up') then
        movement.load('up')
    elseif love.keyboard.isDown('down') then
        movement.load('down')
    elseif love.keyboard.isDown('left') then
        movement.load('left')
    elseif love.keyboard.isDown('right') then
        movement.load('right')
    end
end

function movement.load(key)
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

function movement.update(dt)
    move.timer = move.timer + dt

    local dir = directions[move.key]
    gameState.playerSprite = dir.sprite[1]

    if not dir.boundCheck() then
        move.active = false;
        move.timer = 0
        return
    end

    local progress = move.timer / move.speed

    if move.timer < move.speed then
        mapper.shiftMap(dir, progress)
    else
        mapper.stopMovement(dir)
        move.timer = 0
        handlePostMovement()
    end
end

return movement