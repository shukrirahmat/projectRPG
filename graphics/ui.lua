local ui = {}

local sprites = {}

function ui.load()
    sprites['status_icons'] = love.graphics.newImage('assets/images/status_icons.png')
    sprites['BLIND'] = love.graphics.newQuad(0, 0, 16, 16, 128, 48)
    sprites['SEAL'] = love.graphics.newQuad(16, 0, 16, 16, 128, 48)
    sprites['POISON'] = love.graphics.newQuad(32, 0, 16, 16, 128, 48)
    sprites['WOUND'] = love.graphics.newQuad(48, 0, 16, 16, 128, 48)
    sprites['CURSE'] = love.graphics.newQuad(64, 0, 16, 16, 128, 48)
    sprites['STUN'] = love.graphics.newQuad(80, 0, 16, 16, 128, 48)
    sprites['SLEEP'] = love.graphics.newQuad(96, 0, 16, 16, 128, 48)
    sprites['CONFUSE'] = love.graphics.newQuad(112, 0, 16, 16, 128, 48)
    sprites['PARALYSIS'] = love.graphics.newQuad(0, 16, 16, 16, 128, 48)
    sprites['STEEL'] = love.graphics.newQuad(16, 16, 16, 16, 128, 48)
    sprites['FRAIL'] = love.graphics.newQuad(32, 16, 16, 16, 128, 48)
    sprites['HASTE'] = love.graphics.newQuad(48, 16, 16, 16, 128, 48)
    sprites['SLOW'] = love.graphics.newQuad(64, 16, 16, 16, 128, 48)
    sprites['MIGHT'] = love.graphics.newQuad(80, 16, 16, 16, 128, 48)
    sprites['BARRIER'] = love.graphics.newQuad(96, 16, 16, 16, 128, 48)
    sprites['STEEL2'] = love.graphics.newQuad(112, 16, 16, 16, 128, 48)
    sprites['FRAIL2'] = love.graphics.newQuad(0, 32, 16, 16, 128, 48)
    sprites['HASTE2'] = love.graphics.newQuad(16, 32, 16, 16, 128, 48)
    sprites['SLOW2'] = love.graphics.newQuad(32, 32, 16, 16, 128, 48)
    sprites['RESILIENT'] = love.graphics.newQuad(48, 32, 16, 16, 128, 48)
    sprites['VAMPIRISM'] = love.graphics.newQuad(64, 32, 16, 16, 128, 48)
end

function ui.get_sprite(id)
    return sprites[id]
end

return ui