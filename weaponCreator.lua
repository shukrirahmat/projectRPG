weaponCreator = {}

local dataSheet = {}

dataSheet['rustedAxe'] = {
    name = 'Rusted Axe',
    atkPower = 80,
    category = 'AXE'
}

dataSheet['leatherFist'] = {
    name = 'Leather Fist',
    atkPower = 40,
    category = 'FIST'
}

dataSheet['woodenStaff'] = {
    name = 'Wooden Staff',
    atkPower = 15,
    category = 'STAFF'
}

dataSheet['smallDagger'] = {
    name = 'Small Dagger',
    atkPower = 25,
    category = 'DAGGER'
}

function weaponCreator.new(ref)
    
    local data = dataSheet[ref]
    
    local w = {}
    w.name = data.name
    w.atkPower = data.atkPower
    w.category = data.category
    w.weight = nil
    
    if data.category == 'SWORD' or data.category == 'DAGGER' or data.category == 'FIST' then
        w.weight = 'LIGHTWEIGHT'
    elseif data.category == 'HAMMER' or data.category == 'AXE' or data.category == 'SPEAR' then
        w.weight = 'HEAVYWEIGHT'
    else
        w.weight = 'OTHER'
    end
    
    return w
end

return weaponCreator