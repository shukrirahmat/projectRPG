local passiveData = {}

passiveData['dualWielder'] = {name = 'Dual Wielder', desc = 'Attack twice regardless of agility'};
passiveData['fireLord'] = {name = 'Fire Lord', desc = 'Fire magic deals more damage'}
passiveData['iceLord'] = {name = 'Ice Lord', desc = 'Ice magic deals more damage'}
passiveData['windLord'] = {name = 'Wind Lord', desc = 'Wind magic deals more damage'}
passiveData['thunderLord'] = {name = 'Thunder Lord', desc = 'Bolt magic deals more damage'}
passiveData['seraph'] = {name = 'Seraph', desc = 'Light magic deals more damage'}
passiveData['demonLord'] = {name = 'Demon Lord', desc = 'Void magic deals more damage'}
passiveData['leechLord'] = {name = 'Leech Lord', desc = 'Drain magic deals more damage'}
passiveData['keenEye'] = {name = 'Keen Eye', desc = 'increase critical hit chance'}
passiveData['keenEye+'] = {name = 'Keen Eye +', desc = 'increate ciritical hit chance further'}
passiveData['evasion'] = {name = 'Evasion', desc = 'chance to dodge normal attack'}
passiveData['evasion+'] = {name = 'Evasion +', desc = 'higher chance to dodge normal attack'}
passiveData['arcaneProtection'] = {name = 'Arcane Protection', 
    desc = 'gain strong resistance to fire, ice, wind and bolt'}
passiveData['celestialProtection'] = {name = 'Celestial Protection', 
    desc = 'gain strong resistance to light and void'}
passiveData['regenerate'] = {name = 'Regenerate', desc = 'recover HP every turn'}
passiveData['echoMagic'] = {name = 'Echo Magic', desc = 'chance to cast magic twice'}
passiveData['basher'] = {name = 'Basher', desc = 'chance to stun the enemy on normal attack'}
passiveData['executor'] = {name = 'Executor', desc = 'chance to instantly kill enemy on normal attack'}
passiveData['pincher'] = {name = 'Pincher', desc = 'Normal attack steals money from the enemy'}
passiveData['snatcher'] = {name = 'Snatcher', desc = 'Normal attack may steal item from the enemy'}
passiveData['counter'] = {name = 'Counter', desc = 'Counters when hit with normal attack'}
passiveData['ranged'] = {name = 'Ranged', desc = 'Normal attack will not be countered'}
passiveData['piercer'] = {name = 'Piercer', desc = 'Attack goes through armored enemies defense'}
passiveData['lightWielder'] = {name = 'Light Wielder', desc = 'Gain atk power when equipped with sword, dagger or fists'}
passiveData['HeavyWielder'] = {name = 'Heavy Wielder', desc = 'Gain atk power when equipped with axe, hammer or spear'}
passiveData['fireCombo'] = {name = 'Fire Combo', desc = 'Normal attack is followed by Flame I or II'}
passiveData['iceCombo'] = {name = 'Ice Combo', desc = 'Normal attack is followed by Ice I or II'}
passiveData['windCombo'] = {name = 'Wind Combo', desc = 'Normal attack is followed by Typhoon I'}
passiveData['boltCombo'] = {name = 'Bolt Lord', desc = 'Normal attack is followed by Lightning I'}
passiveData['manaSaver'] = {name = 'Mana Saver', desc = 'Magic attack have a chance to return back the MP cost after casting'}
passiveData['lastStand'] = {name = 'Last Stand', desc = 'if HP is more than 1, then killing blow will left with 1 HP'}

local resistances = { 
        'FIRE', 'ICE', 'WIND', 'BOLT', 'LIGHT', 'VOID', 'AURA', 'DRAIN', 'MANABURN',
        'BLIND', 'SEAL', 'STUN', 'POISON', 'WOUND', 'CURSE', 'SLEEP', 'CONFUSE', 'PARALYSIS',
        'DEATH', 'FRAIL', 'SNARE'
}

for i, res in ipairs(resistances) do
    passiveData['strong:'..res..''] = {name = 'Anti-'..res:lower()..'', 
        desc = 'Gain strong resistance to '..res:lower()..' element'};
    passiveData['immune:'..res..''] = {name = 'Immune-'..res:lower()..'', 
        desc = 'Gain immunity to '..res:lower()..' element'};
end

return passiveData