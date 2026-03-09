local actionData = {}

actionData['normalAtk'] = { 
    execute = normalAttack, 
    cost = 0,
    enemyAnimation = {ref = 'enemyAtk', maxTick = 8, speed = 0.08}
}
actionData['secondAtk'] = {
    execute = secondAttack, 
    cost = 0, 
    enemyAnimation = {ref = 'enemyAtk', maxTick = 8, speed = 0.08}
}

actionData['counterAtk'] = {
    execute = counterAttack, 
    cost = 0, 
    partyAnimation = {ref = 'enemyAtk', maxTick = 8, speed = 0.08}
}

actionData['defend'] = { 
    execute = defend, 
    cost = 0, 
    priority = 2
}

actionData['skillCanceled'] = { 
    execute = skillCanceled
}

actionData['stunned'] = {
    execute = stunned
}

actionData['paralyzed'] = {
    execute = paralyzed
}

actionData['confused'] = {
    execute = confused
}

actionData['sleeping'] = {
    execute = sleeping
}

actionData['flameI'] = {
    name = 'Flame I', 
    magic = true,
    cost = 2, 
    desc = 'Deals small fire damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
    element = 'FIRE',
    baseDamage = 250
}

actionData['frostI'] = {
    name = 'Frost I', 
    magic = true,
    cost = 3, 
    desc = 'Deals small ice damage to one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = castDamageMagic,
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
    execute = useAura,
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
    execute = useAura,
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
    execute = useAura,
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
    execute = useAura,
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
    execute = useAura,
    element = 'AURA',
    auraRatio = 1.5
}

actionData['auraCharge'] = {
    name = 'Aura Charge', 
    tech = true,
    cost = 0, 
    desc = 'Next aura magic will deal 2.5 more damage',
    aim = 'allies',
    scope = 'self',
    execute = auraCharge,
}

actionData['drainI'] = {
    name = 'Drain I', 
    magic = true,
    cost = 4, 
    desc = 'Deals damage to one enemy and recovers the same amount',
    aim = 'enemies',
    scope = 'single',
    execute = castDrain,
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
    execute = castDrain,
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
    execute = castManaBurn,
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
    execute = castManaBurn,
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
    execute = castDracoBomb,
    baseDamage = 150
}

actionData['drakebaneII'] = {
    name = 'Drakebane II', 
    magic = true,
    cost = 8, 
    desc = 'Deals very large damage to dragons',
    aim = 'enemies',
    scope = 'single',
    execute = castDracoBomb,
    baseDamage = 300
}

actionData['exorciseI'] = {
    name = 'Exorcise I', 
    magic = true,
    cost = 4, 
    desc = 'High chance to instantly kill an undead enemies',
    aim = 'enemies',
    scope = 'single',
    execute = castExorcism,
    accuracy = 80
}

actionData['exorciseII'] = {
    name = 'Exorcise II', 
    magic = true,
    cost = 8, 
    desc = 'High chance to instantly kill all undead enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castExorcism,
    accuracy = 80
}

actionData['deathI'] = {
    name = 'Death I', 
    magic = true,
    cost = 5, 
    desc = 'Chance to instantly kill one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castStatusEffect,
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
    execute = castStatusEffect,
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
    execute = castStatusEffect,
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
    execute = castStatusEffect,
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
    execute = castStatusEffect,
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
    execute = castStatusEffect,
    element = 'SEAL',
    accuracy = 50
}

actionData['sealII'] = {
    name = 'seal II', 
    magic = true,
    cost = 5, 
    desc = 'High chance to seal abilities of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'SEAL',
    accuracy = 80
}

actionData['tremorI'] = {
    name = 'Tremor I', 
    magic = true,
    cost = 5, 
    desc = 'Low chance to stun of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'STUN',
    accuracy = 25
}

actionData['tremorII'] = {
    name = 'Tremor II', 
    magic = true,
    cost = 8, 
    desc = 'High chance to stun of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
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
    execute = castStatusEffect,
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
    execute = castStatusEffect,
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
    execute = castStatusEffect,
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
    execute = castStatusEffect,
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
    execute = castStatusEffect,
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
    execute = castStatusEffect,
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
    execute = castStatusEffect,
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
    execute = castStatusEffect,
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
    execute = castStatusEffect,
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
    execute = castStatusEffect,
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
    execute = castStatusEffect,
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
    execute = castStatusEffect,
    element = 'SLEEP',
    accuracy = 40
}

