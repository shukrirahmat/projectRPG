local state = {}

state.party = {}
state.enemies = {}
state.mainMenu = {position = 1, list = {'FIGHT', 'FLEE'}}
state.characterMenu = {position = 1, list = {'ATTACK', 'SKILL', 'GUARD', 'ITEM'}, charID = 1}
state.currentMenu = state.mainMenu
state.battleRunning = false

return state;