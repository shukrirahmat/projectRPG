local party = {}

local members = nil

function party.load(_members)
    members = _members
end

function party.get_members()
    return members
end

return party 