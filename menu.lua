local battleState = require('battleState')
local actionData = require('actionData')
local utils = require('utils')

local menu = {}

local height = battleState.bottomHeight
local itemHeight = (height - 20)/4

local function drawLeftMenu(m)
    local borderHeight = height
    local borderX = 10
    local borderY = windowHeight - borderHeight - 10
    local borderWidth = (windowWidth - 10)/4 - 10
    local itemX = borderX + 10
    local itemY = borderY + 10
    local itemWidth = borderWidth - 20
    local itemHeight = itemHeight

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
        'line',
        borderX,
        borderY,
        borderWidth,
        borderHeight
    )

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font_medium)
    for i, item in ipairs(m.list) do
        if m == battleState.characterMenu
        and battleState.party[battleState.characterMenu.charID].status['SEAL']
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
        if m.position == i then
            drawMenuIndicator(
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

local function drawCharacterMenu()
    local leftMenu = drawLeftMenu(battleState.characterMenu)

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


    local id = battleState.characterMenu.charID
    local charName = battleState.party[id].name
    love.graphics.printf(
        charName,
        nameX,
        nameY,
        nameWidth,
        'center'
    )

    return leftMenu;
end

local function drawDownwardArrow(x, y, width, height)
    love.graphics.polygon(
        'fill',
        x + width/2 - 10,
        y + height - 10,
        x + width/2 + 10,
        y + height - 10,
        x + width/2,
        y + height - 5
    )
end

local function drawUpwardArrow(x, y, width, height)
    love.graphics.polygon(
        'fill',
        x + width/2 - 10,
        y + 10,
        x + width/2 + 10,
        y + 10,
        x + width/2,
        y + 5
    )
end


function drawTargetMenu(refX, refY, refWidth)
    local borderX = refX + refWidth + 10
    local borderY = refY
    local borderWidth = (windowWidth - 10)/4 - 10;
    local borderHeight = height
    local targetX = borderX + 10
    local targetY = borderY + 10
    local targetWidth = borderWidth - 10 * 2
    local targetHeight = itemHeight

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
        'line',
        borderX,
        borderY,
        borderWidth,
        borderHeight
    )

    if #battleState.targetMenu.list < 1 then
        love.graphics.setFont(font_medium)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
            'There is no available target',
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

    for i = 1, #battleState.targetMenu.list, 1 do
        if i < 5 then
            table.insert(firstPage, battleState.targetMenu.list[i])
        else
            table.insert(secondPage, battleState.targetMenu.list[i])
        end
    end

    if battleState.targetMenu.position < 5 then
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
        if battleState.targetMenu.position == pointer then
            drawMenuIndicator(
                targetX,
                targetY + (i - 1) * targetHeight,
                targetHeight
            )
        end
    end

    if #secondPage > 0 then
        if currentPage == firstPage then
            drawDownwardArrow(borderX, borderY, borderWidth, borderHeight)
        else
            drawUpwardArrow(borderX, borderY, borderWidth, borderHeight)
        end
    end
end

function drawDescriptionText(x, y, data)
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
    currentPage, menu, borderX, borderY, borderWidth, borderHeight, isTargeting
    )
    local pageStart = (currentPage - 1) * 8 + 1;
    local pageEnd = math.min(#menu.list, pageStart + 7)
    for i = pageStart, pageEnd do

        love.graphics.setFont(font_medium)
        love.graphics.setColor(1, 1, 1)
        if menu == battleState.skillMenu then
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
        if menu == battleState.skillMenu then
            local skill = actionData[menu.list[i]]
            name = skill.name
        elseif menu == battleState.itemMenu then
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
            drawMenuIndicator(x, y, itemHeight)
            if isTargeting then
                drawTargetMenu(
                    borderX, 
                    borderY, 
                    borderWidth
                )
            else
                local data = {}
                if menu == battleState.skillMenu then
                    local skill = actionData[menu.list[i]]
                    data.cat = 'skill'
                    data.desc = skill.desc
                    data.cost = skill.cost
                elseif menu == battleState.itemMenu then
                    data.cat = 'item'
                    data.desc = menu.list[i].item.desc
                    data.amount = menu.list[i].amount
                end

                drawDescriptionText(
                    borderX + borderWidth + 10,
                    borderY,
                    data
                )
            end
        end
        
        if math.ceil(#menu.list/8) > 1 then
            if math.ceil(menu.position / 8) == 1 then
                drawDownwardArrow(borderX, borderY, borderWidth, borderHeight)
            elseif math.ceil(menu.position / 8) == math.ceil(#menu.list / 8) then
                drawUpwardArrow(borderX, borderY, borderWidth, borderHeight)
            else
                drawDownwardArrow(borderX, borderY, borderWidth, borderHeight)
                drawUpwardArrow(borderX, borderY, borderWidth, borderHeight)
            end
        end
    end
end


function drawMiddleMenu(menu, isTargeting)
    local leftMenu = drawCharacterMenu()

    local borderX = leftMenu.borderX + leftMenu.borderWidth + 10
    local borderY = leftMenu.borderY
    local borderWidth = (windowWidth - 10)/2 - 10
    local borderHeight = height

    love.graphics.setColor(1,1,1)
    love.graphics.rectangle(
        'line',
        borderX,
        borderY,
        borderWidth,
        borderHeight
    )

    if #menu.list == 0 then
        local name = menu.user;
        local text;
        if menu == battleState.skillMenu then
            text = ''..name..' have not learned any skills'
        elseif menu == battleState.itemMenu then
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
        drawCurrentMenuPage(currentPage, menu, borderX, borderY, borderWidth, borderHeight, isTargeting)
    end
end

function menu.drawBattleLog()
    local borderX = 10
    local borderHeight = height
    local borderY = windowHeight - borderHeight - 10
    local borderWidth = windowWidth - borderX * 2

    local textX = borderX + 20
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

    love.graphics.setFont(font_text)
    for index, text in ipairs(battleState.battleLog) do
        love.graphics.printf(
            text,
            textX,
            textY + (index - 1)*textLineHeight,
            textWidth
        )
    end
end

function menu.draw()
    if battleState.currentMenu == battleState.mainMenu then
        drawLeftMenu(battleState.mainMenu)
    elseif battleState.currentMenu == battleState.characterMenu then
        drawCharacterMenu()
    elseif battleState.currentMenu == battleState.targetMenu then
        if battleState.targetMenu.prevMenu == battleState.characterMenu then
            local leftMenu = drawCharacterMenu()
            drawTargetMenu(leftMenu.borderX, leftMenu.borderY, leftMenu.borderWidth)
        elseif battleState.targetMenu.prevMenu == battleState.skillMenu then
            drawMiddleMenu(battleState.skillMenu, true)
        elseif battleState.targetMenu.prevMenu == battleState.itemMenu then
            drawMiddleMenu(battleState.itemMenu, true)
        end
    elseif battleState.currentMenu == battleState.skillMenu then
        drawMiddleMenu(battleState.skillMenu, false)
    elseif battleState.currentMenu == battleState.itemMenu then
        drawMiddleMenu(battleState.itemMenu, false)
    end
end

return menu