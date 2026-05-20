local Input = require('input')

local Order = {}

local Menu = nil
local Party = nil

local position = nil
local default = nil
local lg = love.graphics

function Order.load(menu, party, member_index)
    Menu = menu
    Party = party

    position = member_index
    default = {unpack(Party.members)}
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
    Party.members = default
    Menu.switch_phase('choose_member')
end

function Order.up()
    if position > 1 then
        Party.members[position], Party.members[position - 1] = Party.members[position - 1],Party.members[position]
        position = position - 1
    end
end

function Order.down()
    if position < #Party.members then
        Party.members[position], Party.members[position + 1] = Party.members[position + 1],Party.members[position]
        position = position + 1
    end
end

function Order.confirm()
    Menu.switch_phase('choose_member')
    Menu.set_member_index(position)
end

function Order.has_moved(member)
    return member == Party.members[position]
end

return Order