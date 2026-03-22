local drawHelper = require('utils.drawHelper')
local actionData = require('data.actionData')

local skillMenu = {}

local state = {}

local function moveUp()
    if state.position - 2 >= 1 then
        state.position = state.position - 2
    end
end

local function moveDown()
    if state.position + 2 <= #state.list then
        state.position = state.position + 2
    elseif state.position + 1 == #state.list then
        state.position = state.position + 1
    end
end

local function moveLeft()
    if state.position % 2 == 0 and state.position - 1 >= 1 then
        state.position = state.position - 1
    end
end

local function moveRight()
    if state.position % 2 ~= 0 and state.position + 1 <= #state.list then
        state.position = state.position + 1
    end
end

local function back()
    state.menu.switch(state.prevMenu)
end

local function drawDescriptionText(skill)
    local x = state.borderX + state.borderWidth + state.gap
    local y = windowHeight - state.marginY - state.height
    local width = (state.width - state.gap * 2) / 4
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
        'line',
        x,
        y,
        width,
        state.height
    )

    local header = 'MP cost: '..skill.cost..''
    love.graphics.printf(
        header,
        x + state.paddingX,
        y + state.paddingY + drawHelper.centeredText(state.itemHeight),
        width - state.paddingX * 2
    )
    love.graphics.line(
        x, y + state.itemHeight + state.paddingY * 1.5, 
        x + width, y + state.itemHeight + state.paddingY * 1.5)
    love.graphics.setFont(font_large)
    love.graphics.printf(
        skill.desc,
        x + state.paddingX,
        y + state.itemHeight + state.paddingY * 2 + drawHelper.centeredText(state.itemHeight),
        width - state.paddingX * 2
    )
end

function skillMenu.load(menu, menuState)
    state.menu = menu
    state.height = menuState.height
    state.itemHeight = menuState.itemHeight
    state.marginX = menuState.marginX
    state.marginY = menuState.marginY
    state.width = menuState.width
    state.gap = menuState.gap
    state.paddingX = menuState.paddingX
    state.paddingY = menuState.paddingY
    state.borderX = 0
    state.borderWidth = (state.width - state.gap * 2) / 2
    state.size = 8
    
    state.party = menuState.party
    state.enemies = menuState.enemies

    state.position = 1
    state.list = {}
    state.prevMenu = nil
    state.battler = nil
end

function skillMenu.reset()
    state.position = 1
end

function skillMenu.setup(prevMenu)
    state.list = {}
    state.prevMenu = prevMenu
    state.battler = prevMenu.currentBattler()

    if state.battler.skills and #state.battler.skills > 0 then
        for i, skill in ipairs(state.battler.skills) do
            table.insert(state.list, skill)
        end
    end
    state.borderX = state.marginX + prevMenu.getWidth() + state.gap
end

function skillMenu.getWidth()
    return state.borderWidth
end

function skillMenu.keypressed(key)
    if key == 'up' then
        moveUp()
    elseif key == 'down' then
        moveDown()
    elseif key == 'left' then
        moveLeft()
    elseif key == 'right' then
        moveRight()
    elseif key == 'z' then
        confirm()
    elseif key == 'x' then
        back()
    end
end

function skillMenu.draw(isTargeting)
    state.prevMenu.draw()

    local borderX = state.borderX
    local borderY = windowHeight - state.marginY - state.height
    local borderWidth = state.borderWidth
    local borderHeight = state.height
    local itemX = borderX + state.paddingX
    local itemY = borderY + state.paddingY
    local itemWidth = (borderWidth / 2) - state.paddingY * 2
    local itemHeight = state.itemHeight
    local cursorSpace = 20

    love.graphics.setColor(1,1,1)
    love.graphics.rectangle(
        'line',
        borderX,
        borderY,
        borderWidth,
        borderHeight
    )

    if #state.list == 0 then
        local name = state.battler.name
        local text =''..name..' have not learned any skills.'
        love.graphics.setFont(font_large)
        love.graphics.printf(
            text,
            itemX,
            itemY + drawHelper.centeredText(itemHeight),
            itemWidth,
            'left'
        )
        return
    end

    local currentPage = math.ceil(state.position / state.size)
    local pageStart = (currentPage - 1) * state.size + 1;
    local pageEnd = math.min(#state.list, pageStart + state.size - 1)

    for i = pageStart, pageEnd do
        love.graphics.setFont(font_large)
        love.graphics.setColor(1, 1, 1)

        local skill = actionData[state.list[i]]
        if state.battler.currentMp < skill.cost then
            love.graphics.setColor(0.25, 0.25, 0.25)
        end

        local skillX = borderX + state.paddingX
        if i % 2 == 0 then
            skillX = skillX + borderWidth / 2
        end
        local skillPos = math.ceil((((i - 1) % state.size) + 1) / 2)
        local skillY = borderY + state.paddingY + (skillPos - 1) * itemHeight

        love.graphics.printf(
            skill.name,
            skillX + cursorSpace,
            skillY + drawHelper.centeredText(itemHeight),
            itemWidth
        )

        love.graphics.setColor(1, 1, 1)
        if state.position == i then
            drawHelper.drawMenuIndicator(skillX, skillY, itemHeight)
            if not isTargeting then
                drawDescriptionText(skill)
            end
        end

        if math.ceil(#state.list / state.size) > 1 then
            if math.ceil(state.position / state.size) == 1 then
                drawHelper.drawDownwardArrow(borderX, borderY, borderWidth, borderHeight)
            elseif math.ceil(state.position / state.size) == math.ceil(#state.list / state.size) then
                drawHelper.drawUpwardArrow(borderX, borderY, borderWidth, borderHeight)
            else
                drawHelper.drawDownwardArrow(borderX, borderY, borderWidth, borderHeight)
                drawHelper.drawUpwardArrow(borderX, borderY, borderWidth, borderHeight)
            end
        end
    end
end

return skillMenu