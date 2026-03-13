local drawHelper = require('utils.drawHelper')
local actionData = require('data.actionData')
local gameState = require('gameState')

local battleMenu = {}

local function drawLeftMenu(state, menu)
    local borderHeight = state.menuHeight
    local borderX = 10
    local borderY = windowHeight - borderHeight - 10
    local borderWidth = (windowWidth - 10)/4 - 10
    local itemX = borderX + 10
    local itemY = borderY + 10
    local itemWidth = borderWidth - 20
    local itemHeight = state.menuItemHeight

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', borderX, borderY, borderWidth, borderHeight)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font_medium)
    for i, item in ipairs(menu.list) do
        if menu == state.characterMenu
        and state.party[state.characterMenu.charID].status['SEAL']
        and i == 2 then
            love.graphics.setColor(0.25, 0.25, 0.25)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(
            item,
            itemX,
            itemY + (i - 1) * itemHeight,
            itemWidth,
            'center', 0, 1, 1, 0, -1 * (itemHeight/4)
        )
        if menu.position == i then
            drawHelper.drawMenuIndicator(
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

local function drawCharacterMenu(state)
    local leftMenu = drawLeftMenu(state, state.characterMenu)

    local borderHeight = 30
    local borderX = leftMenu.borderX
    local borderY = leftMenu.borderY - borderHeight
    local borderWidth = leftMenu.borderWidth / 2
    local nameX = borderX + 5
    local nameY = borderY + 5
    local nameWidth = borderWidth - 10

    love.graphics.setFont(font_small)
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

function drawTargetMenu(state, refX, refY, refWidth)
    local borderX = refX + refWidth + 10
    local borderY = refY
    local borderWidth = (windowWidth - 10)/4 - 10;
    local borderHeight = state.menuHeight
    local targetX = borderX + 10
    local targetY = borderY + 10
    local targetWidth = borderWidth - 10 * 2
    local targetHeight = state.menuItemHeight

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
        'line',
        borderX,
        borderY,
        borderWidth,
        borderHeight
    )

    if #state.targetMenu.list < 1 then
        love.graphics.setFont(font_medium)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
            'There is no available target.',
            targetX + 10,
            targetY,
            targetWidth - 20,
            'left', 0, 1, 1, 0, -1 * (targetHeight/4)
        )
        return
    end

    local firstPage = {}
    local secondPage = {}
    local currentPage

    for i = 1, #state.targetMenu.list, 1 do
        if i < 5 then
            table.insert(firstPage, state.targetMenu.list[i])
        else
            table.insert(secondPage, state.targetMenu.list[i])
        end
    end

    if state.targetMenu.position < 5 then
        currentPage = firstPage
    else
        currentPage = secondPage
    end

    love.graphics.setFont(font_medium)
    love.graphics.setColor(1, 1, 1)
    for i, target in ipairs(currentPage) do
        love.graphics.printf(
            target.name,
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
        if state.targetMenu.position == pointer then
            drawHelper.drawMenuIndicator(
                targetX,
                targetY + (i - 1) * targetHeight,
                targetHeight
            )
        end
    end

    if #secondPage > 0 then
        if currentPage == firstPage then
            drawHelper.drawDownwardArrow(borderX, borderY, borderWidth, borderHeight)
        else
            drawHelper.drawUpwardArrow(borderX, borderY, borderWidth, borderHeight)
        end
    end
end

function drawDescriptionText(state, x, y, data)
    local height = state.menuHeight
    local itemHeight = state.menuItemHeight
    local width = (windowWidth - 10)/4 - 10
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
        'line',
        x,
        y,
        width,
        height
    )

    local topText;
    if data.cat == 'skill' then
        topText = 'MP cost: '..data.cost..''
    elseif data.cat == 'item' then
        topText = 'Have left: '..data.amount..''
    end

    love.graphics.printf(
        topText,
        x + 20,
        y + 10,
        width - 20,
        'left', 0, 1, 1, 0, -1 * (itemHeight/4)
    )
    love.graphics.line(x, y + itemHeight + 10, x + width, y + itemHeight + 10)
    love.graphics.setFont(font_small)
    love.graphics.printf(
        data.desc,
        x + 20,
        y + itemHeight + 10,
        width - 40,
        'left', 0, 1, 1, 0, -1 * (itemHeight/4)
    )
end

