local stage_1 = {}

stage_1.size = { x = 11, y = 11 }
stage_1.startPos = { x = 6, y = 10 }
stage_1.floor = { r = 0.89, g = 0.13, b = 0.09 }
stage_1.encounterRate = 100
stage_1.encounters = {'slime', 'slime', 'slime', 'goblin'}
stage_1.maxEncounter = 4
stage_1.spots =
{
    ['6,10'] = { x = 6 , y = 10 , category = 'gates', to = 'overworld'}
}

return stage_1;