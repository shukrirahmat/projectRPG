local owState = require('overworldState')
local utils = require('utils')

local overworldMenu = {}

function overworldMenu.drawMainMenu()
    local borderX = windowWidth - math.floor(windowWidth/6) - 10
    local borderY = 10
    local borderWidth = math.floor(windowWidth/6)
    local borderHeight = 45 * #owState.mainMenu.list + 20
    local itemX = borderX + 10
    local itemY = borderY + 10
    local itemWidth = borderWidth - 20
    local itemHeight = 45
    
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle(
        'fill',
        borderX,
        borderY,
        borderWidth,
        borderHeight
    )
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
        'line',
        borderX,
        borderY,
        borderWidth,
        borderHeight
    )
    
    love.graphics.setFont(font_medium)
    love.graphics.setColor(1, 1, 1)
    for i, item in ipairs(owState.mainMenu.list) do
        love.graphics.printf(
            item,
            itemX,
            itemY + (i - 1) * itemHeight,
            itemWidth,
            'center', 0, 1, 1, 0, -1 * (itemHeight/4)
        )
        if owState.mainMenu.position == i then
            utils.drawMenuIndicator(
                itemX,
                itemY + (i - 1) * itemHeight,
                itemHeight
            )
        end
    end
end
        

return overworldMenu