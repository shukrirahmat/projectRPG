function love.load()

    windowWidth = 800
    windowHeight = 600

    love.graphics.setBackgroundColor(0,0,0)
    font_small = love.graphics.newFont('fonts/MartianMono-Regular.ttf', 14)
    font_medium = love.graphics.newFont('fonts/MartianMono-Regular.ttf', 18)
    font_large = love.graphics.newFont('fonts/MartianMono-Regular.ttf', 24)
    goblin_sprite = love.graphics.newImage('images/goblin.png')
    skeleton_sprite = love.graphics.newImage('images/skeleton.png')
    monsterSpriteDimension = 128

    character1 = {
        name = 'HERO',
        maxHp = 500,
        currentHp = 500,
        maxMp = 0,
        currentMp = 0,
        attack = 120,
        defense = 80,
        agility = 80
    }

    enemy1 = {
        name = 'GOBLIN1',
        maxHp = 100,
        currentHp = 100,
        currentMp = 0,
        maxMp = 0,
        attack = 70,
        defense = 40,
        agility = 60,
        sprite = goblin_sprite
    }

    enemy2 = {
        name = 'SKELETON',
        maxHp = 180,
        currentHp = 180,
        currentMp = 0,
        maxMp = 0,
        attack = 90,
        defense = 50,
        agility = 50,
        sprite = skeleton_sprite
    }

    enemy3 = {
        name = 'GOBLIN2',
        maxHp = 100,
        currentHp = 100,
        currentMp = 0,
        maxMp = 0,
        attack = 70,
        defense = 40,
        agility = 60,
        sprite = goblin_sprite
    }

    enemies = {enemy1, enemy2, enemy3}
    allEnemyDead = false;

    currentPhase = 'mainMenu'

    mainMenu = {current = 1, list = {'FIGHT', 'FLEE'}}
    characterMenu = {current = 1, list = {'ATTACK', 'SKILL', 'GUARD', 'ITEM'}}
    targetSelectionMenu = {current = 1}

    textTimer = 0;
    actionList = {}
    effectList = {};
    battlelog = {}
    battleEnded = false;

    function updateSelectionMenu()
        local enemyList = {}
        for index, enemy in ipairs(enemies) do
            if not enemy.dead then
                table.insert(enemyList, enemy.name)
            end
        end
        targetSelectionMenu.list = enemyList
    end

    function addAttackAction(user, target)
        table.insert(actionList, {name = 'ATTACK', user = user, target = target})
    end

    function setEnemyAction(enemies)
        --For now just attack
        for index, enemy in ipairs(enemies) do
            if not enemy.dead then
                addAttackAction(enemy, character1)
            end
        end
    end

    function setActionOrder()
        for index, action in ipairs(actionList) do
            local agi = action.user.agility
            action.speed = agi + math.floor(math.random(-agi*.25, agi*.25))
        end
        table.sort(actionList, function(action1, action2)
                return action1.speed > action2.speed
            end)
    end
    
    function removeAction(user)
        for index, action in ipairs(actionList) do
            if action.user == user then
                table.remove(actionList, index)
            end
        end
    end

    function executeAction(action)
        local result
        if action.name == 'ATTACK' then
            --FOR NOW NOTHING HAPPEN IF TARGET IS ALREADY DEAD
            if not action.target.dead then
                local damage = calculateAttackDamage(action.user, action.target)
                result = { effectType = 'DAMAGE', value = damage, target = action.target }
                table.insert(battlelog, ''..action.user.name..' attacks '..action.target.name..'')
                table.insert(effectList, result)
            end
        end
    end

    function applyEffect(effect)
        local target = effect.target
        if effect.effectType == 'DAMAGE' then
            target.currentHp = target.currentHp - effect.value
            table.insert(battlelog, ''..target.name..' takes '..effect.value..' damage!')
            if target.currentHp < 0 then 
                target.currentHp = 0
                table.insert(battlelog, ''..target.name..' defeated')
                for index, enemy in ipairs(enemies) do
                    if enemy.name == target.name then
                        enemy.dead = true;
                        removeAction(enemy)
                    end
                end
                if checkIfAllEnemiesDead() then
                    allEnemyDead = true
                end
            end
        end
    end

    function calculateAttackDamage(attacker, target)
        local damage = math.floor(attacker.attack/2) - math.floor(target.defense/3)
        damage = damage + math.floor(math.random(-damage*.2, damage*.2))
        return math.max(damage, 1)
    end

    function checkIfAllEnemiesDead()
        local totalDead = 0
        for index, enemy in ipairs(enemies) do
            if enemy.dead then
                totalDead = totalDead + 1
            end
        end

        return totalDead == #enemies;
    end

end

