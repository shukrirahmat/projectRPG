local state = require('state')
local actionData = require('actionData')

local menu = {}

local height = state.bottomHeight
local itemHeight = (height - 20)/4

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
    local leftMenu = drawLeftMenu(state.characterMenu)

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

function drawDescriptionText(x, y, skill)
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
        'left', 0, 1, 1, 0, -1 * (itemHeight/4)
    )
    love.graphics.line(x, y + itemHeight + 10, x + width, y + itemHeight + 10)
    love.graphics.setFont(font_small)
    love.graphics.printf(
        skill.desc,
        x + 20,
        y + itemHeight + 10,
        width - 40,
        'left', 0, 1, 1, 0, -1 * (itemHeight/4)
    )
end

function drawSkillMenu(isTargeting)
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

    if #state.skillMenu.list == 0 then
        local name = state.skillMenu.user.name
        love.graphics.setFont(font_small)
        love.graphics.printf(
            ''..name..' have not learned any skills',
            borderX + 10,
            borderY + 10,
            borderWidth - 20,
            'left'
        )
    else
        for index, ref in ipairs(state.skillMenu.list) do
            love.graphics.setFont(font_medium)
            local skill = actionData[ref]
            if state.skillMenu.user.currentMp < skill.cost then
                love.graphics.setColor(0.25, 0.25, 0.25)
            else
                love.graphics.setColor(1,1,1)
            end

            local x
            if index % 2 == 0 then
                x = borderX + borderWidth/2 + 10
            else
                x = borderX + 10
            end
            local y = borderY + 10 + (math.floor((index - 1)/2)) * itemHeight

            love.graphics.printf(
                skill.name,
                x + 20,
                y,
                borderWidth/2 - 40,
                'left', 0, 1, 1, 0, -1 * (itemHeight/4)
            )

            if state.skillMenu.position == index then
                drawMenuIndicator(x, y, itemHeight)
                if isTargeting then
                    drawTargetMenu(
                        borderX, 
                        borderY, 
                        borderWidth
                    )
                else 
                    drawDescriptionText(
                        borderX + borderWidth + 10,
                        borderY,
                        skill
                    )
                end
            end
        end

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
    for index, text in ipairs(state.battleLog) do
        love.graphics.printf(
            text,
            textX,
            textY + (index - 1)*textLineHeight,
            textWidth
        )
    end
end

function menu.draw()
    if state.currentMenu == state.mainMenu then
        drawLeftMenu(state.mainMenu)
    elseif state.currentMenu == state.characterMenu then
        drawCharacterMenu()
    elseif state.currentMenu == state.targetMenu then
        if state.targetMenu.prevMenu == state.characterMenu then
            local leftMenu = drawCharacterMenu()
            drawTargetMenu(leftMenu.borderX, leftMenu.borderY, leftMenu.borderWidth)
        elseif state.targetMenu.prevMenu == state.skillMenu then
            drawSkillMenu(true)
        end
    elseif state.currentMenu == state.skillMenu then
        drawSkillMenu(false)
    end
end

return menu