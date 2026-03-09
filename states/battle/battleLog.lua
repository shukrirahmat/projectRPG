local battleLog = {}

function battleLog.showEncounterMessage(state, dt)
    state.textTimer = state.textTimer + dt
    if state.textTimer < state.textSpeed then
        state.battleLog = state.encounterMessage
    elseif state.textTimer >= state.textSpeed then
        state.battleLog = {}
        state.encounterMessage = nil
    end
end

function battleLog.draw(state)
    local borderX = 10
    local borderHeight = state.menuHeight
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
            textY + (index - 1) * textLineHeight,
            textWidth
        )
    end
end

return battleLog