local drawHelper = {}


function drawHelper.drawMenuIndicator(x, y, height)
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

function drawHelper.drawDownwardArrow(x, y, width, height)
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

function drawHelper.drawUpwardArrow(x, y, width, height)
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

function drawHelper.centeredText(ref)
    local font = love.graphics.getFont()
    local textHeight = font:getHeight()
    return (ref - textHeight) * 0.5
end

return drawHelper;