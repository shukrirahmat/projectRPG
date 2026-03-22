local drawHelper = require('utils.drawHelper')

local battlerMenu = {}

local state = {}

local function moveUp()
    if state.position > 1 then
        state.position = state.position - 1
    end
end

local function moveDown()
    if state.position < #state.list then
        state.position = state.position + 1
    end
end

local function confirm()
    if state.position == 1 then
        state.menu.normalAttack()
    elseif state.position == 2 and not battlerMenu.currentBattler().status['SEAL'] then
        state.menu.openSkill()
    end
end

local function back()
    state.menu.previousBattler()
end

function battlerMenu.load(menu, menuState)
    state.menu = menu
    state.height = menuState.height
    state.itemHeight = menuState.itemHeight
    state.marginX = menuState.marginX
    state.marginY = menuState.marginY
    state.width = menuState.width
    state.gap = menuState.gap
    state.paddingX = menuState.paddingX
    state.paddingY = menuState.paddingY
    
    state.borderWidth = (state.width - state.gap * 2) / 4
    
    state.party = menuState.party
    state.position = 1
    state.list = {'ATTACK', 'SKILL', 'DEFEND', 'ITEM'}
    state.battlerIndex = 1
    state.spriteRatio = 0.75
    state.spriteHeight = monsterSpriteDimension * state.spriteRatio
    state.spriteWidth = state.spriteHeight
end

function battlerMenu.setBattler(index)
    state.battlerIndex = index
end

function battlerMenu.currentBattler()
    return state.party[state.battlerIndex]
end

function battlerMenu.reset()
    state.position = 1
end

function battlerMenu.getIndex()
    return state.battlerIndex
end

function battlerMenu.getWidth()
    return state.borderWidth
end

function battlerMenu.keypressed(key)
    if key == 'up' then
        moveUp()
    elseif key == 'down' then
        moveDown()
    elseif key == 'z' then
        confirm()
    elseif key == 'x' then
        back()
    end
end

function battlerMenu.draw()
    local borderHeight = state.height
    local borderX = state.marginX
    local borderY = windowHeight - borderHeight - state.marginY
    local borderWidth = state.borderWidth
    local itemX = borderX + state.paddingX
    local itemY = borderY + state.paddingY
    local itemWidth = borderWidth - state.paddingX * 2
    local itemHeight = state.itemHeight

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', borderX, borderY, borderWidth, borderHeight)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font_large)
    for i, item in ipairs(state.list) do
        
        if i == 2 and battlerMenu.currentBattler().status['SEAL'] then
            love.graphics.setColor(0.25, 0.25, 0.25)
        end
        
        love.graphics.printf(
            item,
            itemX,
            itemY + drawHelper.centeredText(itemHeight) + (i - 1) * itemHeight,
            itemWidth,
            'center'
        )
        
        love.graphics.setColor(1, 1, 1)
        if state.position == i then
            drawHelper.drawMenuIndicator(
                itemX,
                itemY + (i - 1) * itemHeight,
                itemHeight
            )
        end
    end
    
    local spriteX = borderX
    local spriteY = borderY - state.spriteHeight

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle(
        'fill',
        spriteX,
        spriteY,
        state.spriteWidth,
        state.spriteHeight
    )
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
        'line',
        spriteX,
        spriteY,
        state.spriteWidth,
        state.spriteHeight
    )
    
    love.graphics.draw(
        battlerMenu.currentBattler().sprite,
        spriteX,
        spriteY - 1,
        0,
        state.spriteRatio,
        state.spriteRatio
    )
end

return battlerMenu