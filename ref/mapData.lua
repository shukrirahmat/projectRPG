local mapData = {}

mapData['worldMap'] = {
    size = { x = 15, y = 7 },
    startPos = { x = 8, y = 4 },
    floor = { r = 0.6, g = 0.9, b = 0.6 },
    
    spots = {
        ['2,2'] = { x = 2 , y = 2 , category = 'gates', to = 'stage_1'}
    }
}

mapData['stage_1'] = {
    size = { x = 11, y = 11 },
    startPos = { x = 6, y = 10 },
    floor = { r = 0.89, g = 0.13, b = 0.09 },
    encounterRate = 1000,
    encounters = {'slime', 'slime', 'slime', 'goblin'},
    maxEncounter = 1,
    
    spots = {
        ['6,10'] = { x = 6 , y = 10 , category = 'gates', to = 'worldMap'}
    }
}

return mapData