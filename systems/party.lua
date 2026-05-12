local party = {}

function party.load(members)
    party.members = members
    party.items = {}
    party.gold = 0
end

function party.manage_gold(amount)
    party.gold = party.gold + amount
    if party.gold <= 0 then
        party.gold = 0
    end
end

function party.manage_item(ref, quantity)
    if party.items[ref] then
        party.items[ref] = party.items[ref] + quantity
    elseif not party.items[ref] and quantity > 0 then
        party.items[ref] = quantity
    end

    if party.items[ref] < 1 then
        party.items[ref] = nil
    end
end

return party