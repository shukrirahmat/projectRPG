local overworld = {}

overworld.size = { x = 15, y = 7 }
overworld.startPos = { x = 8, y = 4 }
overworld.floor = { r = 0.6, g = 0.9, b = 0.6 }

overworld.spots = {
    ['2,2'] = { x = 2 , y = 2 , category = 'gates', to = 'stage_1'}
}

return overworld;