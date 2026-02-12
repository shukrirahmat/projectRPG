local state = {}

state.party = {}
state.enemies = {}
state.mainMenu = {position = 1, list = {'FIGHT', 'FLEE'}}
state.characterMenu = {position = 1, list = {'ATTACK', 'SKILL', 'DEFEND', 'ITEM'}, charID = 1}
state.targetMenu = {position = 1}
state.skillMenu = {position = 1}
state.currentMenu = state.mainMenu
state.battleRunning = false
state.actionList = {}
state.priorityList = {}
state.effectList = {}
state.killList = {}
state.textTimer = 0
state.textSpeed = 1
state.battleLog = {}
state.bottomHeight = 180
state.partyDied = false
state.allEnemyDead = false
state.battleEnded = false
state.animation = nil
state.infoMode = false
state.cursorTimer = 0
state.cursor = false

return state;