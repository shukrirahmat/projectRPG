local actions = require('systems.actions')

local actionData = {}

actionData['normalAtk'] = { 
    execute = actions.normalAttack, 
    cost = 0,
    enemyAnimation = {ref = 'enemyAtk', speed = 0.7},
    aim = 'enemies',
    scope = 'single'
}
actionData['secondAtk'] = {
    execute = actions.secondAttack, 
    cost = 0, 
    enemyAnimation = {ref = 'enemyAtk', speed = 0.7}
}

actionData['counterAtk'] = {
    execute = actions.counterAttack, 
    cost = 0, 
    partyAnimation = {ref = 'enemyAtk', speed = 0.7}
}

actionData['defend'] = { 
    execute = actions.defend, 
    cost = 0, 
    priority = 2,
    scope = 'self',
    aim = 'allies'
}

actionData['skillCanceled'] = { 
    execute = actions.skillCanceled
}

actionData['noAction'] = { 
    execute = actions.noAction
}

actionData['stunned'] = {
    execute = actions.stunned
}

actionData['paralyzed'] = {
    execute = actions.paralyzed
}

actionData['confused'] = {
    execute = actions.confused
}

actionData['sleeping'] = {
    execute = actions.sleeping
}

actionData['flameI'] = {
    name = 'Flame I', 
    magic = true,
    cost = 2, 
    desc = 'Deals small fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castDamageMagic,
    element = 'FIRE',
    baseDamage = 10
}

actionData['flameII'] = {
    name = 'Flame II', 
    magic = true,
    cost = 4, 
    desc = 'Deals medium fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castDamageMagic,
    element = 'FIRE',
    baseDamage = 40
}

actionData['flameIII'] = {
    name = 'Flame III', 
    magic = true,
    cost = 8, 
    desc = 'Deals large fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castDamageMagic,
    element = 'FIRE',
    baseDamage = 100
}

actionData['flameX'] = {
    name = 'Flame X', 
    magic = true,
    cost = 15, 
    desc = 'Deals very large fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castDamageMagic,
    element = 'FIRE',
    baseDamage = 240
}

actionData['frostI'] = {
    name = 'Frost I', 
    magic = true,
    cost = 3, 
    desc = 'Deals small ice damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castDamageMagic,
    element = 'ICE',
    baseDamage = 15
}

actionData['frostII'] = {
    name = 'Frost II', 
    magic = true,
    cost = 5, 
    desc = 'Deals medium ice damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castDamageMagic,
    element = 'ICE',
    baseDamage = 50
}

actionData['frostIII'] = {
    name = 'Frost III', 
    magic = true,
    cost = 10, 
    desc = 'Deals large ice damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castDamageMagic,
    element = 'ICE',
    baseDamage = 120
}

actionData['luminaI'] = {
    name = 'Lumina I', 
    magic = true,
    cost = 4, 
    desc = 'Deals small light damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castDamageMagic,
    element = 'LIGHT',
    baseDamage = 20
}

actionData['luminaII'] = {
    name = 'Lumina II', 
    magic = true,
    cost = 6, 
    desc = 'Deals medium light damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castDamageMagic,
    element = 'LIGHT',
    baseDamage = 80
}

actionData['luminaIII'] = {
    name = 'Lumina III', 
    magic = true,
    cost = 12, 
    desc = 'Deals large light damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castDamageMagic,
    element = 'LIGHT',
    baseDamage = 160
}

actionData['voidI'] = {
    name = 'Void I', 
    magic = true,
    cost = 4, 
    desc = 'Deals small void damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castDamageMagic,
    element = 'VOID',
    baseDamage = 20,
    variance = 0.4
}

actionData['voidII'] = {
    name = 'Void II', 
    magic = true,
    cost = 6, 
    desc = 'Deals medium void damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castDamageMagic,
    element = 'VOID',
    baseDamage = 80,
    variance = 0.4
}

actionData['voidIII'] = {
    name = 'Void III', 
    magic = true,
    cost = 12, 
    desc = 'Deals large void damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castDamageMagic,
    element = 'VOID',
    baseDamage = 160,
    variance = 0.4
}

