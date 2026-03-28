local gates = require('graphics.gates')
local tiles = require('graphics.tiles')


local graphics = {}

function graphics.load()
    gates.load()
    tiles.load()
end

return graphics