local function drawCurrentMenuPage(
    state, currentPage, menu, borderX, borderY, borderWidth, borderHeight, isTargeting
)
local itemHeight = state.menuItemHeight
local pageStart = (currentPage - 1) * 8 + 1;
local pageEnd = math.min(#menu.list, pageStart + 7)
for i = pageStart, pageEnd do

    love.graphics.setFont(font_medium)
    love.graphics.setColor(1, 1, 1)
    if menu == state.skillMenu then
        local skill = actionData[menu.list[i]]
        if menu.user.currentMp < skill.cost then
            love.graphics.setColor(0.25, 0.25, 0.25)
        end
    end

    local x
    if i % 2 == 0 then
        x = borderX + borderWidth/2 + 10
    else
        x = borderX + 10
    end
    local itemPos = i - (currentPage - 1)*8
    local y = borderY + 10 + (math.floor((itemPos - 1)/2)) * itemHeight

    local name;
    if menu == state.skillMenu then
        local skill = actionData[menu.list[i]]
        name = skill.name
    elseif menu == state.itemMenu then
        name = menu.list[i].item.name
    end

    love.graphics.printf(
        name,
        x + 20,
        y,
        borderWidth/2 - 40,
        'left', 0, 1, 1, 0, -1 * (itemHeight/4)
    )

    love.graphics.setColor(1, 1, 1)
    if menu.position == i then
        drawHelper.drawMenuIndicator(x, y, itemHeight)
        if isTargeting then
            drawTargetMenu(
                state,
                borderX, 
                borderY, 
                borderWidth
            )
        else
            local data = {}
            if menu == state.skillMenu then
                local skill = actionData[menu.list[i]]
                data.cat = 'skill'
                data.desc = skill.desc
                data.cost = skill.cost
            elseif menu == state.itemMenu then
                data.cat = 'item'
                data.desc = menu.list[i].item.desc
                data.amount = menu.list[i].amount
            end

            drawDescriptionText(
                state,
                borderX + borderWidth + 10,
                borderY,
                data
            )
        end
    end

    if math.ceil(#menu.list/8) > 1 then
        if math.ceil(menu.position / 8) == 1 then
            drawHelper.drawDownwardArrow(borderX, borderY, borderWidth, borderHeight)
        elseif math.ceil(menu.position / 8) == math.ceil(#menu.list / 8) then
            drawHelper.drawUpwardArrow(borderX, borderY, borderWidth, borderHeight)
        else
            drawHelper.drawDownwardArrow(borderX, borderY, borderWidth, borderHeight)
            drawHelper.drawUpwardArrow(borderX, borderY, borderWidth, borderHeight)
        end
    end
end
end


function drawMiddleMenu(state, menu, isTargeting)
    local leftMenu = drawCharacterMenu(state)

    local borderX = leftMenu.borderX + leftMenu.borderWidth + 10
    local borderY = leftMenu.borderY
    local borderWidth = (windowWidth - 10)/2 - 10
    local borderHeight = state.menuHeight

    love.graphics.setColor(1,1,1)
    love.graphics.rectangle(
        'line',
        borderX,
        borderY,
        borderWidth,
        borderHeight
    )

    if #menu.list == 0 then
        local name = menu.user.name;
        local text;
        if menu == state.skillMenu then
            text = ''..name..' have not learned any skills'
        elseif menu == state.itemMenu then
            text = 'Party did not have any consumable items'
        end
        love.graphics.setFont(font_small)
        love.graphics.printf(
            text,
            borderX + 10,
            borderY + 10,
            borderWidth - 20,
            'left'
        )
    else        
        local currentPage = math.ceil(menu.position / 8)
        drawCurrentMenuPage(
            state, currentPage, menu, borderX, borderY, borderWidth, borderHeight, isTargeting
        )
    end
end

function battleMenu.draw(state)
    if state.currentMenu == state.mainMenu then
        drawLeftMenu(state, state.mainMenu)
    elseif state.currentMenu == state.characterMenu then
        drawCharacterMenu(state)
    elseif state.currentMenu == state.targetMenu then
        if state.targetMenu.prevMenu == state.characterMenu then
            local leftMenu = drawCharacterMenu(state)
            drawTargetMenu(state, leftMenu.borderX, leftMenu.borderY, leftMenu.borderWidth)
        elseif state.targetMenu.prevMenu == state.skillMenu then
            drawMiddleMenu(state, state.skillMenu, true)
        elseif state.targetMenu.prevMenu == state.itemMenu then
            drawMiddleMenu(state, state.itemMenu, true)
        end
    elseif state.currentMenu == state.skillMenu then
        drawMiddleMenu(state, state.skillMenu, false)
    elseif state.currentMenu == state.itemMenu then
        drawMiddleMenu(state, state.itemMenu, false)
    end
end

function battleMenu.menuReset(menu)
    menu.position = 1
end

function battleMenu.menuUp(menu)
    menu.position = menu.position - 1
end

function battleMenu.menuDown(menu)
    menu.position = menu.position + 1
end

function battleMenu.updateTargetMenu(state, prevMenu, group)
    local targetList = {}
    for i, target in ipairs(group) do
        if not target.isDead then
            table.insert(targetList, target)
        end
    end
    state.targetMenu.list = targetList
    state.targetMenu.prevMenu = prevMenu
end

function battleMenu.updateSkillMenu(state , user)
    local skillList = {}
    if user.skills and #user.skills > 0 then
        for _, skill in ipairs(user.skills) do
            table.insert(skillList, skill)
        end
    end
    state.skillMenu.user = user
    state.skillMenu.list = skillList
end

function battleMenu.updateItemMenu(state, user)
    local itemList = {}
    for k, v in pairs(gameState.partyItems) do
        table.insert(itemList, {item = v.item, amount = v.amount })
    end

    table.sort(itemList, function(a, b) return a.item.id < b.item.id end)
    state.itemMenu.user = user
    state.itemMenu.list = itemList
end

function battleMenu.updateDeadTargetMenu(state, prevMenu, group)
    local targetList = {}
    for _, target in ipairs(group) do
        if target.isDead then
            table.insert(targetList, target)
        end
    end
    state.targetMenu.list = targetList
    state.targetMenu.prevMenu = prevMenu
end

return battleMenu