actionData['infernoI'] = {
    name = 'Inferno I', 
    magic = true,
    cost = 4, 
    desc = 'Deals small fire damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castDamageMagic,
    element = 'FIRE',
    baseDamage = 10
}

actionData['infernoII'] = {
    name = 'Inferno II', 
    magic = true,
    cost = 8, 
    desc = 'Deals medium fire damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castDamageMagic,
    element = 'FIRE',
    baseDamage = 30
}

actionData['infernoIII'] = {
    name = 'Inferno III', 
    magic = true,
    cost = 12, 
    desc = 'Deals large fire damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castDamageMagic,
    element = 'FIRE',
    baseDamage = 80
}

actionData['blizzardI'] = {
    name = 'Blizzard I', 
    magic = true,
    cost = 3, 
    desc = 'Deals small ice damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castDamageMagic,
    element = 'ICE',
    baseDamage = 8
}

actionData['blizzardII'] = {
    name = 'Blizzard II', 
    magic = true,
    cost = 6, 
    desc = 'Deals medium ice damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castDamageMagic,
    element = 'ICE',
    baseDamage = 20
}

actionData['blizzardIII'] = {
    name = 'Blizzard III', 
    magic = true,
    cost = 10, 
    desc = 'Deals large ice damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castDamageMagic,
    element = 'ICE',
    baseDamage = 60
}

actionData['blizzardX'] = {
    name = 'Blizzard X', 
    magic = true,
    cost = 20, 
    desc = 'Deals very large ice damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castDamageMagic,
    element = 'ICE',
    baseDamage = 150
}

actionData['typhoonI'] = {
    name = 'Typhoon I', 
    magic = true,
    cost = 5, 
    desc = 'Deals small wind damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castDamageMagic,
    element = 'WIND',
    baseDamage = 15
}

actionData['typhoonII'] = {
    name = 'Typhoon II', 
    magic = true,
    cost = 9, 
    desc = 'Deals medium wind damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castDamageMagic,
    element = 'WIND',
    baseDamage = 50
}

actionData['typhoonIII'] = {
    name = 'Typhoon III', 
    magic = true,
    cost = 14, 
    desc = 'Deals large wind damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castDamageMagic,
    element = 'WIND',
    baseDamage = 100,
}

actionData['lightningI'] = {
    name = 'Lightning I', 
    magic = true,
    cost = 5, 
    desc = 'Deals small bolt damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castDamageMagic,
    element = 'BOLT',
    baseDamage = 15,
    variance = 0.4
}

actionData['lightningII'] = {
    name = 'Lightning II', 
    magic = true,
    cost = 9, 
    desc = 'Deals medium bolt damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castDamageMagic,
    element = 'BOLT',
    baseDamage = 50,
    variance = 0.4
}

actionData['lightningIII'] = {
    name = 'Lightning III', 
    magic = true,
    cost = 14, 
    desc = 'Deals large bolt damage to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castDamageMagic,
    element = 'BOLT',
    baseDamage = 100,
    variance = 0.4
}

actionData['auraI'] = {
    name = 'Aura I', 
    tech = true,
    cost = 0, 
    desc = 'Deals damage to all enemies using small percentage of strength',
    aim = 'enemies',
    scope = 'all',
    execute = actions.useAura,
    element = 'AURA',
    auraRatio = 0.1
}

actionData['auraII'] = {
    name = 'Aura II', 
    tech = true,
    cost = 0, 
    desc = 'Deals damage to all enemies using medium percentage of strength',
    aim = 'enemies',
    scope = 'all',
    execute = actions.useAura,
    element = 'AURA',
    auraRatio = 0.2
}

actionData['auraIII'] = {
    name = 'Aura III', 
    tech = true,
    cost = 0, 
    desc = 'Deals damage to all enemies using high percentage of strength',
    aim = 'enemies',
    scope = 'all',
    execute = actions.useAura,
    element = 'AURA',
    auraRatio = 0.4
}

actionData['auraBlastI'] = {
    name = 'Aura Blast I', 
    tech = true,
    cost = 0, 
    desc = 'Deals damage to one enemies using high percentage of strength',
    aim = 'enemies',
    scope = 'single',
    execute = actions.useAura,
    element = 'AURA',
    auraRatio = 0.8
}

