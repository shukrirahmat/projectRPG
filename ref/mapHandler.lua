local owState = require('overworldState')
local mapData = require('mapData')
local enemyCreator = require('enemyCreator')

local mapHandler = {}

function mapHandler.createEncounter()

    local encounterSet = {}

    local rollTimes = 1
    local moreRoll = true
    local moreRollChance = 100
    while moreRoll and rollTimes <= owState.currentMap.maxEncounter do
        local roll_1 = math.random(0, 100)
        if roll_1 < moreRollChance then
            local roll_2 = math.random(1, #owState.currentMap.encounters)
            local enemyRef = owState.currentMap.encounters[roll_2]
            if not encounterSet[enemyRef] then
                encounterSet[enemyRef] = 1
            else
                encounterSet[enemyRef] = encounterSet[enemyRef] + 1
            end
            rollTimes = rollTimes + 1
            moreRollChance = math.floor(moreRollChance * 0.8);
        else
            moreRoll = false
        end
    end

    local enemies = {}

    for k, v in pairs(encounterSet) do
        for i = 1, v do
            local name = ''..k:upper()..''..i..''
            local enemy = enemyCreator.new(k, name)
            table.insert(enemies, enemy)
        end
    end

    return enemies
end

function mapHandler.load()
    owState.playerPos = owState.currentMap.startPos;
    owState.currentSprite = player_front[1]
    owState.camera.x = windowWidth/2 - (owState.playerPos.x - 0.5) * owState.tileSize
    owState.camera.y = windowHeight/2 - (owState.playerPos.y - 0.5) * owState.tileSize
    owState.encounterChance = owState.currentMap.encounterRate or nil
end

function mapHandler.draw()
    for y = 1, owState.currentMap.size.y do
        for x = 1, owState.currentMap.size.x do
            local floor = owState.currentMap.floor
            love.graphics.setColor(floor.r, floor.g, floor.b)
            love.graphics.rectangle(
                'fill',
                (x - 1) * owState.tileSize + owState.camera.x - owState.moveShift.x,
                (y - 1) * owState.tileSize + owState.camera.y - owState.moveShift.y,
                owState.tileSize,
                owState.tileSize
            )
        end
    end

    love.graphics.setColor(1, 1, 1)
    for k, v in pairs(owState.currentMap.spots) do
        local sprite
        if v.category == 'gates' then
            sprite = gate_sprite
        end
        love.graphics.draw(
            sprite,
            (v.x - 1) * owState.tileSize + owState.camera.x - owState.moveShift.x,
            (v.y - 1) * owState.tileSize + owState.camera.y - owState.moveShift.y
        )
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        player_sprites,
        owState.currentSprite,
        (owState.playerPos.x - 1) * owState.tileSize + owState.camera.x,
        (owState.playerPos.y - 1) * owState.tileSize + owState.camera.y
    )
end

return mapHandler