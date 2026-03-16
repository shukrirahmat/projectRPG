local gameState = require('gameState')

local battleLog = {}

function battleLog.showEncounterMessage(state, dt)
    state.actionTimer = state.actionTimer + dt
    if state.actionTimer < state.actionSpeed then
        state.battleLog = state.encounterMessage
    elseif state.actionTimer >= state.actionSpeed then
        state.battleLog = {}
        state.encounterMessage = nil
    end
end

function battleLog.addText(state, text)
    if #state.battleLog >= 4 then
        table.remove(state.battleLog, 1)
    end

    table.insert(state.battleLog, text)
end

function battleLog.draw(state)
    local borderX = 20
    local borderHeight = gameState.textHeight
    local borderY = windowHeight - borderHeight - 20
    local borderWidth = windowWidth - borderX * 2

    local textX = borderX + 20
    local textY = borderY + 10
    local textLineHeight = 25
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
            textY + (index - 1) * textLineHeight,
            textWidth
        )
    end
end

return battleLog