actionData['auraBlastII'] = {
    name = 'Aura Blast II', 
    tech = true,
    cost = 0, 
    desc = 'Deals damage to one enemies using very high percentage of strength',
    aim = 'enemies',
    scope = 'single',
    execute = actions.useAura,
    element = 'AURA',
    auraRatio = 1.2
}

actionData['auraCharge'] = {
    name = 'Aura Charge', 
    tech = true,
    cost = 0, 
    desc = 'Next aura magic will deal 2.5 more damage',
    aim = 'allies',
    scope = 'self',
    execute = actions.auraCharge,
}

actionData['drainI'] = {
    name = 'Drain I', 
    magic = true,
    cost = 4, 
    desc = 'Deals damage to one enemy and recovers the same amount',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castDrain,
    element = 'DRAIN',
    baseDamage = 20,
    drainBonus = 0.1
}

actionData['drainII'] = {
    name = 'Drain II', 
    magic = true,
    cost = 8, 
    desc = 'Deals large damage to one enemy and recovers the same amount',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castDrain,
    element = 'DRAIN',
    baseDamage = 60,
    drainBonus = 0.25
}

actionData['manaBurnI'] = {
    name = 'Mana Burn I', 
    magic = true,
    cost = 2, 
    desc = 'Reduce small amount of all enemies MP',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castManaBurn,
    element = 'MANABURN',
    baseDamage = 10,
}

actionData['manaBurnII'] = {
    name = 'Mana Burn II', 
    magic = true,
    cost = 5, 
    desc = 'Reduce large amount of all enemies MP',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castManaBurn,
    element = 'MANABURN',
    baseDamage = 25,
}

actionData['drakebaneI'] = {
    name = 'Drakebane I', 
    magic = true,
    cost = 4, 
    desc = 'Deals large damage to dragons',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castDrakebane,
    baseDamage = 150
}

actionData['drakebaneII'] = {
    name = 'Drakebane II', 
    magic = true,
    cost = 8, 
    desc = 'Deals very large damage to dragons',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castDrakebane,
    baseDamage = 300
}

actionData['exorciseI'] = {
    name = 'Exorcise I', 
    magic = true,
    cost = 4, 
    desc = 'High chance to instantly kill an undead enemies',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castExorcise,
    accuracy = 80
}

actionData['exorciseII'] = {
    name = 'Exorcise II', 
    magic = true,
    cost = 8, 
    desc = 'High chance to instantly kill all undead enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castExorcise,
    accuracy = 80
}

actionData['deathI'] = {
    name = 'Death I', 
    magic = true,
    cost = 5, 
    desc = 'Chance to instantly kill one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castStatusEffect,
    element = 'DEATH',
    accuracy = 30
}

actionData['deathII'] = {
    name = 'Death II', 
    magic = true,
    cost = 10, 
    desc = 'Low chance to instantly kill all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'DEATH',
    accuracy = 15
}

actionData['deathIII'] = {
    name = 'Death III', 
    magic = true,
    cost = 15, 
    desc = 'High chance to instantly kill all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'DEATH',
    accuracy = 30
}

actionData['sandstormI'] = {
    name = 'Sandstorm I', 
    magic = true,
    cost = 3, 
    desc = 'Low chance to blind all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'BLIND',
    accuracy = 50
}

actionData['sandstormII'] = {
    name = 'Sandstorm II', 
    magic = true,
    cost = 5, 
    desc = 'High chance to blind all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'BLIND',
    accuracy = 80
}

actionData['sealI'] = {
    name = 'Seal I', 
    magic = true,
    cost = 3, 
    desc = 'Low chance to seal abilities of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'SEAL',
    accuracy = 50
}

actionData['sealII'] = {
    name = 'Seal II', 
    magic = true,
    cost = 5, 
    desc = 'High chance to seal abilities of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'SEAL',
    accuracy = 80
}

actionData['tremorI'] = {
    name = 'Tremor I', 
    magic = true,
    cost = 2, 
    desc = 'May stun one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castStatusEffect,
    element = 'STUN',
    accuracy = 50
}

