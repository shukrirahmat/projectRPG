function love.load()

    windowWidth = 800
    windowHeight = 600

    love.graphics.setBackgroundColor(0,0,0)
    font_small = love.graphics.newFont('fonts/AtkinsonHyperlegibleMono-Medium.ttf', 14)
    font_medium = love.graphics.newFont('fonts/AtkinsonHyperlegibleMono-Medium.ttf', 16)
    font_large = love.graphics.newFont('fonts/AtkinsonHyperlegibleMono-Medium.ttf', 18)
    font_small:setFilter("nearest", "nearest")
    font_medium:setFilter("nearest", "nearest")
    font_large:setFilter("nearest", "nearest")
    goblin_sprite = love.graphics.newImage('images/goblin.png')
    skeleton_sprite = love.graphics.newImage('images/skeleton.png')
    monsterSpriteDimension = 128

    character1 = {
        name = 'KNIGHT',
        partyMember = true,
        maxHp = 200,
        currentHp = 200,
        maxMp = 0,
        currentMp = 0,
        attack = 120,
        defense = 90,
        agility = 40,
        critRate = 64
    }

    character2 = {
        name = 'FIGHTER',
        partyMember = true,
        maxHp = 180,
        currentHp = 180,
        maxMp = 0,
        currentMp = 0,
        attack = 90,
        defense = 70,
        agility = 60,
        critRate = 8
    }

    character3 = {
        name = 'HUNTER',
        partyMember = true,
        maxHp = 160,
        currentHp = 160,
        maxMp = 0,
        currentMp = 0,
        attack = 60,
        defense = 50,
        agility = 120,
        critRate = 64,
        dead = true
    }

    character4 = {
        name = 'MAGE',
        partyMember = true,
        maxHp = 120,
        currentHp = 120,
        maxMp = 150,
        currentMp = 150,
        attack = 30,
        defense = 40,
        agility = 80,
        critRate = 64,
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

    enemy3 = {
        name = 'GOBLIN3',
        maxHp = 100,
        currentHp = 100,
        currentMp = 0,
        maxMp = 0,
        attack = 70,
        defense = 40,
        agility = 60,
        sprite = goblin_sprite
    }

    enemy4 = {
        name = 'SKELETON1',
        maxHp = 180,
        currentHp = 180,
        currentMp = 0,
        maxMp = 0,
        attack = 90,
        defense = 50,
        agility = 70,
        sprite = skeleton_sprite
    }

    enemy5 = {
        name = 'SKELETON2',
        maxHp = 180,
        currentHp = 180,
        currentMp = 0,
        maxMp = 0,
        attack = 90,
        defense = 50,
        agility = 70,
        sprite = skeleton_sprite
    }

    party = {character1, character2, character3, character4}
    enemies = {enemy1, enemy2, enemy3, enemy4, enemy5}
    allEnemyDead = false;

    currentPhase = 'mainMenu'

    mainMenu = {current = 1, list = {'FIGHT', 'FLEE'}}
    characterMenu = {current = 1, list = {'ATTACK', 'SKILL', 'GUARD', 'ITEM'}, charID = 1}
    targetSelectionMenu = {current = 1}

    textTimer = 0;
    actionList = {}
    effectList = {};
    battlelog = {}
    battleEnded = false;

    function resetMenu(menu)
        menu.current = 1
    end

    function menuDown(menu)
        menu.current = menu.current + 1
    end

    function menuUp(menu)
        menu.current = menu.current - 1
    end

    function updateSelectionMenu()
        local enemyList = {}
        for index, enemy in ipairs(enemies) do
            if not enemy.dead then
                table.insert(enemyList, enemy.name)
            end
        end
        targetSelectionMenu.list = enemyList
    end

    function normalAttack(user, target, isSecondAttack)

        --FOR NOW NOTHING HAPPEN IF TARGET IS ALREADY DEAD
        local result
        if not target.dead then
            local damage
            local crit
            if user.critRate then
                crit = math.random(1, user.critRate) == 1
            else
                crit = math.random(1, 128) == 1
            end
            if crit then
                damage = calculateCritDamage(user, target)
            else
                damage = calculateAttackDamage(user, target)
            end
            if target.defending and not crit then
                damage = math.floor(damage/2)
            end

            local battleLogText

            if isSecondAttack then
                battleLogText = ''..user.name..' attacks again!'
            else
                battleLogText = ''..user.name..' attacks!'
            end

            if crit then
                battleLogText = ''..battleLogText..' Critical hit!';
            end

            result = { effectType = 'DAMAGE', value = damage, user = user, target = target }

            if not isSecondAttack then
                local secondAttackChance = math.floor((user.agility - target.agility)/2)
                local secondAttack = math.random(1, 100) < secondAttackChance

                if secondAttack then
                    result.secondAttack = true
                end
            end

            table.insert(battlelog, battleLogText)
            table.insert(effectList, result)

        end
    end

    function defend(user)
        user.defending = true
        table.insert(battlelog, ''..user.name..' defends!')
    end

    function addAction(action)
        if action.actionType == 'DEFEND'
        or action.actionType == 'SECONDATK' then
            action.priority = true;
            table.insert(actionList, 1, action)
        else
            table.insert(actionList, action)
        end
    end

    function setEnemyAction(enemies)
        --For now just attack
        for index, enemy in ipairs(enemies) do
            if not enemy.dead then
                addAction({actionType = 'NORMALATK', user = enemy, target = character1})
            end
        end
    end

    function chooseNextActionIndex()
        local actionIndex
        local highestSpeed = 0
        if actionList[1].priority then
            actionIndex = 1
        else
            for index, action in ipairs(actionList) do
                local agi = action.user.agility
                local speed = agi + math.floor(math.random(-agi*.25, agi*.25))
                if speed > highestSpeed then
                    highestSpeed = speed
                    actionIndex = index
                end
            end
        end
        return actionIndex
    end

    function removeAction(user)
        for index, action in ipairs(actionList) do
            if action.user == user then
                table.remove(actionList, index)
            end
        end
    end

    function executeAction(action)
        if action.actionType == 'NORMALATK' then
            normalAttack(action.user, action.target, false)
        elseif action.actionType == 'SECONDATK' then
            normalAttack(action.user, action.target, true)
        elseif action.actionType == 'DEFEND' then
            defend(action.user)
        end
    end

    function dealDamage(value, target)
        target.currentHp = target.currentHp - value;
        table.insert(battlelog, ''..target.name..' takes '..value..' damage.');
        if target.currentHp <= 0 then 
            target.currentHp = 0
            table.insert(battlelog, ''..target.name..' defeated.')
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


    function applyEffect(effect)
        if effect.effectType == 'DAMAGE' then
            dealDamage(effect.value, effect.target)
            if effect.secondAttack and not effect.target.dead then
                addAction({actionType = 'SECONDATK', user = effect.user, target = effect.target})
            end
        end
    end

    function calculateAttackDamage(attacker, target)
        local damage = math.floor(attacker.attack/2) - math.floor(target.defense/3)
        damage = damage + math.floor(math.random(-damage*.2, damage*.2))
        return math.max(damage, 1)
    end

    function calculateCritDamage(attacker, target)
        local damage = math.floor(attacker.attack/2) * 4
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

    function playBattle()
        setEnemyAction(enemies)
        currentPhase = 'playBattle'
    end

    function getAbleCharID(currentID, where)
        local nextID
        local found = false
        local outOfBound
        local id

        if where == 'next' then
            nextID = currentID + 1
            outOfBound = nextID > #party 
        elseif where == 'prev' then
            nextID = currentID - 1
            outOfBound = nextID < 1
        end

        while not found and not outOfBound do
            if not party[nextID].dead then
                found = true
                id = nextID
            end
            if where == 'next' then
                nextID = nextID + 1
                outOfBound = nextID > #party 
            elseif where == 'prev' then
                nextID = nextID - 1
                outOfBound = nextID < 1
            end
        end

        if found then
            return id
        else
            return nil
        end
    end


    function getNextAbleCharID(currentID)
        return getAbleCharID(currentID, 'next')
    end

    function getPrevAbleCharID(currentID)
        return getAbleCharID(currentID, 'prev')
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
                for index, character in ipairs({character1, enemy1, enemy2, enemy3, enemy4, enemy5}) do
                    if character.defending then
                        character.defending = false
                    end
                end                
                battlelog = {}
                currentPhase = 'mainMenu'
                mainMenu.current = 1
            elseif #effectList > 0 then
                local effect = effectList[1]
                table.remove(effectList, 1)
                applyEffect(effect)
                if allEnemyDead then
                    battleEnded = true
                end
            elseif #actionList > 0 then
                battlelog = {};
                local nextActionIndex = chooseNextActionIndex()
                local action = actionList[nextActionIndex]
                table.remove(actionList, nextActionIndex)
                executeAction(action)
            end

            textTimer = 0;
        end
    end
end

function love.draw()

    -----------------------TOP------------------------

    local function alignNumber(value)
        local result
        if value/100 > 1 then
            result = ''..value..''
        elseif value/10 > 1 then
            result = ' '..value..''
        else
            result = '  '..value..''
        end
        return result
    end

    local topBoxX = 10
    local topBoxY = 10
    local topBoxWidth = 120
    local topBoxHeight = 90
    local nameX = topBoxX + 5
    local nameY = topBoxY + 5
    local nameWidth = topBoxWidth - 10
    local hpX = topBoxX + 5
    local hpY = topBoxY + 25
    local hpWidth = topBoxWidth - 10
    local mpX = topBoxX + 5
    local mpY = topBoxY + 25 * 2
    local mpWidth = topBoxWidth - 10

    for index, member in ipairs(party) do
        if member.dead then
            love.graphics.setColor(0.25, 0.25, 0.25)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.rectangle(
            'line',
            topBoxX + (index - 1) * (topBoxWidth + topBoxX),
            topBoxY,
            topBoxWidth,
            topBoxHeight
        )
        love.graphics.setFont(font_small)
        love.graphics.printf(
            member.name,
            nameX + (index - 1) * (topBoxWidth + topBoxX),
            nameY,
            nameWidth,
            'center'
        )
        love.graphics.setFont(font_large)
        local memberHpX = hpX + (index - 1) * (topBoxWidth + topBoxX)
        local memberMpX = memberHpX
        love.graphics.setFont(font_large)
        love.graphics.printf('HP '..alignNumber(member.currentHp)..'', memberHpX, hpY, hpWidth, 'center')
        love.graphics.printf('MP '..alignNumber(member.currentMp)..'', memberMpX, mpY, mpWidth, 'center')
    end

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

    function drawBottomMenu(menu)
        local borderHeight = 180
        local borderX = 10
        local borderY = windowHeight - borderHeight - 10
        local borderWidth = (windowWidth - 10)/4 - 10
        local menuOptionX = borderX + 10
        local menuOptionY = borderY + 10
        local menuOptionWidth = borderWidth - 20
        local menuOptionHeight = (borderHeight - 20)/4

        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle(
            'line',
            borderX,
            borderY,
            borderWidth,
            borderHeight
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
        
        for index, option in ipairs(menu.list) do
            if menu.current == index then
                drawMenuIndicator(
                    menuOptionX,
                    menuOptionY + (index - 1) * menuOptionHeight,
                    menuOptionHeight
                )

            end
        end

        return {
            borderHeight = borderHeight,
            borderX = borderX,
            borderY = borderY,
            borderWidth = borderWidth,
            menuOptionX = menuOptionX,
            menuOptionY = menuOptionY,
            menuOptionWidth = menuOptionWidth,
            menuOptionHeight = menuOptionHeight
        }
    end
    
    function drawCharacterMenu()
        local bottomMenu = drawBottomMenu(characterMenu)
        
        local nameBorderHeight = 30
        local nameBorderX = bottomMenu.borderX
        local nameBorderY = bottomMenu.borderY - nameBorderHeight
        local nameBorderWidth = bottomMenu.borderWidth / 2
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
        local charName = party[characterMenu.charID].name
        love.graphics.printf(
            charName,
            nameX,
            nameY,
            nameWidth,
            'center'
        )
        
        return bottomMenu;
    end
        

    function drawTargetSelectionMenu(menu)
        local bottomMenu = drawCharacterMenu()

        local borderX = bottomMenu.borderX + bottomMenu.borderWidth + 10
        local borderY = bottomMenu.borderY
        local borderWidth = (windowWidth - 10)/4 - 10;
        local borderHeight = bottomMenu.borderHeight
        local targetX = borderX + 10
        local targetY = borderY + 10
        local targetWidth = borderWidth - 10 * 2
        local targetHeight = bottomMenu.menuOptionHeight

        love.graphics.setFont(font_medium)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle(
            'line',
            borderX,
            borderY,
            borderWidth,
            borderHeight
        )

        love.graphics.setColor(1, 1, 1)
        if targetSelectionMenu.current < 5 then
            for i = 1, math.min(#targetSelectionMenu.list, 4) do
                love.graphics.printf(
                    targetSelectionMenu.list[i],
                    targetX + 20,
                    targetY + (i - 1) * targetHeight,
                    targetWidth - 20,
                    'left', 0, 1, 1, 0, -1 * (targetHeight/4)
                )
                if #targetSelectionMenu.list > 4 then
                    love.graphics.polygon(
                        'fill',
                        borderX + borderWidth/2 - 10,
                        borderY + borderHeight - 10,
                        borderX + borderWidth/2 + 10,
                        borderY + borderHeight - 10,
                        borderX + borderWidth/2,
                        borderY + borderHeight - 5
                    )
                end
                if targetSelectionMenu.current == i then
                    drawMenuIndicator(
                        targetX,
                        targetY + (i - 1) * targetHeight,
                        targetHeight
                    )
                end
            end
        else
            for i = 5, #targetSelectionMenu.list do
                love.graphics.printf(
                    targetSelectionMenu.list[i],
                    targetX + 20,
                    targetY + (i - 5) * targetHeight,
                    targetWidth - 20,
                    'left', 0, 1, 1, 0, -1 * (targetHeight/4)
                )
                love.graphics.polygon(
                    'fill',
                    borderX + borderWidth/2 - 10,
                    borderY + 10,
                    borderX + borderWidth/2 + 10,
                    borderY + 10,
                    borderX + borderWidth/2,
                    borderY + 5
                )
                if targetSelectionMenu.current == i then
                    drawMenuIndicator(
                        targetX,
                        targetY + (i - 5) * targetHeight,
                        targetHeight
                    )
                end
            end
        end
    end

    function drawMenuIndicator(x, y, height)
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
        drawCharacterMenu();
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
            windowWidth - 200,
            5 + (index - 1) * 20
        )

    end

end

function love.keypressed(key)
    if currentPhase == 'mainMenu' then
        if key == 'down' and mainMenu.current < #mainMenu.list then
            menuDown(mainMenu)
        elseif key == 'up' and mainMenu.current > 1 then
            menuUp(mainMenu)
        elseif key == 'z' and mainMenu.current == 1 then
            currentPhase = 'characterMenu';
            resetMenu(characterMenu)
            characterMenu.charID = getNextAbleCharID(0)
        end
    elseif currentPhase == 'characterMenu' then
        if key == 'down' and characterMenu.current < #characterMenu.list then
            menuDown(characterMenu)
        elseif key == 'up' and characterMenu.current > 1 then
            menuUp(characterMenu)
        elseif key == 'z' then
            if characterMenu.current == 1 then
                updateSelectionMenu()
                currentPhase = 'targetSelection'
                resetMenu(targetSelectionMenu)
            elseif characterMenu.current == 3 then
                addAction({actionType = 'DEFEND', user = party[characterMenu.charID]})
                if getNextAbleCharID(characterMenu.charID) then
                    characterMenu.charID = getNextAbleCharID(characterMenu.charID);
                    resetMenu(characterMenu)
                else
                    playBattle()
                end
            end
        elseif key == 'x' then
            if getPrevAbleCharID(characterMenu.charID) then
                characterMenu.charID = getPrevAbleCharID(characterMenu.charID);
                resetMenu(characterMenu)
            else
                currentPhase = 'mainMenu';
                mainMenu.current = 1;
            end
        end
    elseif currentPhase == 'targetSelection' then
        if key == 'down' and targetSelectionMenu.current < #targetSelectionMenu.list then
            menuDown(targetSelectionMenu)
        elseif key == 'up' and targetSelectionMenu.current > 1 then
            menuUp(targetSelectionMenu)
        elseif key == 'x' then
            currentPhase = 'characterMenu'
            resetMenu(characterMenu)
        elseif key == 'z' then
            local target;
            for index, enemy in ipairs(enemies) do
                if not enemy.dead 
                and enemy.name == targetSelectionMenu.list[targetSelectionMenu.current] then
                    target = enemy
                end
            end
            addAction( {actionType = 'NORMALATK', user = party[characterMenu.charID], target = target})
            if getNextAbleCharID(characterMenu.charID) then
                currentPhase = 'characterMenu'
                characterMenu.charID = getNextAbleCharID(characterMenu.charID);
                resetMenu(characterMenu)
            else
                playBattle()
            end
        end
    end
end