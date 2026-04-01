local battler = require('systems.battler')
local utils = require('helpers.utils')
local transitions = require('systems.transitions')
local enemy_data = require('data.enemy_data')
local middle_screen = require('states.battle.middle_screen')
local hud = require('states.battle.hud')
local logger = require('states.battle.logger')
local menu = require('states.battle.menu')

local battle = {}

local party_battlers = {}
local enemy_battlers = {}
local phase = nil
local fade_in_done = false
local encounter_message_done = false

local function check_intro_done()
    if fade_in_done and encounter_message_done then
        menu.load(party_battlers, enemy_battlers)
        phase = 'menu_input'
    end
end

local function fade_in_callback()
    fade_in_done = true
    check_intro_done()
end

local function encounter_message_callback()
    encounter_message_done = true
    check_intro_done()
end

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

    phase = 'intro'

    transitions.load('fade_in', 0.5, fade_in_callback)
    logger.load('Enemy encountered!', encounter_message_callback)
end

function battle.update(dt)
    if phase == 'intro' then
        transitions.update(dt)
        logger.update(dt)
    end
end

function battle.draw()
    hud.draw()
    middle_screen.draw()
    
    if menu.is_active() then
        menu.draw()
    end

    if logger.is_active() then
        logger.draw()
    end

    if transitions.is_active() then
        transitions.draw()
    end
end

function battle.keypressed(key)
    if phase == 'menu_input' then
        menu.keypressed(key)
    end
end

return battle