actionData['tremorII'] = {
    name = 'Tremor II', 
    magic = true,
    cost = 5, 
    desc = 'Low chance to stun of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'STUN',
    accuracy = 25
}

actionData['tremorIII'] = {
    name = 'Tremor III', 
    magic = true,
    cost = 8, 
    desc = 'High chance to stun of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'STUN',
    accuracy = 50
}

actionData['woundI'] = {
    name = 'Wound I', 
    magic = true,
    cost = 3, 
    desc = 'Low chance to leave all enemies wounded',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'WOUND',
    accuracy = 50
}

actionData['woundII'] = {
    name = 'Wound II', 
    magic = true,
    cost = 5, 
    desc = 'High chance to leave all enemies wounded',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'WOUND',
    accuracy = 80
}

actionData['toxinI'] = {
    name = 'Toxin I', 
    magic = true,
    cost = 2, 
    desc = 'Chance to poison one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castStatusEffect,
    element = 'POISON',
    accuracy = 80
}

actionData['toxinII'] = {
    name = 'Toxin II', 
    magic = true,
    cost = 3, 
    desc = 'Low chance to poison all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'POISON',
    accuracy = 50
}

actionData['toxinIII'] = {
    name = 'Toxin III', 
    magic = true,
    cost = 5, 
    desc = 'High chance to poison all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'POISON',
    accuracy = 80
}

actionData['hexI'] = {
    name = 'Hex I', 
    magic = true,
    cost = 3, 
    desc = 'Chance to put a curse one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castStatusEffect,
    element = 'CURSE',
    accuracy = 70
}

actionData['hexII'] = {
    name = 'Hex II', 
    magic = true,
    cost = 5, 
    desc = 'Low chance to put a curse on all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'CURSE',
    accuracy = 40
}

actionData['hexIII'] = {
    name = 'Hex III', 
    magic = true,
    cost = 8, 
    desc = 'High chance to put a curse on all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'CURSE',
    accuracy = 70
}

actionData['paralyzeI'] = {
    name = 'Paralyze I', 
    magic = true,
    cost = 3, 
    desc = 'Chance to apply paralysis to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castStatusEffect,
    element = 'PARALYSIS',
    accuracy = 70
}

actionData['paralyzeII'] = {
    name = 'Paralyze II', 
    magic = true,
    cost = 5, 
    desc = 'Low chance to apply paralysis to all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'PARALYSIS',
    accuracy = 40
}

actionData['paralyzeIII'] = {
    name = 'Paralyze III', 
    magic = true,
    cost = 8, 
    desc = 'High chance to apply paralysis on all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'PARALYSIS',
    accuracy = 70
}

actionData['slumberI'] = {
    name = 'Slumber I', 
    magic = true,
    cost = 4, 
    desc = 'Chance to put one enemy to sleep',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castStatusEffect,
    element = 'SLEEP',
    accuracy = 50
}

actionData['slumberII'] = {
    name = 'Slumber II', 
    magic = true,
    cost = 7, 
    desc = 'Low chance to put one all enemies to sleep',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'SLEEP',
    accuracy = 25
}

actionData['slumberIII'] = {
    name = 'Slumber III', 
    magic = true,
    cost = 10, 
    desc = 'High chance to put one all enemies to sleep',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'SLEEP',
    accuracy = 50
}

actionData['confusionI'] = {
    name = 'Confusion I', 
    magic = true,
    cost = 4, 
    desc = 'Chance to confuse one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castStatusEffect,
    element = 'CONFUSE',
    accuracy = 50
}

actionData['confusionII'] = {
    name = 'Confusion II', 
    magic = true,
    cost = 7, 
    desc = 'Low chance to confuse all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'CONFUSE',
    accuracy = 25
}

actionData['confusionIII'] = {
    name = 'Confusion III', 
    magic = true,
    cost = 10, 
    desc = 'High chance to confuse all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'CONFUSE',
    accuracy = 50
}

actionData['healI'] = {
    name = 'Heal I', 
    magic = true,
    cost = 2, 
    desc = 'Recover small amount of HP to one ally',
    aim = 'allies',
    scope = 'single',
    execute = actions.castHeal,
    healAmount = 50
}

