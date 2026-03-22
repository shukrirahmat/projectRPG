local drawHelper = require('utils.drawHelper')
local actionCreator = require('entities.actionCreator')
local itemManager = require('systems.itemManager')

local partyMenu = {}

local state = {}

local function previousBattler(index)
    local canAct = false
    while not canAct and index > 0 do
        local battler = state.party[index]
        if battler.isDead or battler:cannotAct() then
            index = index - 1
        else
            canAct = true
            state.battlerIndex = index
            state.battler = battler
            state.battler.currentAction = nil
            if state.battler.usingItem then
                itemManager.manageItems(state.battler.usingItem, 1)
                state.battler.usingItem = nil
            end
        end
    end
    
    if not canAct then
        state.isActive = false
        state.result = { ref = 'toMain' }
    end
end

local function setBattler(index)
    local canAct = false
    while not canAct and index <= #state.party do
        local battler = state.party[index]
        if battler.isDead or battler:cannotAct() then
            index = index + 1
        else
            canAct = true
            state.battlerIndex = index
            state.battler = battler
            state.battler.currentAction = nil
        end
    end
    
    if not canAct then
        state.isActive = false
        state.result = { ref = 'finished' }
    end
end

local function moveUp()
    if state.position > 1 then
        state.position = state.position - 1
    end
end

local function moveDown()
    if state.position < #state.list then
        state.position = state.position + 1
    end
end

local function confirm()
    if state.position == 1 then
        state.result = { ref = 'attack', battler = state.battler }
    elseif state.position == 2 then
        state.result = { ref = 'chooseSkill', battler = state.battler }
    elseif state.position == 3 then
        state.battler.currentAction = actionCreator.new('defend', state.battler, {state.battler})
        state.result = { ref = 'nextBattler' }
    elseif state.position == 4 then
        state.result = { ref = 'chooseItem', battler = state.battler }
    end
end

local function back()
    previousBattler(state.battlerIndex - 1)
end

------------------------------------------
-----------------PUBLIC-------------------
------------------------------------------


function partyMenu.load(menuState, index)
    state.marginX = menuState.marginX
    state.marginY = menuState.marginY
    state.paddingX = menuState.paddingX
    state.paddingY = menuState.paddingY
    state.width = menuState.width
    state.height = menuState.height
    state.itemHeight = menuState.itemHeight
    state.gap = menuState.gap
    
    state.party = menuState.party
    state.enemies = menuState.enemies
    
    state.position = 1
    state.list = {'ATTACK', 'SKILL', 'DEFEND', 'ITEM'}
    state.isActive = true
    state.result = nil
    
    state.borderWidth = (state.width - state.gap * 2) / 4
    state.spriteRatio = 0.75
    state.spriteHeight = monsterSpriteDimension * state.spriteRatio
    state.spriteWidth = state.spriteHeight
    
    setBattler(index)
end

function partyMenu.nextBattler(menuState)
    local index = state.battlerIndex + 1
    partyMenu.load(menuState, index)
end

function partyMenu.isActive()
    return state.isActive
end

function partyMenu.getResult()
    local result = state.result
    state.result = nil
    return result
end

function partyMenu.getWidth()
    return state.borderWidth
end

function partyMenu.draw()
    local borderHeight = state.height
    local borderX = state.marginX
    local borderY = windowHeight - borderHeight - state.marginY
    local borderWidth = state.borderWidth
    local itemX = borderX + state.paddingX
    local itemY = borderY + state.paddingY
    local itemWidth = borderWidth - state.paddingX * 2
    local itemHeight = state.itemHeight

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', borderX, borderY, borderWidth, borderHeight)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font_large)
    for i, item in ipairs(state.list) do
        
        if i == 2 and state.battler.status['SEAL'] then
            love.graphics.setColor(0.25, 0.25, 0.25)
        end
        
        love.graphics.printf(
            item,
            itemX,
            itemY + drawHelper.centeredText(itemHeight) + (i - 1) * itemHeight,
            itemWidth,
            'center'
        )
        
        love.graphics.setColor(1, 1, 1)
        if state.position == i then
            drawHelper.drawMenuIndicator(
                itemX,
                itemY + (i - 1) * itemHeight,
                itemHeight
            )
        end
    end
    
    local spriteX = borderX
    local spriteY = borderY - state.spriteHeight

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle(
        'fill',
        spriteX,
        spriteY,
        state.spriteWidth,
        state.spriteHeight
    )
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
        'line',
        spriteX,
        spriteY,
        state.spriteWidth,
        state.spriteHeight
    )
    
    love.graphics.draw(
        state.battler.sprite,
        spriteX,
        spriteY - 1,
        0,
        state.spriteRatio,
        state.spriteRatio
    )
end

function partyMenu.keypressed(key)
    if key == 'up' then
        moveUp()
    elseif key == 'down' then
        moveDown()
    elseif key == 'z' then
        confirm()
    elseif key == 'x' then
        back()
    end
end

return partyMenu