actionData['slumberII'] = {
    name = 'Slumber II', 
    magic = true,
    cost = 7, 
    desc = 'Low chance to put one all enemies to sleep',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'SLEEP',
    accuracy = 20
}

actionData['slumberIII'] = {
    name = 'Slumber III', 
    magic = true,
    cost = 10, 
    desc = 'High chance to put one all enemies to sleep',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'SLEEP',
    accuracy = 40
}

actionData['confusionI'] = {
    name = 'Confusion I', 
    magic = true,
    cost = 4, 
    desc = 'Chance to confuse one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castStatusEffect,
    element = 'CONFUSE',
    accuracy = 40
}

actionData['confusionII'] = {
    name = 'Confusion II', 
    magic = true,
    cost = 7, 
    desc = 'Low chance to confuse all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'CONFUSE',
    accuracy = 20
}

actionData['confusionIII'] = {
    name = 'Confusion III', 
    magic = true,
    cost = 10, 
    desc = 'High chance to confuse all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'CONFUSE',
    accuracy = 40
}

actionData['healI'] = {
    name = 'Heal I', 
    magic = true,
    cost = 2, 
    desc = 'Recover small amount of HP to one ally',
    aim = 'allies',
    scope = 'single',
    execute = castHeal,
    healAmount = 50
}

actionData['healII'] = {
    name = 'Heal II', 
    magic = true,
    cost = 4, 
    desc = 'Recover medium amount of HP to one ally',
    aim = 'allies',
    scope = 'single',
    execute = castHeal,
    healAmount = 100
}

actionData['healIII'] = {
    name = 'Heal III', 
    magic = true,
    cost = 6, 
    desc = 'Recover large amount of HP to one ally',
    aim = 'allies',
    scope = 'single',
    execute = castHeal,
    healAmount = 300
}

actionData['fullHeal'] = {
    name = 'Full Heal', 
    magic = true,
    cost = 10, 
    desc = 'Recover HP of one ally to full',
    aim = 'allies',
    scope = 'single',
    execute = castHeal
}

actionData['healAllI'] = {
    name = 'Heal All I', 
    magic = true,
    cost = 12, 
    desc = 'Recover medium amount of HP to all allies',
    aim = 'allies',
    scope = 'all',
    execute = castHeal,
    healAmount = 80
}

actionData['healAllII'] = {
    name = 'Heal All II', 
    magic = true,
    cost = 20, 
    desc = 'Recover large amount of HP to all allies',
    aim = 'allies',
    scope = 'all',
    execute = castHeal,
    healAmount = 250
}

actionData['neutralize'] = {
    name = 'Neutralize', 
    magic = true,
    cost = 2, 
    desc = 'Remove poison from one ally',
    aim = 'allies',
    scope = 'single',
    execute = castRemoveStatus,
    status = 'POISON'
}

actionData['neutralizeAll'] = {
    name = 'Neutralize All', 
    magic = true,
    cost = 5, 
    desc = 'Remove poison from all allies',
    aim = 'allies',
    scope = 'all',
    execute = castRemoveStatus,
    status = 'POISON'
}

actionData['purify'] = {
    name = 'Purify', 
    magic = true,
    cost = 3, 
    desc = 'Remove curse from one ally',
    aim = 'allies',
    scope = 'single',
    execute = castRemoveStatus,
    status = 'CURSE'
}

actionData['purifyAll'] = {
    name = 'Purify All', 
    magic = true,
    cost = 6, 
    desc = 'Remove curse from all allies',
    aim = 'allies',
    scope = 'all',
    execute = castRemoveStatus,
    status = 'CURSE'
}

actionData['mendAll'] = {
    name = 'Mend All', 
    magic = true,
    cost = 8, 
    desc = 'Remove wound from all allies',
    aim = 'allies',
    scope = 'all',
    execute = castRemoveStatus,
    status = 'WOUND'
}

actionData['dispel'] = {
    name = 'Dispel', 
    magic = true,
    cost = 3, 
    desc = 'Remove paralysis from one ally',
    aim = 'allies',
    scope = 'single',
    execute = castRemoveStatus,
    status = 'PARALYSIS'
}

actionData['dispelAll'] = {
    name = 'Dispel All', 
    magic = true,
    cost = 6, 
    desc = 'Remove paralysis from all allies',
    aim = 'allies',
    scope = 'all',
    execute = castRemoveStatus,
    status = 'PARALYSIS'
}