actionData['healII'] = {
    name = 'Heal II', 
    magic = true,
    cost = 4, 
    desc = 'Recover medium amount of HP to one ally',
    aim = 'allies',
    scope = 'single',
    execute = actions.castHeal,
    healAmount = 120
}

actionData['healIII'] = {
    name = 'Heal III', 
    magic = true,
    cost = 6, 
    desc = 'Recover large amount of HP to one ally',
    aim = 'allies',
    scope = 'single',
    execute = actions.castHeal,
    healAmount = 300
}

actionData['HealX'] = {
    name = 'Heal X', 
    magic = true,
    cost = 10, 
    desc = 'Recover HP of one ally to full',
    aim = 'allies',
    scope = 'single',
    execute = actions.castHeal,
    healAmount = 999
}

actionData['allHealI'] = {
    name = 'All Heal I', 
    magic = true,
    cost = 12, 
    desc = 'Recover medium amount of HP to all allies',
    aim = 'allies',
    scope = 'all',
    execute = actions.castHeal,
    healAmount = 80
}

actionData['allHealII'] = {
    name = 'All Heal II', 
    magic = true,
    cost = 20, 
    desc = 'Recover large amount of HP to all allies',
    aim = 'allies',
    scope = 'all',
    execute = actions.castHeal,
    healAmount = 200
}

actionData['neutralizeI'] = {
    name = 'Neutralize I', 
    magic = true,
    cost = 2, 
    desc = 'Remove poison from one ally',
    aim = 'allies',
    scope = 'single',
    execute = actions.castRemoveStatus,
    status = 'POISON'
}

actionData['neutralizeII'] = {
    name = 'Neutralize II', 
    magic = true,
    cost = 5, 
    desc = 'Remove poison from all allies',
    aim = 'allies',
    scope = 'all',
    execute = actions.castRemoveStatus,
    status = 'POISON'
}

actionData['purifyI'] = {
    name = 'Purify I', 
    magic = true,
    cost = 3, 
    desc = 'Remove curse from one ally',
    aim = 'allies',
    scope = 'single',
    execute = actions.castRemoveStatus,
    status = 'CURSE'
}

actionData['purifyII'] = {
    name = 'Purify II', 
    magic = true,
    cost = 6, 
    desc = 'Remove curse from all allies',
    aim = 'allies',
    scope = 'all',
    execute = actions.castRemoveStatus,
    status = 'CURSE'
}

actionData['mend'] = {
    name = 'Mend', 
    magic = true,
    cost = 8, 
    desc = 'Remove wound from all allies',
    aim = 'allies',
    scope = 'all',
    execute = actions.castRemoveStatus,
    status = 'WOUND'
}

actionData['dispelI'] = {
    name = 'Dispel I', 
    magic = true,
    cost = 3, 
    desc = 'Remove paralysis from one ally',
    aim = 'allies',
    scope = 'single',
    execute = actions.castRemoveStatus,
    status = 'PARALYSIS'
}

actionData['dispelII'] = {
    name = 'Dispel II', 
    magic = true,
    cost = 6, 
    desc = 'Remove paralysis from all allies',
    aim = 'allies',
    scope = 'all',
    execute = actions.castRemoveStatus,
    status = 'PARALYSIS'
}

actionData['alarmI'] = {
    name = 'Alarm I', 
    magic = true,
    cost = 3, 
    desc = 'Awake one ally from sleep',
    aim = 'allies',
    scope = 'single',
    execute = actions.castRemoveStatus,
    status = 'SLEEP'
}

actionData['alarmII'] = {
    name = 'Alarm II', 
    magic = true,
    cost = 6, 
    desc = 'Awake all allies from sleep',
    aim = 'allies',
    scope = 'all',
    execute = actions.castRemoveStatus,
    status = 'SLEEP'
}

actionData['soothI'] = {
    name = 'Sooth I', 
    magic = true,
    cost = 3, 
    desc = 'Remove confusion from one ally',
    aim = 'allies',
    scope = 'single',
    execute = actions.castRemoveStatus,
    status = 'CONFUSE'
}

