local effects = require('systems.effects')

local effectData = {}

effectData['damage'] = { 
    apply = effects.dealDamage , 
    partyAnimation = {ref ='partyDamaged', speed = 0.75},
    enemyAnimation = {ref ='enemyDamaged', speed = 1}
}

effectData['resisted'] = { 
    apply = effects.dealDamage , 
    partyAnimation = {ref ='partyDamaged', speed = 0.75},
    enemyAnimation = {ref ='enemyResisted', speed = 1}
}
effectData['immune'] = { 
    apply = effects.noEffect , 
    enemyAnimation = {ref ='enemyImmune', speed = 1}
}

effectData['skillCanceled'] = { 
    apply = skillCanceled , 
}

effectData['recover'] = {
    apply = recovery,
}

effectData['mpRecover'] = {
    apply = mpRecovery,
}

effectData['revive'] = {
    apply = revival,
}

effectData['mpDamage'] = {
    apply = dealMPDamage,
    enemyAnimation = {ref ='enemyManaBurned', speed = 1}
}

effectData['mpResisted'] = {
    apply = dealMPDamage,
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
    apply = missed , 
    enemyAnimation = {ref ='enemyDodgedResist', speed = 1}
}

effectData['addStatus'] = { 
    apply = effects.addStatus,
}

effectData['addStatChange'] = { 
    apply = addStatChange,
}

effectData['clearStatus'] = {
    apply = effects.clearStatus,
}

effectData['poisonDamage'] = { 
    apply = poisonDamage , 
    partyAnimation = {ref ='partyDamaged', speed = 0.75},
    enemyAnimation = {ref ='enemyDamaged', speed = 1}
}

effectData['curseEffect'] = { 
    apply = curseEffect,
}

effectData['stealGold'] = { 
    apply = effects.stealGold,
}

effectData['stealItem'] = { 
    apply = effects.stealItem,
}

return effectData