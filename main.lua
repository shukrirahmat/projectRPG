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
    fire_sprite1 = love.graphics.newImage('images/fire1.png')
    fire_sprite2 = love.graphics.newImage('images/fire2.png')
    fire_sprite3 = love.graphics.newImage('images/fire3.png')
    fire_sprite4 = love.graphics.newImage('images/fire4.png')

    blaze_sheet = love.graphics.newImage('images/blaze.png')

    blaze_frames = {}
    for i = 0, 8, 1 do
        local quad = love.graphics.newQuad(0, i*128, 800, 128, 800, 1152)
        table.insert(blaze_frames, quad)
    end

    monsterSpriteDimension = 128
    skillSpriteDimension = 64

    character1 = {
        name = 'KNIGHT',
        partyMember = true,
        maxHp = 200,
        currentHp = 200,
        maxMp = 0,
        currentMp = 0,
        attack = 80,
        defense = 80,
        agility = 60,
        critRate = 64
    }

    character2 = {
        name = 'FIGHTER',
        partyMember = true,
        maxHp = 180,
        currentHp = 180,
        maxMp = 0,
        currentMp = 0,
        attack = 70,
        defense = 50,
        agility = 100,
        critRate = 16
    }

    character3 = {
        name = 'PRIEST',
        partyMember = true,
        maxHp = 160,
        currentHp = 160,
        maxMp = 50,
        currentMp = 50,
        attack = 60,
        defense = 50,
        agility = 80,
        critRate = 64,
        skills = {1}
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
        skills = { 2, 3 }
    }

    enemy1 = {
        name = 'GOBLIN1',
        maxHp = 30,
        currentHp = 1,
        currentMp = 0,
        maxMp = 0,
        attack = 60,
        defense = 40,
        agility = 60,
        sprite = goblin_sprite,
        spriteHeight = monsterSpriteDimension/4
    }

    enemy2 = {
        name = 'GOBLIN2',
        maxHp = 30,
        currentHp = 1,
        currentMp = 0,
        maxMp = 0,
        attack = 60,
        defense = 40,
        agility = 60,
        sprite = goblin_sprite,
        spriteHeight = monsterSpriteDimension/4
    }

    enemy3 = {
        name = 'GOBLIN3',
        maxHp = 30,
        currentHp = 1,
        currentMp = 0,
        maxMp = 0,
        attack = 60,
        defense = 40,
        agility = 60,
        sprite = goblin_sprite,
        spriteHeight = monsterSpriteDimension/4
    }

    enemy4 = {
        name = 'SKELETON1',
        maxHp = 50,
        currentHp = 1,
        currentMp = 0,
        maxMp = 0,
        attack = 90,
        defense = 50,
        agility = 40,
        sprite = skeleton_sprite,
        spriteHeight = 0,
        strongAgainst = {'FIRE'}
    }

    enemy5 = {
        name = 'SKELETON2',
        maxHp = 50,
        currentHp = 1,
        currentMp = 0,
        maxMp = 0,
        attack = 90,
        defense = 50,
        agility = 40,
        sprite = skeleton_sprite,
        spriteHeight = 0,
        strongAgainst = {'FIRE'}
    }

    party = {character1, character2, character3, character4}
    enemies = {enemy1, enemy2, enemy3, enemy4, enemy5}
    partyDied = false;
    allEnemyDead = false;

    function checkResistance(target, category, element)
        local listToCheck
        if category == 'immunity' then
            listToCheck = target.immunity
        elseif category == 'strong' then
            listToCheck = target.strongAgainst
        end

        local result = false

        if listToCheck and #listToCheck > 0 then
            local i = 1;
            while i <= #listToCheck and result == false do
                if listToCheck[i] == element then
                    result = true
                else
                    i = i + 1
                end
            end
        end

        return result
    end

    function handleResistance(element, target, baseDamage)
        local effect
        local damage = baseDamage

        if checkResistance(target, 'immunity', element) then
            effect = {effectType='IMMUNE'}
        elseif checkResistance(target, 'strong', element) then
            damage = math.floor(baseDamage / 2 )
            effect = {effectType='STRONGRES', value = damage}
        else
            effect = {effectType= 'DAMAGE', value = damage}
        end

        return effect
    end

    function castBlaze(user, group)
        local text = ''..user.name..' casts Blaze';
        battleLogAdd(text)

        for index, target in ipairs(group) do
            if not target.dead then
                local damage = math.random(8, 12)
                local effect = handleResistance('FIRE', target, damage)

                effect.user = user
                effect.target = target
                table.insert(effectList, effect)
            end
        end
    end


    function castFire(user, target)
        local damage = math.random(8, 12)
        local text = ''..user.name..' casts Fire';
        local effect = handleResistance('FIRE', target, damage)

        effect.user = user
        effect.target = target

        battleLogAdd(text)
        table.insert(effectList, effect)
    end

    function castHeal(user, target)
        local amount = math.random(36, 44)
        local text = ''..user.name..' casts Heal';

        local effect = {effectType='RECOVERY', value = amount, user = user, target = target}
        battleLogAdd(text)
        table.insert(effectList, effect)
    end

    allSkills = {
        { 
            name = 'Heal',
            cost = 2, 
            desc = 'Recover 36-44 HP to one ally',
            aim = party,
            scope = 'single',
            execute = castHeal
        },
        { 
            name = 'Fire', 
            cost= 2, 
            desc = 'Deal 8-12 fire damage to one enemy',
            aim = enemies,
            scope = 'single',
            execute = castFire,
            sprite = {fire_sprite1, fire_sprite2, fire_sprite3, fire_sprite4}
        },
        { 
            name = 'Blaze', 
            cost= 4, 
            desc = 'Deal 8-12 fire damage to all enemies',
            aim = enemies,
            scope = 'all',
            execute = castBlaze
        },
    }

    currentPhase = 'mainMenu'

    mainMenu = {current = 1, list = {'FIGHT', 'FLEE'}}
    characterMenu = {current = 1, list = {'ATTACK', 'SKILL', 'GUARD', 'ITEM'}, charID = 1}
    targetSelectionMenu = {current = 1}
    skillSelectionMenu = {current = 1}

    actionList = {}
    effectList = {};
    toKillList = {};
    battlelog = {}
    battleEnded = false;

    textTimer = 0
    textSpeed = 1
    animation = nil
    
    function battleLogAdd(text)
        if #battlelog >= 8 then
            table.remove(battlelog, 1)
        end
        
        table.insert(battlelog, text)
    end

    function resetMenu(menu)
        menu.current = 1
    end

    function menuDown(menu)
        menu.current = menu.current + 1
    end

    function menuUp(menu)
        menu.current = menu.current - 1
    end

    function updateSkillSelectionMenu(character)
        local skillList = {}
        if character.skills and #character.skills > 0 then
            for index, skill in ipairs(character.skills) do
                table.insert(skillList, skill)
            end
        end

        skillSelectionMenu.user = character
        skillSelectionMenu.list = skillList
    end

    function updateTargetSelectionMenu(fromMenu, group)
        local targetList = {}
        for index, target in ipairs(group) do
            if not target.dead then
                table.insert(targetList, target.name)
            end
        end
        targetSelectionMenu.list = targetList
        targetSelectionMenu.fromMenu = fromMenu
    end

    function reselectTargetWhenDead(selectedTarget)
        local target = selectedTarget
        if selectedTarget.dead then
            if selectedTarget.partyMember then
                target = selectTargetRandomly(party)
            else
                target = selectTargetRandomly(enemies)
            end
        end
        return target
    end

    function normalAttack(user, target, isSecondAttack)

        local result
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
                addAction({actionType = 'SECONDATK', user = user, target = target})
            end
        end

        battleLogAdd(battleLogText)
        table.insert(effectList, result)
    end

    function defend(user)
        user.defending = true
        battleLogAdd(''..user.name..' defends!')
    end

    function addPriorityAction(action)
        local i = 1
        local stop = false

        while not stop and i <= #actionList do
            if actionList[i].priority then
                i = i + 1
            else
                stop = true
            end
        end

        if stop then
            table.insert(actionList, i, action)
        else
            table.insert(actionList, action)
        end
    end


    function addAction(action)
        if action.actionType == 'DEFEND'
        or action.actionType == 'SECONDATK' then
            action.priority = true;
            addPriorityAction(action)
        else
            table.insert(actionList, action)
        end
    end

    function selectTargetRandomly(group)
        local availableTargets = {}

        for index, target in ipairs(group) do
            if not target.dead then
                table.insert(availableTargets, target)
            end
        end

        local selectedTarget
        local i = 1

        while not selectedTarget do
            if i == #availableTargets then
                selectedTarget = availableTargets[i]
            else
                local chance = math.random(1, 10)
                if chance < 5 then
                    i = i + 1
                else
                    selectedTarget = availableTargets[i]
                end
            end
        end

        return selectedTarget
    end    

    function setPartyAction()
        for index, member in ipairs(party) do
            if not member.dead and member.currentAction then
                addAction(member.currentAction)
            end
        end
    end

    function setEnemyAction()
        --For now just attack
        for index, enemy in ipairs(enemies) do
            if not enemy.dead then
                local target = selectTargetRandomly(party)
                addAction({actionType = 'NORMALATK', user = enemy, target = target})
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
                local speed = agi + math.floor(math.random(-agi*0.5, agi*0.5))
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
        elseif action.actionType == 'SKILL' then
            action.user.currentMp = math.max(0, action.user.currentMp - action.skill.cost)
            action.skill.execute(action.user, action.target)
        end
    end

    function handleDeath(target)
        target.currentHp = 0
        target.dead = true
        battleLogAdd(''..target.name..' defeated.')
        removeAction(target)

        if actionList[1] and actionList[1].actionType == 'SECONDATK' then
            table.remove(actionList, 1)
        end

        if target.partyMember and checkIfAllDead(party) then
            partyDied = true
        elseif not target.partyMember and checkIfAllDead(enemies) then
            allEnemyDead = true
        end
    end

    function dealDamage(value, target)
        target.currentHp = target.currentHp - value;
        battleLogAdd(''..target.name..' takes '..value..' damage.');
        if target.currentHp <= 0 then
            target.currentHp = 0;
            table.insert(toKillList, target)
        end
    end

    function recover(value, target)
        target.currentHp = target.currentHp + value;
        if target.currentHp > target.maxHp then
            target.currentHp = target.maxHp
        end
        battleLogAdd(''..target.name..' recover '..value..' HP.');
    end


    function applyEffect(effect)
        if effect.effectType == 'DAMAGE' or effect.effectType == 'STRONGRES' then
            dealDamage(effect.value, effect.target)
        elseif effect.effectType == 'IMMUNE' then
            battleLogAdd('But it did not affect '..effect.target.name..'');
        elseif effect.effectType == 'RECOVERY' then
            recover(effect.value, effect.target)
        end
    end

    function calculateAttackDamage(attacker, target)
        local damage = math.floor(attacker.attack/2) - math.floor(target.defense/3)
        damage = damage + math.floor(math.random(-damage*.2, damage*.2))
        return math.max(damage, 1)
    end

    function calculateCritDamage(attacker, target)
        local damage = math.floor(attacker.attack/2 * 4) - math.floor(target.defense/6)
        damage = damage + math.floor(math.random(-damage*.2, damage*.2))
        return math.max(damage, 1)
    end

    function checkIfAllDead(group)
        local totalDead = 0
        for index, member in ipairs(group) do
            if member.dead then
                totalDead = totalDead + 1
            end
        end

        return totalDead == #group;
    end

    function playBattle()
        setPartyAction();
        setEnemyAction(enemies)
        textTimer = textSpeed/2
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

    function createAnimation(character, category, maxTick, speed, value)
        return {
            character=character,
            category=category,
            timer=0,
            tick=0,
            maxTick=maxTick,
            speed=speed,
            value=value
        }
    end
