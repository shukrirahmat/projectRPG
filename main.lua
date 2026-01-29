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
        maxHp = 25,
        currentHp = 25,
        maxMp = 0,
        currentMp = 0,
        attack = 12,
        defense = 5,
        agility = 3
    }

    enemy1 = {
        name = 'GOBLIN',
        maxHp = 10,
        currentHp = 10,
        currentMp = 0,
        maxMp = 0,
        attack = 6,
        defense = 3,
        agility = 2,
        sprite = goblin_sprite
    }

    currentPhase = 'mainMenu'

    mainMenu = {current = 1, list = {'FIGHT', 'FLEE'}}
    characterMenu = {current = 1, list = {'ATTACK', 'SKILL', 'GUARD', 'ITEM'}}

    textTimer = 0;
    actionOrder = {}
    damageToDeal = {};
    battlelog = {}
    battleEnded = false;

    function setActionOrder()
        actionOrder = {}
        local units = {character1, enemy1}
        for index, unit in ipairs(units) do
            local action = {}
            action.speed = unit.agility + math.floor(math.random(-unit.agility*.25, unit.agility*.25))
            action.unit = unit
            table.insert(actionOrder, action)
        end
        table.sort(actionOrder, function(action1, action2)
                return action1.speed > action2.speed
            end)
    end

end

function love.update(dt)
    local function getTarget(attacker)
        local target
        local units = {character1, enemy1}
        if attacker == character1 then
            target = enemy1
        elseif attacker == enemy1 then
            target = character1
        end
        return target
    end

    local function calculateAttackDamage(attacker, target)
        local damage = math.floor(attacker.attack/2) - math.floor(target.defense/3)
        damage = damage + math.floor(math.random(-damage*.2, damage*.2))
        return math.max(damage, 1)
    end

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
            if #damageToDeal == 0 and #actionOrder == 0 then
                battlelog = {}
                currentPhase = 'mainMenu'
                mainMenu.current = 1
            elseif #damageToDeal == 0 then
                battlelog = {};
                local attacker = actionOrder[1].unit
                local target = getTarget(attacker)
                local totalDamage = calculateAttackDamage(attacker, target)
                table.insert(battlelog, ''..attacker.name..' attacks '..target.name..'')
                table.insert(damageToDeal, {damage = totalDamage, target = target})
                table.remove(actionOrder, 1)
            elseif #damageToDeal > 0 then
                local target = damageToDeal[1].target
                local damage = damageToDeal[1].damage
                target.currentHp = target.currentHp - damage
                table.insert(battlelog, ''..target.name..' takes '..damage..' damage!')
                table.remove(damageToDeal, 1)
                if target.currentHp < 0 then 
                    target.currentHp = 0
                    if target.sprite then
                        target.sprite = nil
                    end
                    battleEnded = true;
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

    if enemy1.sprite then
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
    end

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
    elseif currentPhase == 'playBattle' or currentPhase == 'battleEnd' then
        drawBattleLog()
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
            setActionOrder()
            currentPhase = 'playBattle'
        elseif key == 'x' then
            currentPhase = 'mainMenu';
            mainMenu.current = 1;
        end
    end
end