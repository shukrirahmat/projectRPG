local actionData = require('data.actionData')
local actionCreator = require('entities.actionCreator')
local drawHelper = require('utils.drawHelper')
local itemManager = require('systems.itemManager')

local targetMenu = {}

local state = {}

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
    state.isActive = false;
    state.battler.currentAction = actionCreator.new(state.ref, state.battler, {state.list[state.position]})
    
    if state.action.item then
        state.battler.usingItem = state.ref
        itemManager.manageItems(state.ref, -1)
    end
    
    state.result = { ref = 'nextBattler', prevMenu = state.prevMenu }
end

local function back()
    state.isActive = false;
    state.result = { ref = 'back', prevMenu = state.prevMenu }
end

------------------------------------------
-----------------PUBLIC-------------------
------------------------------------------

function targetMenu.load(menuState, prevMenu, ref, battler)

    state.party = menuState.party
    state.enemies = menuState.enemies
    state.battler = battler
    state.prevMenu = prevMenu
    state.result = nil
    state.position = 1
    state.list = {}
    state.isActive = nil
    state.ref = ref

    state.action = actionData[ref]
    
    if state.action.aim == 'enemies' then
        for i, enemy in ipairs(state.enemies) do
            if not enemy.isDead then
                table.insert(state.list, enemy)
            end
        end
        if #state.list == 1 then
            state.battler.currentAction = actionCreator.new(ref, state.battler, {state.list[1]})
            state.result = { ref = 'nextBattler' , prevMenu = state.prevMenu }
            return
        end
    end

    if state.action.aim == 'allies' then
        if state.action.scope == 'dead' then
            for i, deadMember in ipairs(state.party) do
                if deadMember.isDead then
                    table.insert(state.list, deadMember)
                end
            end
        else
            for i, member in ipairs(state.party) do
                if not member.isDead then
                    table.insert(state.list, member)
                end
            end
        end
    end
    
    state.isActive = true

    state.height = menuState.height
    state.itemHeight = menuState.itemHeight
    state.marginX = menuState.marginX
    state.marginY = menuState.marginY
    state.width = menuState.width
    state.gap = menuState.gap
    state.paddingX = menuState.paddingX
    state.paddingY = menuState.paddingY
    state.borderX = state.marginX + state.prevMenu.getWidth() + state.gap
end

function targetMenu.getResult()
    local result = state.result
    state.result = nil
    return result
end

function targetMenu.isActive()
    return state.isActive
end

function targetMenu.draw()
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

return targetMenu