local stage_1 = {}

stage_1.name = 'stage 1'
stage_1.width = 11
stage_1.height = 11
stage_1.start_position = { x = 6, y = 10 }
stage_1.tiles = {
    { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2}
}
stage_1.events =  {
    ['6,10'] = {type = 'gate', spriteID = 1, to = 'overworld'}
}
stage_1.has_encounter = true
stage_1.encounter_chance = 200
stage_1.encounter_pool = {'goblin', 'goblin', 'goblin', 'skeleton'}
stage_1.encounter_max = 2



return stage_1