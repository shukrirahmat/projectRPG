local gates = require('graphics.gates')
local tiles = require('graphics.tiles')
local player_sprites = require('graphics.player_sprites')


local graphics = {}

function graphics.load()
    gates.load()
    tiles.load()
    player_sprites.load()
end

return graphics