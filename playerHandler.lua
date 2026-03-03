local owState = require('overworldState')
local mapData = require('mapData')
local mapHandler = require('mapHandler')

local playerHandler = {}

local directions = {
    up = {
        dx = 0, dy = -1,
        axis = "y",
        sprite = player_back,
        boundCheck = function() return owState.playerPos.y > 1 end
    },
    down = {
        dx = 0, dy = 1,
        axis = "y",
        sprite = player_front,
        boundCheck = function() return owState.playerPos.y < owState.currentMap.size.y end
    },
    left = {
        dx = -1, dy = 0,
        axis = "x",
        sprite = player_left,
        boundCheck = function() return owState.playerPos.x > 1 end
    },
    right = {
        dx = 1, dy = 0,
        axis = "x",
        sprite = player_right,
        boundCheck = function() return owState.playerPos.x < owState.currentMap.size.x end
    }
}

local function getNextMove(currentMove)
    
    if owState.mainMenuOpen then
        return nil
    end
    
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

function playerHandler.travelTo(ref)
    owState.currentMap = mapData[ref]
    mapHandler.load()
end

function playerHandler.movePlayer(dt)
    local dir = directions[owState.currentMove]
    if not dir then return end

    owState.moveTimer = owState.moveTimer - dt
    owState.currentSprite = dir.sprite[1]

    if not dir.boundCheck() then
        owState.currentMove = getNextMove(owState.currentMove)
        owState.moveTimer = owState.moveSpeed
        return
    end

    local progress = owState.moveTimer / owState.moveSpeed
    local shiftAmount = (1 - progress) * owState.tileSize

    if owState.moveTimer > 0 then
        owState.moveShift[dir.axis] = dir.dy ~= 0 and dir.dy * shiftAmount or dir.dx * shiftAmount

        local step = math.abs(owState.moveShift[dir.axis]) / owState.tileSize
        if step <= 0.25 then
            owState.currentSprite = dir.sprite[2]
        elseif step <= 0.5 then
            owState.currentSprite = dir.sprite[1]
        elseif step <= 0.75 then
            owState.currentSprite = dir.sprite[3]
        end
    else
        owState.moveShift[dir.axis] = 0

        owState.playerPos.x = owState.playerPos.x + dir.dx
        owState.playerPos.y = owState.playerPos.y + dir.dy

        owState.camera.x = owState.camera.x - dir.dx * owState.tileSize
        owState.camera.y = owState.camera.y - dir.dy * owState.tileSize

        owState.moveTimer = owState.moveSpeed

        local spot = owState.currentMap.spots[''..owState.playerPos.x..','..owState.playerPos.y..'']
        if spot then
            owState.currentMove = nil
            if spot.category == 'gates' then
                playerHandler.travelTo(spot.to)
            end
        else
            owState.currentMove = getNextMove(owState.currentMove)
        end
    end
end

return playerHandler