actionData['soothII'] = {
    name = 'Sooth II', 
    magic = true,
    cost = 6, 
    desc = 'Remove confusion from all allies',
    aim = 'allies',
    scope = 'all',
    execute = actions.castRemoveStatus,
    status = 'CONFUSE'
}

actionData['cleanse'] = {
    name = 'Cleanse', 
    magic = true,
    cost = 10, 
    desc = 'Remove poison, curse, wound, paralysis, sleep and confusion from one ally',
    aim = 'allies',
    scope = 'single',
    execute = actions.castCleanse,
}

actionData['steelI'] = {
    name = 'Steel I', 
    magic = true,
    cost = 2, 
    desc = 'Increase the defensive power of one ally',
    aim = 'allies',
    scope = 'single',
    execute = actions.castStatusEffect,
    element = 'STEEL',
    accuracy = 100
}

actionData['steelII'] = {
    name = 'Steel II', 
    magic = true,
    cost = 5, 
    desc = 'Increase the defensive power of all allies',
    aim = 'allies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'STEEL',
    accuracy = 100
}

actionData['fleetI'] = {
    name = 'Fleet I', 
    magic = true,
    cost = 2, 
    desc = 'Increase the agility of one ally',
    aim = 'allies',
    scope = 'single',
    execute = actions.castStatusEffect,
    element = 'FLEET',
    accuracy = 100
}

actionData['fleetII'] = {
    name = 'Fleet II', 
    magic = true,
    cost = 5, 
    desc = 'Increase the agility of all allies',
    aim = 'allies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'FLEET',
    accuracy = 100
}

actionData['frailI'] = {
    name = 'Frail I', 
    magic = true,
    cost = 2, 
    desc = 'Reduce the defensive power of one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castStatusEffect,
    element = 'FRAIL',
    accuracy = 100
}

actionData['frailII'] = {
    name = 'Frail II', 
    magic = true,
    cost = 5, 
    desc = 'Reduce the defensive power of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'FRAIL',
    accuracy = 100
}

actionData['snareI'] = {
    name = 'Snare I', 
    magic = true,
    cost = 2, 
    desc = 'Reduce the agility of one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = actions.castStatusEffect,
    element = 'SNARE',
    accuracy = 100
}

actionData['snareII'] = {
    name = 'Snare II', 
    magic = true,
    cost = 5, 
    desc = 'Reduce the agility of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'SNARE',
    accuracy = 100
}

actionData['reviveI'] = {
    name = 'Revive I', 
    magic = true,
    cost = 25, 
    desc = 'Revive one dead ally with some HP',
    aim = 'allies',
    scope = 'dead',
    execute = actions.castRevive,
    reviveRatio = 25
}

actionData['reviveII'] = {
    name = 'Revive II', 
    magic = true,
    cost = 50, 
    desc = 'Revive one dead ally with full HP',
    aim = 'allies',
    scope = 'dead',
    execute = actions.castRevive,
    reviveRatio = 100
}

actionData['barrier'] = {
    name = 'Barrier', 
    magic = true,
    cost = 12, 
    desc = 'Summons barrier that reduce magic damage toward allies',
    aim = 'allies',
    scope = 'all',
    execute = actions.castStatusEffect,
    element = 'BARRIER',
    accuracy = 100
}

actionData['might'] = {
    name = 'Might', 
    magic = true,
    cost = 8, 
    desc = 'Increases the attack power of one ally',
    aim = 'allies',
    scope = 'single',
    execute = actions.castStatusEffect,
    element = 'MIGHT',
    accuracy = 100
}

actionData['guardian'] = {
    name = 'Guardian', 
    magic = true,
    cost = 20, 
    desc = 'Protects all allies from any attacks for one turn while also disabling them',
    aim = 'allies',
    scope = 'all',
    execute = actions.castGuardian,
    accuracy = 100,
    priority = 3
}

actionData['quickStrike'] = {
    name = 'Quick Strike', 
    tech = true,
    cost = 0, 
    desc = 'A fast normal attack that deals half the damage',
    aim = 'enemies',
    scope = 'single',
    execute = actions.quickStrike,
    priority = 1
}

