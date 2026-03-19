local battlerMenu = require('states.battle2.menu.battlerMenu')
local drawHelper = require('utils.drawHelper')
local actionCreator = require('entities.actionCreator')

local targetMenu = {}

local state = {}

local function setEnemiesTarget()
    state.list = {}    
    for i, enemy in ipairs(state.enemies) do
        if not enemy.isDead then
            table.insert(state.list, enemy)
        end
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
    if state.prevMenu == battlerMenu then
        local target = state.list[state.position]
        state.battler.currentAction = actionCreator.new('normalAtk', state.battler, {target})
    end
    
    state.menu.nextBattler()
end

local function back()
    if state.prevMenu == battlerMenu then
        state.menu.switch(battlerMenu)
    end
end

function targetMenu.load(menu, menuState)
    state.menu = menu
    state.height = menuState.height
    state.itemHeight = menuState.itemHeight
    state.marginX = menuState.marginX
    state.marginY = menuState.marginY
    state.width = menuState.width
    state.gap = menuState.gap
    state.paddingX = menuState.paddingX
    state.paddingY = menuState.paddingY
    state.borderX = 0
        
    state.position = 1
    state.list = {}
    state.prevMenu = nil
    state.party = menuState.party
    state.enemies = menuState.enemies
    state.battler = nil
end

function targetMenu.reset()
    state.position = 1
end

function targetMenu.open(prevMenu)
    state.prevMenu = prevMenu    
    if state.prevMenu == battlerMenu then
        state.battler = battlerMenu.currentBattler()
        setEnemiesTarget()
        state.borderX = state.marginX + battlerMenu.getWidth() + state.gap
    end
end

function targetMenu.keypressed(key)
    if key == 'up' then
        moveUp()
    elseif key == 'down' then
        moveDown()
    elseif key == 'x' then
        back()
    elseif key == 'z' then
        confirm()
    end
end

function targetMenu.draw()
    if state.prevMenu == battlerMenu then
        battlerMenu.draw()
    end
    
    local borderX = state.borderX
    local borderY = windowHeight - state.marginY - state.height
    local borderWidth = (state.width - state.gap * 2) / 4
    local borderHeight = state.height
    local targetX = borderX + state.paddingX
    local targetY = borderY + state.paddingY
    local cursorSpace = 20
    local targetWidth = borderWidth - state.paddingY * 2
    local targetHeight = state.itemHeight

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', borderX, borderY, borderWidth, borderHeight)

    if #state.list < 1 then
        love.graphics.setFont(font_large)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
            'There is no available target.',
            targetX,
            targetY + drawHelper.centeredText(targetHeight),
            targetWidth
        )
        return
    end

    local firstPage = {}
    local secondPage = {}
    local currentPage

    for i = 1, #state.list  do
        if i < 5 then
            table.insert(firstPage, state.list[i])
        else
            table.insert(secondPage, state.list[i])
        end
    end

    if state.position < 5 then
        currentPage = firstPage
    else
        currentPage = secondPage
    end

    love.graphics.setFont(font_large)
    love.graphics.setColor(1, 1, 1)
    for i, target in ipairs(currentPage) do
        love.graphics.printf(
            target.name,
            targetX + cursorSpace,
            targetY + drawHelper.centeredText(targetHeight) + (i - 1) * targetHeight,
            targetWidth
        )
        local pointer = i
        if currentPage == secondPage then
            pointer = i + 4
        end
        if state.position == pointer then
            drawHelper.drawMenuIndicator(
                targetX,
                targetY + (i - 1) * targetHeight,
                targetHeight
            )
        end
    end

    if #secondPage > 0 then
        if currentPage == firstPage then
            drawHelper.drawDownwardArrow(borderX, borderY, borderWidth, borderHeight)
        else
            drawHelper.drawUpwardArrow(borderX, borderY, borderWidth, borderHeight)
        end
    end
end

return targetMenu