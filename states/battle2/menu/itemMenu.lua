local drawHelper = require('utils.drawHelper')
local actionData = require('data.actionData')
local actionCreator = require('entities.actionCreator')
local gameState = require('gameState')
local itemData = require('data.itemData')
local itemManager = require('systems.itemManager')

local itemMenu = {}

local state = {}

local function moveUp()
    if state.position - 2 >= 1 then
        state.position = state.position - 2
    end
end

local function moveDown()
    if state.position + 2 <= #state.list then
        state.position = state.position + 2
    elseif state.position % 2 == 0 and state.position + 1 == #state.list then
        state.position = state.position + 1
    end
end

local function moveLeft()
    if state.position % 2 == 0 and state.position - 1 >= 1 then
        state.position = state.position - 1
    end
end

local function moveRight()
    if state.position % 2 ~= 0 and state.position + 1 <= #state.list then
        state.position = state.position + 1
    end
end

local function confirm()
    local itemRef = state.list[state.position].item
    local skill = actionData[itemRef]

    if skill.scope =='single' then
        state.isTargeting = true
        state.result = { ref = 'useItem', item = itemRef, battler = state.battler }
    elseif skill.scope == 'all' then
        local group = state.enemies
        if skill.aim == 'allies' then
            group = state.party
        end
        local action = actionCreator.new(itemRef, state.battler, {unpack(group)})
        state.battler.currentAction = action
        state.battler.usingItem = itemRef
        itemManager.manageItems(itemRef, -1)
        state.result = { ref = 'nextBattler' }
        state.isActive = false
    elseif skill.scope =='self' then
        local action = actionCreator.new(itemRef, state.battler, {state.battler})
        state.battler.currentAction = action
        state.battler.usingItem = itemRef
        itemManager.manageItems(itemRef, -1)
        state.result = { ref = 'nextBattler' }
        state.isActive = false
    elseif skill.scope =='dead' then
        state.isTargeting = true
        state.result = { ref = 'useItem', item = itemRef, battler = state.battler}
    end
end

local function back()
    state.isActive = false;
    state.result = { ref = 'back', prevMenu = state.prevMenu }
end

local function drawDescriptionText(itemObject)
    local x = state.borderX + state.borderWidth + state.gap
    local y = windowHeight - state.marginY - state.height
    local width = (state.width - state.gap * 2) / 4
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
        'line',
        x,
        y,
        width,
        state.height
    )
    
    local usable = itemData[itemObject.item]

    local header = 'Have left: '..itemObject.amount..''
    love.graphics.printf(
        header,
        x + state.paddingX,
        y + state.paddingY + drawHelper.centeredText(state.itemHeight),
        width - state.paddingX * 2
    )
    love.graphics.line(
        x, y + state.itemHeight + state.paddingY * 1.5, 
        x + width, y + state.itemHeight + state.paddingY * 1.5)
    love.graphics.setFont(font_large)
    love.graphics.printf(
        usable.desc,
        x + state.paddingX,
        y + state.itemHeight + state.paddingY * 2 + drawHelper.centeredText(state.itemHeight),
        width - state.paddingX * 2
    )
end

------------------------------------------
-----------------PUBLIC-------------------
------------------------------------------

function itemMenu.load(menuState, prevMenu, battler)
    state.isActive = true

    state.height = menuState.height
    state.itemHeight = menuState.itemHeight
    state.marginX = menuState.marginX
    state.marginY = menuState.marginY
    state.width = menuState.width
    state.gap = menuState.gap
    state.paddingX = menuState.paddingX
    state.paddingY = menuState.paddingY
    state.borderX = state.marginX + prevMenu.getWidth() + state.gap
    state.borderWidth = (state.width - state.gap * 2) / 2
    state.size = 8

    state.party = menuState.party
    state.enemies = menuState.enemies

    state.position = 1
    state.list = {}
    state.prevMenu = prevMenu
    state.battler = battler
    state.isTargeting = false

    for k, v in pairs(gameState.partyItems) do
        local id = itemData[k].id
        table.insert(state.list, {item = k, amount = v, id = id})
    end

    table.sort(state.list, function(a, b) return a.id < b.id end)
end

function itemMenu.getResult()
    local result = state.result
    state.result = nil
    return result
end

function itemMenu.isActive()
    return state.isActive
end

function itemMenu.getWidth()
    return state.borderWidth + state.prevMenu.getWidth() + state.gap
end

function itemMenu.close()
    state.isActive = false
end

function itemMenu.cancelTargetting()
    state.isTargeting = false
end

function itemMenu.draw()

    local borderX = state.borderX
    local borderY = windowHeight - state.marginY - state.height
    local borderWidth = state.borderWidth
    local borderHeight = state.height
    local itemX = borderX + state.paddingX
    local itemY = borderY + state.paddingY
    local textWidth = borderWidth - state.paddingX
    local itemWidth = (borderWidth / 2) - state.paddingX * 2
    local itemHeight = state.itemHeight
    local cursorSpace = 20

    love.graphics.setColor(1,1,1)
    love.graphics.rectangle(
        'line',
        borderX,
        borderY,
        borderWidth,
        borderHeight
    )

    if #state.list == 0 then
        local text ='The party do not have any consumable items.'
        love.graphics.setFont(font_large)
        love.graphics.printf(
            text,
            itemX,
            itemY + drawHelper.centeredText(itemHeight),
            textWidth,
            'left'
        )
        return
    end

    local currentPage = math.ceil(state.position / state.size)
    local pageStart = (currentPage - 1) * state.size + 1;
    local pageEnd = math.min(#state.list, pageStart + state.size - 1)

    for i = pageStart, pageEnd do
        love.graphics.setFont(font_large)
        love.graphics.setColor(1, 1, 1)

        local usable = itemData[state.list[i].item]

        local usableX = borderX + state.paddingX
        if i % 2 == 0 then
            usableX = usableX + borderWidth / 2
        end
        local skillPos = math.ceil((((i - 1) % state.size) + 1) / 2)
        local usableY = borderY + state.paddingY + (skillPos - 1) * itemHeight

        love.graphics.printf(
            usable.name,
            usableX + cursorSpace,
            usableY + drawHelper.centeredText(itemHeight),
            itemWidth
        )

        love.graphics.setColor(1, 1, 1)
        if state.position == i then
            drawHelper.drawMenuIndicator(usableX, usableY, itemHeight)
            if not state.isTargeting then
                drawDescriptionText(state.list[i])
            end
        end

        if math.ceil(#state.list / state.size) > 1 then
            if math.ceil(state.position / state.size) == 1 then
                drawHelper.drawDownwardArrow(borderX, borderY, borderWidth, borderHeight)
            elseif math.ceil(state.position / state.size) == math.ceil(#state.list / state.size) then
                drawHelper.drawUpwardArrow(borderX, borderY, borderWidth, borderHeight)
            else
                drawHelper.drawDownwardArrow(borderX, borderY, borderWidth, borderHeight)
                drawHelper.drawUpwardArrow(borderX, borderY, borderWidth, borderHeight)
            end
        end
    end
end

function itemMenu.keypressed(key)
    if #state.list > 0 then
        if key == 'up' then
            moveUp()
        elseif key == 'down' then
            moveDown()
        elseif key == 'left' then
            moveLeft()
        elseif key == 'right' then
            moveRight()
        elseif key == 'z' then
            confirm()
        end
    end

    if key == 'x' then
        back()
    end
end


return itemMenu