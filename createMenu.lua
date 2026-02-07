local function createMenu()

    local mainMenu = {current = 1, list = {'FIGHT', 'FLEE'}}
    local currentMenu = mainMenu

    local fullHeight = 180
    local fullWidth = windowWidth - 10
    local originX = 10
    local originY = windowHeight - fullHeight - 10
    local itemHeight = (fullHeight  - 20) / 4
    
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

    local function drawLeftMenu(menu)
        local x = originX
        local y = originY
        local width = fullWidth / 4 - 10
        local itemX = x + 10
        local itemY = y + 10
        local itemWidth = width - 20
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle(
            'line',
            x,
            y,
            width,
            fullHeight
        )

        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(font_medium)
        for index, item in ipairs(menu.list) do
            love.graphics.printf(
                item,
                itemX,
                itemY + (index - 1) * itemHeight,
                itemWidth,
                'center', 0, 1, 1, 0, -1 * (itemHeight/4)
            )
            if menu.current == index then
                drawMenuIndicator(
                    itemX,
                    itemY + (index - 1) * itemHeight,
                    itemHeight
                )
            end
        end


        return {
            x = x,
            y = y,
            width = width,
            itemX = itemX,
            itemY = itemY,
            itemWidth = itemWidth,
        }
    end
    
    local function moveUp()
        if currentMenu.current > 1 then
            currentMenu.current = currentMenu.current - 1
        end
    end
    
    local function moveDown()
        if currentMenu.current < #currentMenu.list then
            currentMenu.current = currentMenu.current + 1
        end
    end

    local function draw()
        if currentMenu == mainMenu then
            drawLeftMenu(mainMenu)
        end
    end

    return {
        draw = draw,
        moveUp = moveUp,
        moveDown = moveDown
    }    
end

return createMenu;