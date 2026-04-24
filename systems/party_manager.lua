local party_manager = {}

local members = nil
local items = nil
local gold = nil

function party_manager.load(_members)
    members = _members
    items = {}
    gold = 0
end

function party_manager.get_members()
    return members
end

function party_manager.get_gold()
    return gold
end

function party_manager.manage_gold(amount)
    gold = gold + amount
    if gold <= 0 then
        gold = 0
    end
end

function party_manager.get_items()
    return items
end

function party_manager.manage_item(ref, quantity)
    if items[ref] then
        items[ref] = items[ref] + quantity
    elseif not items[ref] and quantity > 0 then
        items[ref] = quantity
    end

    if items[ref] < 1 then
        items[ref] = nil
    end
end

return party_manager 