actionData['alarm'] = {
    name = 'Alarm', 
    magic = true,
    cost = 3, 
    desc = 'Awake one ally from sleep',
    aim = 'allies',
    scope = 'single',
    execute = castRemoveStatus,
    status = 'SLEEP'
}

actionData['alarmAll'] = {
    name = 'Alarm All', 
    magic = true,
    cost = 6, 
    desc = 'Awake all allies from sleep',
    aim = 'allies',
    scope = 'all',
    execute = castRemoveStatus,
    status = 'SLEEP'
}

actionData['sooth'] = {
    name = 'Sooth', 
    magic = true,
    cost = 3, 
    desc = 'Remove confusion from one ally',
    aim = 'allies',
    scope = 'single',
    execute = castRemoveStatus,
    status = 'CONFUSE'
}

actionData['soothAll'] = {
    name = 'Sooth All', 
    magic = true,
    cost = 6, 
    desc = 'Remove confusion from all allies',
    aim = 'allies',
    scope = 'all',
    execute = castRemoveStatus,
    status = 'CONFUSE'
}

actionData['cleanse'] = {
    name = 'Cleanse', 
    magic = true,
    cost = 10, 
    desc = 'Remove poison, curse, wound, paralysis, sleep and confusion from one ally',
    aim = 'allies',
    scope = 'single',
    execute = castRemoveStatus,
}

actionData['steel'] = {
    name = 'Steel', 
    magic = true,
    cost = 2, 
    desc = 'Increase the defensive power of one ally',
    aim = 'allies',
    scope = 'single',
    execute = castStatusEffect,
    element = 'STEEL',
    accuracy = 100
}

actionData['steelAll'] = {
    name = 'Steel All', 
    magic = true,
    cost = 5, 
    desc = 'Increase the defensive power of all allies',
    aim = 'allies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'STEEL',
    accuracy = 100
}

actionData['fleet'] = {
    name = 'Fleet', 
    magic = true,
    cost = 2, 
    desc = 'Increase the agility of one ally',
    aim = 'allies',
    scope = 'single',
    execute = castStatusEffect,
    element = 'FLEET',
    accuracy = 100
}

actionData['fleetAll'] = {
    name = 'Fleet All', 
    magic = true,
    cost = 5, 
    desc = 'Increase the agility of all allies',
    aim = 'allies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'FLEET',
    accuracy = 100
}

actionData['frail'] = {
    name = 'Frail', 
    magic = true,
    cost = 2, 
    desc = 'Reduce the defensive power of one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castStatusEffect,
    element = 'FRAIL',
    accuracy = 100
}

actionData['frail All'] = {
    name = 'Frail All', 
    magic = true,
    cost = 5, 
    desc = 'Reduce the defensive power of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'FRAIL',
    accuracy = 100
}

actionData['snare'] = {
    name = 'Snare', 
    magic = true,
    cost = 2, 
    desc = 'Reduce the agility of one enemy',
    aim = 'enemies',
    scope = 'single',
    execute = castStatusEffect,
    element = 'SNARE',
    accuracy = 100
}

actionData['snareAll'] = {
    name = 'Snare All', 
    magic = true,
    cost = 5, 
    desc = 'Reduce the agility of all enemies',
    aim = 'enemies',
    scope = 'all',
    execute = castStatusEffect,
    element = 'SNARE',
    accuracy = 100
}

actionData['revive'] = {
    name = 'Revive', 
    magic = true,
    cost = 25, 
    desc = 'Revive one dead ally with some HP',
    aim = 'allies',
    scope = 'dead',
    execute = castRevive,
    reviveRatio = 25
}

actionData['fullRevive'] = {
    name = 'Full Revive', 
    magic = true,
    cost = 50, 
    desc = 'Revive one dead ally with full HP',
    aim = 'allies',
    scope = 'dead',
    execute = castRevive,
    reviveRatio = 100
}

actionData['barrier'] = {
    name = 'Barrier', 
    magic = true,
    cost = 12, 
    desc = 'Summons barrier that reduce magic damage toward allies',
    aim = 'allies',
    scope = 'all',
    execute = castStatusEffect,
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
    execute = castStatusEffect,
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
    execute = castGuardian,
    element = 'GUARDIAN',
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
    execute = quickStrike,
    priority = 1
}

