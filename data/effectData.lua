local effects = require('systems.effects')

local effectData = {}

effectData['damage'] = { 
    apply = effects.dealDamage , 
    partyAnimation = 'partyDamaged',
    enemyAnimation = 'enemyDamaged',
}

effectData['resisted'] = { 
    apply = dealDamage , 
    partyAnimation = 'partyDamaged',
    enemyAnimation = 'enemyResisted',
}
effectData['immune'] = { 
    apply = noEffect , 
    enemyAnimation = 'enemyImmune',
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
    enemyAnimation = 'enemyManaBurned',
}

effectData['mpResisted'] = {
    apply = dealMPDamage,
    enemyAnimation = 'enemyManaBurned',
}

effectData['instakill'] = { 
    apply = instakill , 
}

effectData['missed'] = { 
    apply = missed , 
    enemyAnimation = 'enemyDodged',
}

effectData['missedResist'] = { 
    apply = missed , 
    enemyAnimation = 'enemyDodgedResist',
}

effectData['addStatus'] = { 
    apply = addStatus,
}

effectData['addStatChange'] = { 
    apply = addStatChange,
}

effectData['clearStatus'] = {
    apply = clearStatus,
}

effectData['poisonDamage'] = { 
    apply = poisonDamage , 
    partyAnimation = 'partyDamaged',
    enemyAnimation = 'enemyDamaged',
}

effectData['curseEffect'] = { 
    apply = curseEffect,
}

effectData['stealGold'] = { 
    apply = stealGold,
}

effectData['stealItem'] = { 
    apply = stealItem,
}

return effectData