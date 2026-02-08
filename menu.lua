local state = require('state')

local menu = {}

local height = 180
local itemHeight = (height - 20)/4

local function drawMenuIndicator(x, y, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon(
        'fill',
        x,
        y + (height/2) - 10,
        x,
        y + (height/2) + 10,
        x + 10,
        y + (height/2)
    )
end

local function drawLeftMenu(m)
    local borderX = 10
    local borderY = windowHeight - height - 10
    local borderWidth = (windowWidth - 10)/4 - 10
    local itemX = borderX + 10
    local itemY = borderY + 10
    local itemWidth = borderWidth - 20

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
        'line',
        borderX,
        borderY,
        borderWidth,
        height
    )

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font_medium)
    for i, item in ipairs(m.list) do
        love.graphics.printf(
            item,
            itemX,
            itemY + (i - 1) * itemHeight,
            itemWidth,
            'center', 0, 1, 1, 0, -1 * (itemHeight/4)
        )
        if m.position == i then
            drawMenuIndicator(
                itemX,
                itemY + (i - 1) * itemHeight,
                itemHeight
            )
        end
    end

    return {
        borderX = borderX,
        borderY = borderY,
        borderWidth = borderWidth,
        itemX = itemX,
        itemY = itemY,
        itemWidth = itemWidth,
    }
end

local function drawCharacterMenu()
    local leftMenu = drawLeftMenu(state.characterMenu)

    local borderHeight = 30
    local borderX = leftMenu.borderX
    local borderY = leftMenu.borderY - borderHeight
    local borderWidth = leftMenu.borderWidth / 2
    local nameX = borderX + 5
    local nameY = borderY + 5
    local nameWidth = borderWidth - 10

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font_small)
    love.graphics.rectangle(
        'line',
        borderX,
        borderY,
        borderWidth,
        borderHeight
    )

    
    local id = state.characterMenu.charID
    local charName = state.party[id].name
    love.graphics.printf(
        charName,
        nameX,
        nameY,
        nameWidth,
        'center'
    )

    return leftMenu;
end

function menu.draw()
    if state.currentMenu == state.mainMenu then
        drawLeftMenu(state.mainMenu)
    elseif state.currentMenu == state.characterMenu then
        drawCharacterMenu()
    end
end

return menu