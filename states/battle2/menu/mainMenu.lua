local drawHelper = require('utils.drawHelper')

local mainMenu = {}

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
    if state.position == 1 then
        state.menu.nextBattler()
    end
end

function mainMenu.load(menu, menuState)  
    state.menu = menu
    state.height = menuState.height
    state.itemHeight = menuState.itemHeight
    state.marginX = menuState.marginX
    state.marginY = menuState.marginY
    state.width = menuState.width
    state.gap = menuState.gap
    state.paddingX = menuState.paddingX
    state.paddingY = menuState.paddingY
    
    state.position = 1
    state.list = {'FIGHT', 'FLEE'}    
end

function mainMenu.reset()
    state.position = 1
end

function mainMenu.keypressed(key)
    if key == 'up' then
        moveUp()
    elseif key == 'down' then
        moveDown()
    elseif key == 'z' then
        confirm()
    end
end

function mainMenu.draw()
    local borderHeight = state.height
    local borderX = state.marginX
    local borderY = windowHeight - borderHeight - state.marginY
    local borderWidth = (state.width - state.gap * 2) / 4
    local itemX = borderX + state.paddingX
    local itemY = borderY + state.paddingY
    local itemWidth = borderWidth - state.paddingX * 2
    local itemHeight = state.itemHeight

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', borderX, borderY, borderWidth, borderHeight)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font_large)
    for i, item in ipairs(state.list) do
        love.graphics.printf(
            item,
            itemX,
            itemY + drawHelper.centeredText(itemHeight) + (i - 1) * itemHeight,
            itemWidth,
            'center'
        )
        if state.position == i then
            drawHelper.drawMenuIndicator(
                itemX,
                itemY + (i - 1) * itemHeight,
                itemHeight
            )
        end
    end
end

return mainMenu