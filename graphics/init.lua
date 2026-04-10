local gates = require('graphics.gates')
local tiles = require('graphics.tiles')
local player_sprites = require('graphics.player_sprites')
local party_sprites = require('graphics.party_sprites')
local enemy_sprites = require('graphics.enemy_sprites')
local ui = require('graphics.ui')


local graphics = {}

function graphics.load()
    gates.load()
    tiles.load()
    player_sprites.load()
    party_sprites.load()
    enemy_sprites.load()
    ui.load()
end

return graphics