local Input = require('input')

local Order = {}

local Menu = nil
local Party = nil

local position = nil
local lifted = nil
local saved = nil
local lg = love.graphics

function Order.load(menu, party)
    Menu = menu
    Party = party

    position = 1
    lifted = nil
    saved = nil
end

function Order.draw(member, x, y, width, height)
    if member == Party.members[position] then
        local vertical_center = y + height * 0.5
        lg.polygon('fill', 
            x - 35, vertical_center - 20, 
            x - 35, vertical_center + 20, 
            x - 15, vertical_center
        )
    end
end

function Order.keypressed(key)
    if key == Input.back then
        Order.back()
    elseif key == Input.up then
        Order.up()
    elseif key == Input.down then
        Order.down()
    elseif key == Input.confirm then
        Order.confirm()
    end
end

function Order.back()
    if lifted then
        lifted = nil
        Party.members = saved.arrangement
        position = saved.position
    else
        Menu.switch_phase('main')
    end
end

function Order.up()
    if position > 1 then
        if lifted then
            Party.members[position], Party.members[position - 1] = Party.members[position - 1],Party.members[position]
        end
        position = position - 1
    end
end

function Order.down()
    if position < #Party.members then
        if lifted then
            Party.members[position], Party.members[position + 1] = Party.members[position + 1],Party.members[position]
        end
        position = position + 1
    end
end

function Order.confirm()
    if lifted then
        lifted = nil
    else
        lifted = Party.members[position]
        saved = { arrangement = {unpack(Party.members)} , position = position}
    end
end

function Order.has_lifted(member)
    return lifted == member
end

return Order