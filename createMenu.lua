local function createMenu()
   
   local phase = 'mainMenu'
   local mainMenu = {current = 1, list = {'FIGHT', 'FLEE'}}
   
   local height = 180
   local startX = 5
   local startY = windowHeight - height - 10
   local fullWidth = windowWidth - 10
   
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
   
   local function drawMainMenu()
        local borderX = startX + 5
        local borderY = startY
        local width = fullWidth/4 - 10
        local menuOptionX = borderX + 10
        local menuOptionY = borderY + 10
        local menuOptionWidth = width - 20
        local menuOptionHeight = (height - 20)/4

        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle(
            'line',
            borderX,
            borderY,
            width,
            height
        )

        love.graphics.setFont(font_medium)
        for i, option in ipairs(mainMenu.list) do
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(
                option,
                menuOptionX,
                menuOptionY + (i - 1) * menuOptionHeight,
                menuOptionWidth,
                'center', 0, 1, 1, 0, -1 * (menuOptionHeight/4)
            )
        end

        for i, option in ipairs(mainMenu.list) do
            if mainMenu.current == i then
                drawMenuIndicator(
                    menuOptionX,
                    menuOptionY + (i - 1) * menuOptionHeight,
                    menuOptionHeight
                )
            end
        end
    end
   
   local function draw()
       if phase == 'mainMenu' then
           drawMainMenu()
        end
    end
    
    return {
        draw = draw
    }
    
end

return createMenu