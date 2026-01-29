function love.load()

    windowWidth = 800
    windowHeight = 600

    love.graphics.setBackgroundColor(0,0,0)
    font_small = love.graphics.newFont('fonts/MartianMono-Regular.ttf', 14)
    font_medium = love.graphics.newFont('fonts/MartianMono-Regular.ttf', 18)
    font_large = love.graphics.newFont('fonts/MartianMono-Regular.ttf', 24)
    goblin_sprite = love.graphics.newImage('images/goblin.png')
    monsterSpriteDimension = 128

    character1 = {
        name = 'HERO',
        maxHp = 500,
        maxMp = 350,
        attack = 120,
        defense = 80,
        speed = 100
    }

    enemy1 = {
        name = 'GOBLIN',
        maxHp = 250,
        maxMp = 0,
        attack = 80,
        defense = 50,
        speed = 60,
        sprite = goblin_sprite
    }

    currentPhase = 'mainMenu'

    mainMenu = {current = 1, list = {'FIGHT', 'FLEE'}}
    characterMenu = {current = 1, list = {'ATTACK', 'SKILL', 'GUARD', 'ITEM'}}
end

function love.draw()

    -----------------------TOP------------------------
    local topBoxX = 10
    local topBoxY = 10
    local topBoxWidth = 150
    local topBoxHeight = 100
    local nameX = topBoxX + 5
    local nameY = topBoxY + 5
    local nameWidth = topBoxWidth - 10
    local hpX = topBoxX + 5
    local hpY = topBoxY + 25
    local hpWidth = topBoxWidth - 10
    local mpX = topBoxX + 5
    local mpY = topBoxY + 25 * 2
    local mpWidth = topBoxWidth - 10

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', topBoxX, topBoxY, topBoxWidth, topBoxHeight)
    love.graphics.setFont(font_small)
    love.graphics.printf(character1.name, nameX, nameY, nameWidth, 'center')
    love.graphics.setFont(font_large)
    love.graphics.printf('HP '..character1.maxHp..'', hpX, hpY, hpWidth, 'center')
    love.graphics.printf('MP '..character1.maxMp..'', mpX, mpY, mpWidth, 'center')

    ---------------------MIDDLE-------------------

    love.graphics.draw(
        enemy1.sprite,
        windowWidth/2, 
        windowHeight/2,
        0,
        1,
        1,
        monsterSpriteDimension/2,
        monsterSpriteDimension/1.5
    )

    --------------------BOTTOM-----------------------

    function drawBottomMenu(menu)

        local bottomBoxHeight = 180
        local bottomBoxX = 10
        local bottomBoxY = windowHeight - bottomBoxHeight - 10
        local bottomLeftWidth = 200
        local menuOptionX = bottomBoxX + 10
        local menuOptionY = bottomBoxY + 10
        local menuOptionWidth = bottomLeftWidth - 20
        local menuOptionHeight = (bottomBoxHeight - 20)/4

        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle(
            'line',
            bottomBoxX,
            bottomBoxY,
            bottomLeftWidth,
            bottomBoxHeight
        )

        love.graphics.setFont(font_medium)
        for optionIndex, option in ipairs(menu.list) do
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(
                option,
                menuOptionX,
                menuOptionY + (optionIndex - 1) * menuOptionHeight,
                menuOptionWidth,
                'center', 0, 1, 1, 0, -1 * (menuOptionHeight/4)
            )
            if menu.current == optionIndex then
                love.graphics.setColor(0.25, 0.25, 0.25)
                love.graphics.rectangle(
                    'line',
                    menuOptionX,
                    menuOptionY + 2 + (optionIndex - 1) * menuOptionHeight,
                    menuOptionWidth,
                    menuOptionHeight - 4
                )
            end

        end
    end

    if currentPhase == 'mainMenu' then
        drawBottomMenu(mainMenu)
    elseif currentPhase == 'characterMenu' then
        drawBottomMenu(characterMenu)
    end

end

function love.keypressed(key)
    if currentPhase == 'mainMenu' then
        if key == 'down' and mainMenu.current < #mainMenu.list then
            mainMenu.current = mainMenu.current + 1
        elseif key == 'up' and mainMenu.current > 1 then
            mainMenu.current = mainMenu.current - 1
        elseif key == 'z' and mainMenu.current == 1 then
            currentPhase = 'characterMenu';
            characterMenu.current = 1;
        end
    end
    
    if currentPhase == 'characterMenu' then
        if key == 'down' and characterMenu.current < #characterMenu.list then
            characterMenu.current = characterMenu.current + 1
        elseif key == 'up' and characterMenu.current > 1 then
            characterMenu.current = characterMenu.current - 1
        elseif key == 'x' then
            currentPhase = 'mainMenu';
            mainMenu.current = 1;
        end
    end
end