local ui = {}

local sprites = {}

function ui.load()
    sprites['status_icons'] = love.graphics.newImage('assets/images/status_Icons.png')
    sprites['BLIND'] = love.graphics.newQuad(0, 0, 16, 16, 128, 32)
    sprites['SEAL'] = love.graphics.newQuad(16, 0, 16, 16, 128, 32)
    sprites['POISON'] = love.graphics.newQuad(32, 0, 16, 16, 128, 32)
    sprites['WOUND'] = love.graphics.newQuad(48, 0, 16, 16, 128, 32)
    sprites['CURSE'] = love.graphics.newQuad(64, 0, 16, 16, 128, 32)
    sprites['STUN'] = love.graphics.newQuad(80, 0, 16, 16, 128, 32)
    sprites['SLEEP'] = love.graphics.newQuad(96, 0, 16, 16, 128, 32)
    sprites['CONFUSE'] = love.graphics.newQuad(112, 0, 16, 16, 128, 32)
    sprites['PARALYSIS'] = love.graphics.newQuad(0, 16, 16, 16, 128, 32)
    sprites['STEEL'] = love.graphics.newQuad(16, 16, 16, 16, 128, 32)
    sprites['FRAIL'] = love.graphics.newQuad(32, 16, 16, 16, 128, 32)
    sprites['HASTE'] = love.graphics.newQuad(48, 16, 16, 16, 128, 32)
    sprites['SLOW'] = love.graphics.newQuad(64, 16, 16, 16, 128, 32)
    sprites['MIGHT'] = love.graphics.newQuad(80, 16, 16, 16, 128, 32)
    sprites['BARRIER'] = love.graphics.newQuad(96, 16, 16, 16, 128, 32)
end

function ui.get_sprite(id)
    return sprites[id]
end

return ui