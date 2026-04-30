local item_data = require('data.item_data')

local spoils = {
}

function spoils.load(gold, items, party_manager, textbox)
    spoils.gold = gold
    spoils.items = items
    spoils.party_manager = party_manager
    spoils.textbox = textbox
    spoils.is_active = true
end

function spoils.update(dt)
    if not spoils.is_active then return end
    
    spoils.party_manager.manage_gold(spoils.gold)
    spoils.textbox.queue({'The party obtained '..spoils.gold..' gold.'})
    
    local item_lines = {}
    for i, item in ipairs(spoils.items) do
        spoils.party_manager.manage_item(item.ref, 1)
        local item_name = item_data[item.ref].name
        table.insert(item_lines, ''..item.enemy_name..' dropped '..item_name..'.')
    end
    
    if #item_lines > 0 then
        spoils.textbox.queue(item_lines)
    end
    
    spoils.is_active = false;    
end

return spoils