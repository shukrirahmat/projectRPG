local renderer = {}

function renderer.center_text(line_height)   
    local font = love.graphics.getFont()
    local textHeight = font:getHeight()
    return (line_height - textHeight) * 0.5    
end

function renderer.draw_option_cursor(x, y, height)
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

function renderer.draw_downward_arrow(x, y, width, height, ratio)
    local size = ratio or 1
    
    love.graphics.polygon(
        'fill',
        x + width/2 - 10 * size,
        y + height - 10 * size,
        x + width/2 + 10 * size,
        y + height - 10 * size,
        x + width/2,
        y + height - 5 * size
    )
end

function renderer.draw_upward_arrow(x, y, width, height, ratio)
    local size = ratio or 1
    
    love.graphics.polygon(
        'fill',
        x + width/2 - 10 * size,
        y + 10 * size,
        x + width/2 + 10 * size,
        y + 10 * size,
        x + width/2,
        y + 5 * size
    )
end

return renderer