actionData['hiddenBlades'] = {
    name = 'Hidden Blades', 
    tech = true,
    cost = 0, 
    desc = 'Quickly throw sharp daggers to all enemies that also might stun them',
    aim = 'enemies',
    scope = 'all',
    execute = hiddenBlades,
    priority = 1
}

actionData['cover'] = {
    name = 'Cover', 
    tech = true,
    cost = 0, 
    desc = 'Cover an ally from any attack',
    aim = 'allies',
    scope = 'single',
    execute = cover,
    priority = 2
}

actionData['flameStrike'] = {
    name = 'Flame Strike', 
    tech = true,
    cost = 4, 
    desc = 'A normal attack that are imbued with fire element',
    aim = 'enemies',
    scope = 'single',
    execute = elementalStrike,
    element = 'FIRE'
}

actionData['frostStrike'] = {
    name = 'Frost Strike', 
    tech = true,
    cost = 4, 
    desc = 'A normal attack that are imbued with ice element',
    aim = 'enemies',
    scope = 'single',
    execute = elementalStrike,
    element = 'ICE'
}

actionData['ligtningStrike'] = {
    name = 'Lightning Strike', 
    tech = true,
    cost = 4, 
    desc = 'A normal attack that are imbued with bolt element',
    aim = 'enemies',
    scope = 'single',
    execute = elementalStrike,
    element = 'BOLT'
}

actionData['typhoonStrike'] = {
    name = 'Typhoon Strike', 
    tech = true,
    cost = 4, 
    desc = 'A normal attack that are imbued with wind element',
    aim = 'enemies',
    scope = 'single',
    execute = elementalStrike,
    element = 'WIND'
}

actionData['luminaStrike'] = {
    name = 'Lumina Strike', 
    tech = true,
    cost = 6, 
    desc = 'A normal attack that are imbued with light element',
    aim = 'enemies',
    scope = 'single',
    execute = elementalStrike,
    element = 'LIGHT'
}

actionData['voidStrike'] = {
    name = 'Void Strike', 
    tech = true,
    cost = 6, 
    desc = 'A normal attack that are imbued with void element',
    aim = 'enemies',
    scope = 'single',
    execute = elementalStrike,
    element = 'VOID'
}

actionData['focus'] = {
    name = 'Focus', 
    tech = true,
    cost = 0, 
    desc = 'Ensure next normal attack to not miss',
    aim = 'allies',
    scope = 'self',
    execute = focus,
}

actionData['ram'] = {
    name = 'Ram', 
    tech = true,
    cost = 0, 
    desc = 'Charges into an enemy, and take some recoil damage',
    aim = 'enemies',
    scope = 'single',
    execute = ram,
}

actionData['desperation'] = {
    name = 'Desperation', 
    tech = true,
    cost = 0, 
    desc = 'Attack that are more likely to land critical hits at low health',
    aim = 'enemies',
    scope = 'single',
    execute = desperation,
}

actionData['undo'] = {
    name = 'Undo', 
    tech = true,
    cost = 0, 
    desc = 'Remove defense and agility debuffs from self',
    aim = 'allies',
    scope = 'self',
    execute = undo,
}

actionData['healingTonic'] = {
    name = 'Healing Tonic', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = useTonic,
    healAmount = 40
}

actionData['prismTonic'] = {
    name = 'Prism Tonic', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = useTonic,
}

actionData['goldenNectar'] = {
    name = 'Golden Nectar', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = useNectar,
    mpHealAmount = 40
}

actionData['antidote'] = {
    name = 'Antidote', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = useStatusRecovery,
    status = 'POISON'
}

actionData['holyWater'] = {
    name = 'Holy Water', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = useStatusRecovery,
    status = 'CURSE'
}

actionData['bandage'] = {
    name = 'Bandage', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = useStatusRecovery,
    status = 'WOUND'
}

actionData['wigglyGrass'] = {
    name = 'Wiggly Grass', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = useStatusRecovery,
    status = 'PARALYSIS'
}

actionData['fairyBell'] = {
    name = 'Fairy Bell', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = useStatusRecovery,
    status = 'SLEEP'
}

actionData['clarityBrew'] = {
    name = 'Clarity Brew', 
    item = true,
    cost = 0, 
    aim = 'allies',
    scope = 'single',
    execute = useStatusRecovery,
    status = 'CONFUSE'
}

return actionData;