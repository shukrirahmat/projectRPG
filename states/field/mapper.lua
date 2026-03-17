local gameState = require('gameState')
local sprites = require('graphics.sprites')

local mapper = {}

local state = {
    tileSize = 64
}

local function drawTiles()
    for y = 1, gameState.currentMap.size.y do
        for x = 1, gameState.currentMap.size.x do
            local floor = gameState.currentMap.floor
            love.graphics.setColor(floor.r, floor.g, floor.b)
            love.graphics.rectangle(
                'fill',
                (x - 1) * state.tileSize + state.camera.x - state.mapShift.x,
                (y - 1) * state.tileSize + state.camera.y - state.mapShift.y,
                state.tileSize,
                state.tileSize
            )
        end
    end
end

local function drawSpots()
    love.graphics.setColor(1, 1, 1)
    for k, v in pairs(gameState.currentMap.spots) do
        local sprite
        if v.category == 'gates' then
            sprite = sprites['gate']
        end
        love.graphics.draw(
            sprite,
            (v.x - 1) * state.tileSize + state.camera.x - state.mapShift.x,
            (v.y - 1) * state.tileSize + state.camera.y - state.mapShift.y
        )
    end
end

local function drawPlayer()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        sprites['player'],
        gameState.playerSprite,
        (gameState.playerPos.x - 1) * state.tileSize + state.camera.x,
        (gameState.playerPos.y - 1) * state.tileSize + state.camera.y
    )
end

function mapper.load()
    state.camera = {}
    state.camera.x = windowWidth/2 - (gameState.playerPos.x - 0.5) * state.tileSize
    state.camera.y = windowHeight/2 - (gameState.playerPos.y - 0.5) * state.tileSize
    state.mapShift = { x = 0, y = 0 }
end

function mapper.shiftMap(dir, progress)
    local shiftAmount = progress * state.tileSize

    if dir.axis == 'x' then
        state.mapShift.x = math.floor(dir.dx * shiftAmount)
    elseif dir.axis == 'y' then
        state.mapShift.y = math.floor(dir.dy * shiftAmount)
    end

    local step = math.abs(state.mapShift[dir.axis]) / state.tileSize
    if step <= 0.25 then
        gameState.playerSprite = dir.sprite[2]
    elseif step <= 0.5 then
        gameState.playerSprite = dir.sprite[1]
    elseif step <= 0.75 then
        gameState.playerSprite = dir.sprite[3]
    end
end

function mapper.stopMovement(dir)
    state.mapShift[dir.axis] = 0
    gameState.playerPos.x = gameState.playerPos.x + dir.dx
    gameState.playerPos.y = gameState.playerPos.y + dir.dy
    state.camera.x = state.camera.x - dir.dx * state.tileSize
    state.camera.y = state.camera.y - dir.dy * state.tileSize
end

function mapper.draw()
    drawTiles()
    drawSpots()
    drawPlayer()
end

return mapper