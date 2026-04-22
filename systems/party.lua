local party = {}

local members = nil
local items = nil

function party.load(_members)
    members = _members
    items = {}
end

function party.get_members()
    return members
end

function party.manage_item(ref, quantity)
    if items[ref] then
        items[ref] = items[ref] + quantity
    elseif not items[ref] and quantity > 0 then
        items[ref] = quantity
    end

    if items[ref] < 1 then
        items[ref] = nil
    end
end

return party 