end

function love.update(dt)

    if battleEnded and not animation then
        currentPhase = 'battleEnd';
        textTimer = textTimer + dt
        if textTimer > textSpeed then
            battlelog = {}
            if partyDied then
                battleLogAdd('Party has been defeated')
            elseif allEnemyDead then
                battleLogAdd('All enemy has been defeated')
            end
            textTimer = 0
        end                

    elseif currentPhase == 'playBattle' then
        textTimer = textTimer + dt
        if not animation and textTimer > textSpeed then
            if #effectList == 0 and #actionList == 0 and #toKillList == 0 then
                for index, group in ipairs({party, enemies}) do
                    for memberIndex, member in ipairs(group) do
                        if member.defending then
                            member.defending = false
                        end

                        if member.currentAction then
                            member.currentAction = nil
                        end
                    end
                end                
                battlelog = {}
                currentPhase = 'mainMenu'
                mainMenu.current = 1
            elseif #toKillList > 0 then
                local toKill = toKillList[1]
                table.remove(toKillList, 1)
                handleDeath(toKill)

                --death animation--
                if not toKill.partyMember then
                    animation = createAnimation(toKill, 'enemyDied', 8, 0.05)
                end

                if partyDied or allEnemyDead then
                    battleEnded = true
                end

            elseif #effectList > 0 then

                local effect = effectList[1]
                table.remove(effectList, 1)
                applyEffect(effect)

                --starts damage animation--
                if effect.effectType == 'DAMAGE' or effect.effectType == 'STRONGRES' then
                    if not effect.target.partyMember then
                        if effect.effectType == 'DAMAGE' then
                            animation = createAnimation(
                                effect.target,
                                'enemyDamaged',
                                10,
                                0.08,
                                effect.value
                            )
                        elseif effect.effectType == 'STRONGRES' then
                            animation = createAnimation(
                                effect.target,
                                'enemyResisted',
                                10,
                                0.08,
                                effect.value
                            )
                        end
                    else
                        animation = createAnimation(effect.target, 'partyDamaged', 10, 0.05)
                    end
                end
            elseif #actionList > 0 then
                battlelog = {};
                local nextActionIndex = chooseNextActionIndex()
                local action = actionList[nextActionIndex]
                table.remove(actionList, nextActionIndex)

                if action.target
                and action.target ~= party and action.target ~= enemies then
                    action.target = reselectTargetWhenDead(action.target)
                end
                executeAction(action)

                --starts attack animation--
                if not action.user.partyMember then
                    if action.actionType == 'NORMALATK' or action.actionType == 'SECONDATK' then
                        animation = createAnimation(action.user, 'enemyAttack', 8, 0.08)
                    end
                else
                    if action.actionType == 'SKILL' and action.skill.aim == enemies then
                        if action.skill.scope == 'single' then
                            animation = createAnimation(action.target, 'skillToEnemy', 10, 0.1)
                            animation.skill = action.skill
                        elseif action.skill.scope == 'all' then
                            animation = createAnimation(action.target, 'skillToEnemyAll', 10, 0.08)
                            animation.skill = action.skill
                        end
                    end
                end
            end
            textTimer = 0;

        elseif animation then
            animation.timer = animation.timer + dt
            if animation.tick >= animation.maxTick then
                animation = nil
            elseif animation.timer > animation.speed then
                animation.tick = animation.tick + 1
                animation.timer = 0;
            end
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

        local shiftY = 0;
        if animation and animation.category == 'partyDamaged' and animation.character == member then
            for i = 0, animation.maxTick, 1 do
                if animation.tick <= 3 then
                    shiftY = animation.tick * 4
                else
                    shiftY = math.max(0, (16 - (animation.tick) * 2))
                end
            end
        end        

        love.graphics.rectangle(
            'line',
            topBoxX + (index - 1) * (topBoxWidth + topBoxX),
            topBoxY + shiftY,
            topBoxWidth,
            topBoxHeight
        )
        love.graphics.setFont(font_small)
        love.graphics.printf(
            member.name,
            nameX + (index - 1) * (topBoxWidth + topBoxX),
            nameY + shiftY,
            nameWidth,
            'center'
        )
        love.graphics.setFont(font_large)
        local memberHpX = hpX + (index - 1) * (topBoxWidth + topBoxX)
        local memberMpX = memberHpX
        love.graphics.setFont(font_large)
        love.graphics.printf('HP '..alignNumber(member.currentHp)..'', memberHpX, hpY + shiftY, hpWidth,        'center')
        love.graphics.printf('MP '..alignNumber(member.currentMp)..'', memberMpX, mpY + shiftY, mpWidth,        'center')
    end

    ---------------------MIDDLE-------------------

    local enemyMovement = { 
        {x=-5, y=0},
        {x=-5, y=-5},
        {x= 0, y=-5},
        {x=5, y=-5},
        {x=5, y=0},
        {x=5, y=5},
        {x= 0, y=5},
    }

    local function getSpritePos(enemy,index, shiftX, shiftY)
        local x = windowWidth/2 + (index - 1) * monsterSpriteDimension + shiftX 
        - (monsterSpriteDimension/2) * #enemies;
        local y = windowHeight/2 + shiftY  - monsterSpriteDimension/1.5
        local height = enemy.spriteHeight
        local sprite = {x = x, y = y, height = height}
        return sprite
    end

    local function drawEnemySprite(enemy, index, shiftX, shiftY, tint)
        local spritePos = getSpritePos(enemy, index, shiftX, shiftY)
        if not tint then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(tint, tint, tint)
        end
        local x = spritePos.x
        local y = spritePos.y
        love.graphics.draw(enemy.sprite, x, y)
        love.graphics.setColor(1, 1, 1)
    end
    
    if animation and animation.category == 'skillToEnemyAll' then
        for index, frame in ipairs(blaze_frames) do
            if animation.tick == index then
                love.graphics.draw(
                    blaze_sheet, 
                    blaze_frames[index], 
                    0, 
                    windowHeight/2 - monsterSpriteDimension/2)
            end
        end
    end

    for index, enemy in ipairs(enemies) do
        if not enemy.dead then
            if animation and animation.character == enemy then
                if animation.category == 'enemyAttack' then
                    for moveIndex, movement in ipairs(enemyMovement) do
                        if animation.tick == moveIndex then
                            drawEnemySprite(enemy, index, movement.x, movement.y)
                        elseif animation.tick == 0 or animation.tick > #enemyMovement then
                            drawEnemySprite(enemy, index, 0, 0)
                        end
                    end
                elseif animation.category == 'skillToEnemy' then
                    love.graphics.setColor(1, 1, 1)
                    drawEnemySprite(enemy, index, 0, 0)
                    local spritePos = getSpritePos(enemy, index, 0, 0)
                    local spriteID = math.floor(animation.tick * 0.5)
                    if animation.skill.sprite[spriteID] then
                        love.graphics.draw(
                            animation.skill.sprite[spriteID],
                            spritePos.x + monsterSpriteDimension/2 - skillSpriteDimension/2,
                            spritePos.y + spritePos.height
                            + monsterSpriteDimension/2 - skillSpriteDimension/2 
                        )
                    end
                elseif animation.category == 'enemyDamaged' 
                or animation.category == 'enemyResisted' then
                    for i = 0, animation.maxTick, 1 do
                        if animation.tick % 2 == 0 and animation.tick <= 4 then
                            drawEnemySprite(enemy, index, 0, 0)
                        elseif animation.tick > 4 then
                            drawEnemySprite(enemy, index, 0, 0)
                        else
                            drawEnemySprite(enemy, index, 0, 0, 0.1)
                        end

                        if animation.tick > 1 then
                            local spritePos = getSpritePos(enemy, index, 0, 0)
                            if animation.category == 'enemyResisted' then
                                love.graphics.setColor(0.5,0.5,0.5)
                            else
                                love.graphics.setColor(1,1,1)
                            end
                            love.graphics.setFont(font_large)
                            love.graphics.printf(
                                ''..animation.value..'',
                                spritePos.x,
                                spritePos.y + spritePos.height - 20 - animation.tick * 2,
                                monsterSpriteDimension,
                                'center'
                            )
                        end
                    end
                end
            else
                drawEnemySprite(enemy, index, 0, 0)
            end
        elseif enemy.dead and animation 
        and animation.character == enemy and animation.category == 'enemyDied' then
            for i = 0, animation.maxTick, 1 do
                local tint = math.max(0, 1 - animation.tick/5)
                drawEnemySprite(enemy, index, 0, 0, tint)
            end
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

    function drawSkillSelectionMenu(isTargeting)
        local bottomMenu = drawCharacterMenu()

        local borderX = bottomMenu.borderX + bottomMenu.borderWidth + 10
        local borderY = bottomMenu.borderY
        local borderWidth = (windowWidth - 10)/2 - 10
        local borderHeight = bottomMenu.borderHeight

        love.graphics.setColor(1,1,1)
        love.graphics.rectangle(
            'line',
            borderX,
            borderY,
            borderWidth,
            borderHeight
        )

        if #skillSelectionMenu.list == 0 then
            local name = skillSelectionMenu.user.name
            love.graphics.setFont(font_small)
            love.graphics.printf(
                ''..name..' have not learned any skills',
                borderX + 10,
                borderY + 10,
                borderWidth - 20,
                'left'
            )
        else
            love.graphics.setFont(font_medium)
            for index, id in ipairs(skillSelectionMenu.list) do
                local skill = allSkills[id]
                if skillSelectionMenu.user.currentMp < skill.cost then
                    love.graphics.setColor(0.25, 0.25, 0.25)
                else
                    love.graphics.setColor(1,1,1)
                end

                local x
                if index % 2 == 0 then
                    x = (borderX + 10) * 2
                else
                    x = borderX + 10
                end
                local y = borderY + 10 + (math.floor((index - 1)/2)) * bottomMenu.menuOptionHeight
                local height = bottomMenu.menuOptionHeight

                love.graphics.printf(
                    skill.name,
                    x + 20,
                    y,
                    borderWidth/2 - 40,
                    'left', 0, 1, 1, 0, -1 * (height/4)
                )

                if skillSelectionMenu.current == index then
                    drawMenuIndicator(x, y, height)

                    if isTargeting then
                        drawTargetSelectionMenu(
                            borderX, 
                            borderY, 
                            borderWidth, 
                            borderHeight, 
                            bottomMenu.menuOptionHeight
                        )
                    else 
                        drawDescriptionText(
                            borderX + borderWidth + 10,
                            borderY,
                            borderHeight,
                            skill,
                            height
                        )
                    end
                end
            end

        end
    end

    function drawDescriptionText(x, y, height, skill, menuHeight)
        local width = (windowWidth - 10)/4 - 10
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle(
            'line',
            x,
            y,
            width,
            height
        )
        love.graphics.printf(
            'MP cost: '..skill.cost..'',
            x + 20,
            y + 10,
            width - 20,
            'left', 0, 1, 1, 0, -1 * (menuHeight/4)
        )
        love.graphics.line(x, y + menuHeight + 10, x + width, y + menuHeight + 10)
        love.graphics.printf(
            skill.desc,
            x + 20,
            y + menuHeight + 10,
            width - 40,
            'left', 0, 1, 1, 0, -1 * (menuHeight/4)
        )
    end

    function drawAttackSelectionMenu()
        local bottomMenu = drawCharacterMenu()
        drawTargetSelectionMenu(
            bottomMenu.borderX,
            bottomMenu.borderY,
            bottomMenu.borderWidth,
            bottomMenu.borderHeight,
            bottomMenu.menuOptionHeight
        )
    end


    function drawTargetSelectionMenu(refX, refY, refWidth, refHeight, refOptionHeight)
        local borderX = refX + refWidth + 10
        local borderY = refY
        local borderWidth = (windowWidth - 10)/4 - 10;
        local borderHeight = refHeight
        local targetX = borderX + 10
        local targetY = borderY + 10
        local targetWidth = borderWidth - 10 * 2
        local targetHeight = refOptionHeight

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
    elseif currentPhase == 'skillSelection' then
        drawSkillSelectionMenu(false)
    elseif currentPhase == 'targetSelection' then
        if targetSelectionMenu.fromMenu == characterMenu then
            drawAttackSelectionMenu()
        elseif targetSelectionMenu.fromMenu == skillSelectionMenu then
            drawSkillSelectionMenu(true)
        end
    elseif currentPhase == 'playBattle' or currentPhase == 'battleEnd' then
        drawBattleLog()
    end

    --TEMP
    --[[love.graphics.setColor(1, 1, 1)
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

    end]]

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
                updateTargetSelectionMenu(characterMenu, enemies)
                currentPhase = 'targetSelection'
                resetMenu(targetSelectionMenu)
            elseif characterMenu.current == 2 then
                updateSkillSelectionMenu(party[characterMenu.charID])
                currentPhase = 'skillSelection'
                resetMenu(skillSelectionMenu)
            elseif characterMenu.current == 3 then
                local user = party[characterMenu.charID]
                user.currentAction = {actionType = 'DEFEND', user = user}
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
    elseif currentPhase == 'skillSelection' then
        if key == 'down' and skillSelectionMenu.current + 2 <= #skillSelectionMenu.list then
            menuDown(skillSelectionMenu)
            menuDown(skillSelectionMenu)
        elseif key == 'up' and skillSelectionMenu.current - 2 >= 1 then
            menuUp(skillSelectionMenu)
            menuUp(skillSelectionMenu)
        elseif key == 'right' 
        and skillSelectionMenu.current % 2 ~= 0 
        and skillSelectionMenu.current + 1 <= #skillSelectionMenu.list then
            menuDown(skillSelectionMenu)
        elseif key == 'left'
        and skillSelectionMenu.current % 2 == 0
        and skillSelectionMenu.current - 1 >= 1 then
            menuUp(skillSelectionMenu)
        elseif key == 'x' then
            currentPhase = 'characterMenu'
            characterMenu.current = 2
        elseif key == 'z' then
            local skillToUse = allSkills[skillSelectionMenu.list[skillSelectionMenu.current]]
            if skillSelectionMenu.user.currentMp >= skillToUse.cost then
                if skillToUse.scope == 'single' then
                    updateTargetSelectionMenu(skillSelectionMenu, skillToUse.aim)
                    currentPhase = 'targetSelection'
                    resetMenu(targetSelectionMenu)
                elseif skillToUse.scope == 'all' then
                    local user = party[characterMenu.charID]
                    user.currentAction = {
                        actionType = 'SKILL',
                        user = user, 
                        target = enemies, 
                        skill = skillToUse
                    }
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
    elseif currentPhase == 'targetSelection' then
        if key == 'down' and targetSelectionMenu.current < #targetSelectionMenu.list then
            menuDown(targetSelectionMenu)
        elseif key == 'up' and targetSelectionMenu.current > 1 then
            menuUp(targetSelectionMenu)
        elseif key == 'x' then
            if targetSelectionMenu.fromMenu == characterMenu then
                currentPhase = 'characterMenu'
                resetMenu(characterMenu)
            elseif targetSelectionMenu.fromMenu == skillSelectionMenu then
                currentPhase = 'skillSelection'
            end
        elseif key == 'z' then
            local target;
            for index, group in ipairs({party, enemies}) do
                for groupIndex, member in ipairs(group) do
                    if not member.dead 
                    and member.name == targetSelectionMenu.list[targetSelectionMenu.current] then
                        target = member
                    end
                end
            end
            local user = party[characterMenu.charID]

            if targetSelectionMenu.fromMenu == characterMenu then
                user.currentAction = {actionType = 'NORMALATK', user = user, target = target}
            elseif targetSelectionMenu.fromMenu == skillSelectionMenu then
                local skill = allSkills[skillSelectionMenu.list[skillSelectionMenu.current]]
                user.currentAction = {
                    actionType = 'SKILL',
                    user = user, 
                    target = target, 
                    skill = skill
                }
            end

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