actionData['cover'] = {
    name = 'Cover', 
    tech = true,
    cost = 0, 
    desc = 'Cover an ally from any attack',
    aim = 'allies',
    scope = 'single',
    execute = actions.cover,
    priority = 2
}

actionData['flameStrike'] = {
    name = 'Flame Strike', 
    tech = true,
    cost = 4, 
    desc = 'A normal attack that are imbued with fire element',
    aim = 'enemies',
    scope = 'single',
    execute = actions.elementalStrike,
    element = 'FIRE'
}

actionData['frostStrike'] = {
    name = 'Frost Strike', 
    tech = true,
    cost = 4, 
    desc = 'A normal attack that are imbued with ice element',
    aim = 'enemies',
    scope = 'single',
    execute = actions.elementalStrike,
    element = 'ICE'
}

actionData['lightningStrike'] = {
    name = 'Lightning Strike', 
    tech = true,
    cost = 4, 
    desc = 'A normal attack that are imbued with bolt element',
    aim = 'enemies',
    scope = 'single',
    execute = actions.elementalStrike,
    element = 'BOLT'
}

actionData['typhoonStrike'] = {
    name = 'Typhoon Strike', 
    tech = true,
    cost = 4, 
    desc = 'A normal attack that are imbued with wind element',
    aim = 'enemies',
    scope = 'single',
    execute = actions.elementalStrike,
    element = 'WIND'
}

actionData['luminaStrike'] = {
    name = 'Lumina Strike', 
    tech = true,
    cost = 6, 
    desc = 'A normal attack that are imbued with light element',
    aim = 'enemies',
    scope = 'single',
    execute = actions.elementalStrike,
    element = 'LIGHT'
}

actionData['voidStrike'] = {
    name = 'Void Strike', 
    tech = true,
    cost = 6, 
    desc = 'A normal attack that are imbued with void element',
    aim = 'enemies',
    scope = 'single',
    execute = actions.elementalStrike,
    element = 'VOID'
}

actionData['focus'] = {
    name = 'Focus', 
    tech = true,
    cost = 0, 
    desc = 'Ensure next normal attack to not miss',
    aim = 'allies',
    scope = 'self',
    execute = actions.focus,
}

actionData['ram'] = {
    name = 'Ram', 
    tech = true,
    cost = 0, 
    desc = 'Charges into an enemy, and take some recoil damage',
    aim = 'enemies',
    scope = 'single',
    execute = actions.ram,
}

actionData['desperation'] = {
    name = 'Desperation', 
    tech = true,
    cost = 0, 
    desc = 'Attack that are more likely to land critical hits at low health',
    aim = 'enemies',
    scope = 'single',
    execute = actions.desperation,
}

actionData['undo'] = {
    name = 'Undo', 
    tech = true,
    cost = 0, 
    desc = 'Remove Frail and Snare debuffs from self',
    aim = 'allies',
    scope = 'self',
    execute = actions.undo,
}

actionData['healingTonic'] = {
    name = 'Healing Tonic', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = actions.useTonic,
    healAmount = 40
}

actionData['potentTonic'] = {
    name = 'Potent Tonic', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = actions.useTonic,
    healAmount = 80
}

actionData['prismTonic'] = {
    name = 'Prism Tonic', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = actions.useTonic,
    healAmount = 999
}

actionData['goldenNectar'] = {
    name = 'Golden Nectar', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = actions.useNectar,
    mpHealAmount = 40
}

actionData['antidote'] = {
    name = 'Antidote', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = actions.useStatusRecovery,
    status = 'POISON'
}

actionData['holyWater'] = {
    name = 'Holy Water', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = actions.useStatusRecovery,
    status = 'CURSE'
}

actionData['bandage'] = {
    name = 'Bandage', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = actions.useStatusRecovery,
    status = 'WOUND'
}

actionData['wigglyGrass'] = {
    name = 'Wiggly Grass', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = actions.useStatusRecovery,
    status = 'PARALYSIS'
}

actionData['fairyBell'] = {
    name = 'Fairy Bell', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = actions.useStatusRecovery,
    status = 'SLEEP'
}

actionData['clarityBrew'] = {
    name = 'Clarity Brew', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = actions.useStatusRecovery,
    status = 'CONFUSE'
}

return actionData;