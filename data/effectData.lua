local effects = require('systems.effects')

local effectData = {}

effectData['damage'] = { 
    apply = effects.dealDamage , 
    partyAnimation = {ref ='partyDamaged', speed = 0.6},
    enemyAnimation = {ref ='enemyDamaged', speed = 1}
}

effectData['resisted'] = { 
    apply = effects.dealDamage , 
    partyAnimation = {ref ='partyDamaged', speed = 0.6},
    enemyAnimation = {ref ='enemyResisted', speed = 1}
}
effectData['immune'] = { 
    apply = effects.noEffect , 
    enemyAnimation = {ref ='enemyImmune', speed = 1}
}

effectData['nothing'] = { 
    apply = effects.nothingHappens
}

effectData['skillCanceled'] = { 
    apply = effects.skillCanceled , 
}

effectData['recover'] = {
    apply = effects.recovery,
}

effectData['mpRecover'] = {
    apply = mpRecovery,
}

effectData['revive'] = {
    apply = revival,
}

effectData['mpDamage'] = {
    apply = effects.dealMPDamage,
    enemyAnimation = {ref ='enemyManaBurned', speed = 1}
}

effectData['mpResisted'] = {
    apply = effects.dealMPDamage,
    enemyAnimation = {ref ='enemyManaBurned', speed = 1}
}

effectData['instakill'] = { 
    apply = effects.instakill , 
}

effectData['missed'] = { 
    apply = effects.missed , 
    enemyAnimation = {ref ='enemyDodged', speed = 1}
}

effectData['missedResist'] = { 
    apply = effects.missed , 
    enemyAnimation = {ref ='enemyDodgedResist', speed = 1}
}

effectData['addStatus'] = { 
    apply = effects.addStatus,
}

effectData['addStatChange'] = { 
    apply = effects.addStatChange,
}

effectData['clearStatus'] = {
    apply = effects.clearStatus,
}

effectData['poisonDamage'] = { 
    apply = effects.poisonDamage , 
    partyAnimation = {ref ='partyDamaged', speed = 0.6},
    enemyAnimation = {ref ='enemyDamaged', speed = 1}
}

effectData['curseEffect'] = { 
    apply = effects.curseEffect,
}

effectData['stealGold'] = { 
    apply = effects.stealGold,
}

effectData['stealItem'] = { 
    apply = effects.stealItem,
}

return effectData