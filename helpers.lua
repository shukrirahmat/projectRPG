local state = require('state')

H = {}

helpers = H

function H.getAbleCharID(currentID, where)
    local nextID
    local found = false
    local outOfBound

    if where == 'next' then
        nextID = currentID + 1
        outOfBound = nextID > #state.party 
    elseif where == 'prev' then
        nextID = currentID - 1
        outOfBound = nextID < 1
    end

    while not found and not outOfBound do
        if not state.party[nextID].isDead then
            found = true
        else
            if where == 'next' then
                nextID = nextID + 1
                outOfBound = nextID > #state.party 
            elseif where == 'prev' then
                nextID = nextID - 1
                outOfBound = nextID < 1
            end
        end
    end

    if found then
        return nextID
    else
        return nil
    end
end

return H