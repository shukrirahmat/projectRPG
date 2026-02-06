local createAction = require('createAction')

local function createMenu(_battle)

    local battle = _battle
    local mainMenu = {current = 1, list = {'FIGHT', 'FLEE'}}
    local characterMenu = {current = 1, list = {'ATTACK', 'SKILL', 'GUARD', 'ITEM'}, charID = 1}
    local targetSelectionMenu = {current = 1}
    local currentMenu = mainMenu

    local height = 180
    local startX = 5
    local startY = windowHeight - height - 10
    local fullWidth = windowWidth - 10

    local function reset(menu)
        menu.current = 1
    end

    local function updateTargetSelectionMenu(prevMenu, group)
        local targetList = {}
        for index, target in ipairs(group) do
            if not target.getStat('dead') then
                table.insert(targetList, target)
            end
        end
        targetSelectionMenu.list = targetList
        targetSelectionMenu.prevMenu = prevMenu
    end

    local function getAbleCharID(currentID, where)
        local party = battle.getParty()
        local nextID
        local found = false
        local outOfBound = false

        if where == 'next' then
            nextID = currentID + 1
            outOfBound = nextID > #party 
        elseif where == 'prev' then
            nextID = currentID - 1
            outOfBound = nextID < 1
        end

        while not found and not outOfBound do
            if not party[nextID].getStat('dead') then
                found = true
            else
                if where == 'next' then
                    nextID = nextID + 1
                    outOfBound = nextID > #party 
                elseif where == 'prev' then
                    nextID = nextID - 1
                    outOfBound = nextID < 1
                end
            end
        end

        if found then
            return nextID
        else
            return nil
        end
    end
    
    local function proceed()
        local initial        
        if currentMenu == mainMenu then
            initial = 0
        else
            initial = characterMenu.charID
        end
        
        local nextID = getAbleCharID(initial, 'next')
        if nextID then
            currentMenu = characterMenu
            characterMenu.charID = nextID
            reset(characterMenu)
        else
            battle.run()
        end
    end

    local function confirm()
        if currentMenu == mainMenu and mainMenu.current == 1 then
            proceed()
        elseif currentMenu == characterMenu then
            if characterMenu.current == 1 then
                updateTargetSelectionMenu(characterMenu, battle.getEnemies())
                currentMenu = targetSelectionMenu
                reset(targetSelectionMenu)
            end
        elseif currentMenu == targetSelectionMenu then
            if targetSelectionMenu.prevMenu == characterMenu then
                local user = battle.getParty()[characterMenu.charID]
                local target = targetSelectionMenu.list[targetSelectionMenu.current]
                local action = createAction('normalAtk', user, target)
                user.setCurrentAction(action)
                proceed()
            end
        end
    end

    local function back()
        if currentMenu == characterMenu then
            local prevID = getAbleCharID(characterMenu.charID, 'prev')
            if prevID then
                currentMenu.charID = prevID
                reset(characterMenu)
            else
                currentMenu = mainMenu
                reset(mainMenu)
            end
        elseif currentMenu == targetSelectionMenu then
            currentMenu = targetSelectionMenu.prevMenu
        end
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
        local borderX = startX + 5
        local borderY = startY
        local height = height
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
        for i, option in ipairs(menu.list) do
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(
                option,
                menuOptionX,
                menuOptionY + (i - 1) * menuOptionHeight,
                menuOptionWidth,
                'center', 0, 1, 1, 0, -1 * (menuOptionHeight/4)
            )
        end

        for i, option in ipairs(menu.list) do
            if menu.current == i then
                drawMenuIndicator(
                    menuOptionX,
                    menuOptionY + (i - 1) * menuOptionHeight,
                    menuOptionHeight
                )
            end
        end

        return {
            x = borderX, 
            y = borderY, 
            height = height,
            width = width,
            optionX = menuOptionX,
            optionY = menuOptionY,
            optionHeight = menuOptionHeight,
            optionWidth = menuOptionWidth
        }
    end

    local function drawMainMenu()
        drawLeftMenu(mainMenu)
    end

    local function drawCharacterMenu()
        local leftMenu = drawLeftMenu(characterMenu)

        local nameBorderHeight = 30
        local nameBorderX = leftMenu.x
        local nameBorderY = leftMenu.y - nameBorderHeight
        local nameBorderWidth = leftMenu.width / 2
        local nameX = nameBorderX + 5
        local nameY = nameBorderY + 5
        local nameWidth = nameBorderWidth - 10

        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(font_small)
        love.graphics.rectangle(
            'line',
            nameBorderX,
            nameBorderY,
            nameBorderWidth,
            nameBorderHeight
        )

        local member = battle.getPartyMember(characterMenu.charID)
        local name =  member.getStat('name')
        love.graphics.printf(
            name,
            nameX,
            nameY,
            nameWidth,
            'center'
        )

        return leftMenu;
    end

    local function drawTargetSelectionMenu(refX, refY, refWidth, refHeight, refOptionHeight)
        local borderX = refX + refWidth + 10
        local borderY = refY
        local borderWidth = fullWidth/4 - 10;
        local borderHeight = refHeight
        local targetX = borderX + 10
        local targetY = borderY + 10
        local targetWidth = borderWidth - 10 * 2
        local targetHeight = refOptionHeight

        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle(
            'line',
            borderX,
            borderY,
            borderWidth,
            borderHeight
        )

        local firstPage = {}
        local secondPage = {}
        local currentPage

        for i = 1, #targetSelectionMenu.list, 1 do
            if i < 5 then
                table.insert(firstPage, targetSelectionMenu.list[i])
            else
                table.insert(secondPage, targetSelectionMenu.list[i])
            end
        end

        if targetSelectionMenu.current < 5 then
            currentPage = firstPage
        else
            currentPage = secondPage
        end

        love.graphics.setFont(font_medium)
        love.graphics.setColor(1, 1, 1)
        for i, target in ipairs(currentPage) do
            love.graphics.printf(
                target.getStat('name'),
                targetX + 20,
                targetY + (i - 1) * targetHeight,
                targetWidth - 20,
                'left', 0, 1, 1, 0, -1 * (targetHeight/4)
            )
            local pointer
            if currentPage == firstPage then
                pointer = i
            else
                pointer = i + 4
            end
            if targetSelectionMenu.current == pointer then
                drawMenuIndicator(
                    targetX,
                    targetY + (i - 1) * targetHeight,
                    targetHeight
                )
            end
        end

        if #secondPage > 0 then
            if currentPage == firstPage then
                love.graphics.polygon(
                    'fill',
                    borderX + borderWidth/2 - 10,
                    borderY + borderHeight - 10,
                    borderX + borderWidth/2 + 10,
                    borderY + borderHeight - 10,
                    borderX + borderWidth/2,
                    borderY + borderHeight - 5
                )
            else
                love.graphics.polygon(
                    'fill',
                    borderX + borderWidth/2 - 10,
                    borderY + 10,
                    borderX + borderWidth/2 + 10,
                    borderY + 10,
                    borderX + borderWidth/2,
                    borderY + 5
                )
            end
        end
    end

    local function drawAttackTargetMenu()
        local leftMenu = drawCharacterMenu()
        drawTargetSelectionMenu(
            leftMenu.x, 
            leftMenu.y, 
            leftMenu.width,
            leftMenu.height,
            leftMenu.optionHeight
        )
    end
    
    local function nextRound()
        currentMenu = mainMenu
        reset(mainMenu)
    end


    local function draw()
        if currentMenu == mainMenu then
            drawMainMenu()
        elseif currentMenu == characterMenu then
            drawCharacterMenu()
        elseif currentMenu == targetSelectionMenu then
            if targetSelectionMenu.prevMenu == characterMenu then
                drawAttackTargetMenu()
            end
        end
    end

    return {
        draw = draw,
        moveUp = moveUp,
        moveDown = moveDown,
        confirm = confirm,
        back = back,
        nextRound = nextRound
    }

end

return createMenu