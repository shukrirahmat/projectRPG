local gates = {}

local sprites = {}

function gates.load()
    sprites[1] = love.graphics.newImage('assets/images/gate_1.png')
end

function gates.get_gate(id)
    return sprites[id]
end
    

return gates