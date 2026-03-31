local battler = require('systems.battler')
local utils = require('systems.utils')
local enemy_data = require('data.enemy_data')
local middle_screen = require('states.battle.middle_screen')
local hud = require('states.battle.hud')

local battle = {}

local party_battlers = {}
local enemy_battlers = {}

local function set_party_battlers(party)
    for i, member in ipairs(party) do
        local new_battler = battler.new_member(member)
        table.insert(party_battlers, new_battler)
    end
end

local function set_enemy_battlers(enemies)
    for k, v in pairs(enemies) do
        for i = 1, v do
            local name = utils.capitalize(k)
            if v > 1 then
                name = ''..name..' #'..i..''
            end
            local new_battler = battler.new_enemy(enemy_data[k], name)
            table.insert(enemy_battlers, new_battler)
        end
    end
end

function battle.load(game, var)
    set_party_battlers(game.party.get_members())
    set_enemy_battlers(var.enemies)
    
    hud.load(party_battlers)
    middle_screen.load(enemy_battlers)
end

function battle.update(dt)
end

function battle.draw()
    hud.draw()
    middle_screen.draw()
end

function battle.keypressed(key)
end

return battle