function love.update(dt)

    if battleEnded then
        currentPhase = 'battleEnd';
        textTimer = textTimer + dt
        if textTimer > 1 then
            battlelog = {}
            table.insert(battlelog, 'Enemy defeated')
            textTimer = 0
        end                

    elseif currentPhase == 'playBattle' then

        textTimer = textTimer + dt
        if textTimer > 1 then
            if #effectList == 0 and #actionList == 0 then
                battlelog = {}
                currentPhase = 'mainMenu'
                mainMenu.current = 1
            elseif #effectList == 0 then
                battlelog = {};
                executeAction(actionList[1])
                table.remove(actionList, 1)
            elseif #effectList > 0 then
                applyEffect(effectList[1])
                table.remove(effectList, 1)
                if allEnemyDead then
                    battleEnded = true
                end
            end

            textTimer = 0;
        end
    end
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
    love.graphics.printf('HP '..character1.currentHp..'', hpX, hpY, hpWidth, 'center')
    love.graphics.printf('MP '..character1.currentMp..'', mpX, mpY, mpWidth, 'center')

    ---------------------MIDDLE-------------------

    for index, enemy in ipairs(enemies) do
        if not enemy.dead then
            love.graphics.draw(
                enemy.sprite,
                windowWidth/2 + (index - 1) * monsterSpriteDimension, 
                windowHeight/2,
                0,
                1,
                1,
                (monsterSpriteDimension/2) * #enemies,
                monsterSpriteDimension/1.5
            )
        end
    end

    --------------------BOTTOM-----------------------

    function createBottomMenu(menu)
        local bottomBoxHeight = 180
        local bottomBoxX = 10
        local bottomBoxY = windowHeight - bottomBoxHeight - 10
        local bottomLeftWidth = windowWidth/4
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
        end

        return {
            bottomBoxHeight = bottomBoxHeight,
            bottomBoxX = bottomBoxX,
            bottomBoxY = bottomBoxY,
            bottomLeftWidth = bottomLeftWidth,
            menuOptionX = menuOptionX,
            menuOptionY = menuOptionY,
            menuOptionWidth = menuOptionWidth,
            menuOptionHeight = menuOptionHeight
        }

    end

    function drawBottomMenu(menu)
        local bottomMenu = createBottomMenu(menu)

        for index, option in ipairs(menu.list) do
            if menu.current == index then
                drawMenuIndicator(
                    bottomMenu.menuOptionX,
                    bottomMenu.menuOptionY + (index - 1) * bottomMenu.menuOptionHeight,
                    bottomMenu.menuOptionWidth,
                    bottomMenu.menuOptionHeight
                )

            end
        end
    end

    function drawTargetSelectionMenu(menu)
        local bottomMenu = createBottomMenu(menu)

        local borderX = bottomMenu.bottomBoxX * 2 + bottomMenu.bottomLeftWidth
        local borderY = bottomMenu.bottomBoxY
        local borderWidth = windowWidth - bottomMenu.bottomBoxX * 3 - bottomMenu.bottomLeftWidth
        local borderHeight = bottomMenu.bottomBoxHeight
        local targetX = borderX + 10
        local targetY = borderY + 10
        local targetWidth = borderWidth/2 - 10 * 2
        local targetHeight = bottomMenu.menuOptionHeight

        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle(
            'line',
            borderX,
            borderY,
            borderWidth,
            borderHeight
        )

        for index, enemyName in ipairs(targetSelectionMenu.list) do
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(
                enemyName,
                targetX + 20,
                targetY + (index - 1) * targetHeight,
                targetWidth,
                'left', 0, 1, 1, 0, -1 * (targetHeight/4)
            )
            if targetSelectionMenu.current == index then
                drawMenuIndicator(
                    targetX,
                    targetY + (index - 1) * targetHeight,
                    targetWidth,
                    targetHeight
                )
            end
        end
    end

    function drawMenuIndicator(x, y, width, height)
        love.graphics.setColor(0.25, 0.25, 0.25)
        love.graphics.rectangle(
            'line',
            x,
            y,
            width,
            height
        )
    end

    function drawBattleLog()
        local borderX = 10
        local borderHeight = 180
        local borderY = windowHeight - borderHeight - 10
        local borderWidth = windowWidth - borderX * 2

        local textX = borderX + 10
        local textY = borderY + 10
        local textLineHeight = 20
        local textWidth = borderWidth - textX * 2 

        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle(
            'line',
            borderX,
            borderY,
            borderWidth,
            borderHeight
        )

        love.graphics.setFont(font_medium)
        for index, text in ipairs(battlelog) do
            love.graphics.printf(
                text,
                textX,
                textY + (index - 1)*textLineHeight,
                textWidth
            )
        end
    end



    if currentPhase == 'mainMenu' then
        drawBottomMenu(mainMenu)
    elseif currentPhase == 'characterMenu' then
        drawBottomMenu(characterMenu)
    elseif currentPhase == 'targetSelection' then
        drawTargetSelectionMenu(characterMenu)
    elseif currentPhase == 'playBattle' or currentPhase == 'battleEnd' then
        drawBattleLog()
    end

    --TEMP
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font_small)
    for index, enemy in ipairs(enemies) do
        local text
        if enemy.dead then
            text = 'DEAD'
        else
            text = ''..enemy.name..' '..enemy.currentHp..''
        end
        love.graphics.print(
            text,
            5,
            windowHeight/2 + (index - 1) * 20
        )

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
    elseif currentPhase == 'characterMenu' then
        if key == 'down' and characterMenu.current < #characterMenu.list then
            characterMenu.current = characterMenu.current + 1
        elseif key == 'up' and characterMenu.current > 1 then
            characterMenu.current = characterMenu.current - 1
        elseif key == 'z' and characterMenu.current == 1 then
            updateSelectionMenu()
            currentPhase = 'targetSelection'
            targetSelectionMenu.current = 1;
        elseif key == 'x' then
            currentPhase = 'mainMenu';
            mainMenu.current = 1;
        end
    elseif currentPhase == 'targetSelection' then
        if key == 'down' and targetSelectionMenu.current < #targetSelectionMenu.list then
            targetSelectionMenu.current = targetSelectionMenu.current + 1
        elseif key == 'up' and targetSelectionMenu.current > 1 then
            targetSelectionMenu.current = targetSelectionMenu.current - 1
        elseif key == 'x' then
            currentPhase = 'characterMenu'
            characterMenu.current = 1;
        elseif key == 'z' then
            local target;
            for index, enemy in ipairs(enemies) do
                if not enemy.dead 
                and enemy.name == targetSelectionMenu.list[targetSelectionMenu.current] then
                    target = enemy
                end
            end
            addAttackAction(character1, target)
            setEnemyAction(enemies)
            setActionOrder()
            currentPhase = 'playBattle'
        end
    end
end