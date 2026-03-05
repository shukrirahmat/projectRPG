local battleState = {}

battleState.party = {}
battleState.enemies = {}
battleState.mainMenu = {position = 1, list = {'FIGHT', 'FLEE'}}
battleState.characterMenu = {position = 1, list = {'ATTACK', 'SKILL', 'DEFEND', 'ITEM'}, charID = 1}
battleState.targetMenu = {position = 1}
battleState.skillMenu = {position = 1}
battleState.itemMenu = {position = 1}
battleState.currentMenu = battleState.mainMenu
battleState.battleRunning = false
battleState.actionList = {}
battleState.priorityList = {}
battleState.effectList = {}
battleState.killList = {}
battleState.followUp = {}
battleState.textTimer = 0
battleState.textSpeed = 1
battleState.battleLog = {'Enemy encountered!'}
battleState.bottomHeight = 180
battleState.partyDied = false
battleState.allEnemyDead = false
battleState.battleEnded = false
battleState.animation = nil
battleState.infoMode = false
battleState.encounterMessage = true;

return battleState;