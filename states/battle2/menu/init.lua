local mainMenu = require('states.battle2.menu.mainMenu')
local partyMenu = require('states.battle2.menu.partyMenu')
local targetMenu = require('states.battle2.menu.targetMenu')
local skillMenu = require('states.battle2.menu.skillMenu')
local itemMenu = require('states.battle2.menu.itemMenu')

local menu = {}

local state = {}

function menu.load(party, enemies)
    state.marginX = 20
    state.marginY = 20
    state.paddingX = 20
    state.paddingY = 10
    state.width = windowWidth - state.marginX * 2
    state.height = 180
    state.itemHeight = (state.height - state.paddingY * 2) / 4
    state.gap = 10

    state.party = party
    state.enemies = enemies

    state.phase = 'mainMenu'
    state.isActive = true
    mainMenu.load(state)
end

function menu.isActive()
    return state.isActive
end

function menu.update(dt)

    if state.phase == 'mainMenu' then
        local result = mainMenu.getResult()
        if result then
            if result.ref == 'fight' then
                partyMenu.load(state, 1)
                state.phase = 'partyMenu'
            elseif result.ref == 'flee' then
                --to be done--
                state.phase = 'escaping'
            end
        end
    end

    if state.phase == 'partyMenu' then
        local result = partyMenu.getResult()
        if result then
            if result.ref == 'finished' then
                state.isActive = false
            elseif result.ref == 'toMain' then
                mainMenu.load(state)
                state.phase = 'mainMenu'
            elseif result.ref == 'attack' then
                targetMenu.load(state, partyMenu, 'normalAtk', result.battler)
                state.phase = 'targetMenu'
            elseif result.ref == 'chooseSkill' then
                skillMenu.load(state, partyMenu, result.battler)
                state.phase = 'skillMenu'
            elseif result.ref == 'nextBattler' then
                partyMenu.nextBattler(state)
            elseif result.ref == 'chooseItem' then
                itemMenu.load(state, partyMenu, result.battler)
                state.phase = 'itemMenu'
            end
        end
    end

    if state.phase == 'targetMenu' then
        local result = targetMenu.getResult()
        if result then
            if result.ref == 'nextBattler' then
                if result.prevMenu == skillMenu then
                    skillMenu.close()
                elseif result.prevMenu == itemMenu then
                    itemMenu.close()
                end
                partyMenu.nextBattler(state)
                state.phase = 'partyMenu'
            elseif result.ref == 'back' then
                if result.prevMenu == partyMenu then
                    state.phase = 'partyMenu'
                elseif result.prevMenu == skillMenu then
                    skillMenu.cancelTargetting()
                    state.phase = 'skillMenu'
                elseif result.prevMenu == itemMenu then
                    itemMenu.cancelTargetting()
                    state.phase = 'itemMenu'
                end
            end
        end
    end

    if state.phase == 'skillMenu' then
        local result = skillMenu.getResult()
        if result then
            if result.ref == 'back' then
                if result.prevMenu == partyMenu then
                    state.phase = 'partyMenu'
                end
            elseif result.ref == 'nextBattler' then
                partyMenu.nextBattler(state)
                state.phase = 'partyMenu'
            elseif result.ref == 'useSkill' then
                targetMenu.load(state, skillMenu, result.skill, result.battler)
                state.phase = 'targetMenu'
            end
        end
    end

    if state.phase == 'itemMenu' then
        local result = itemMenu.getResult()
        if result then
            if result.ref == 'back' then
                if result.prevMenu == partyMenu then
                    state.phase = 'partyMenu'
                end
            elseif result.ref == 'nextBattler' then
                partyMenu.nextBattler(state)
                state.phase = 'partyMenu'
            elseif result.ref == 'useItem' then
                targetMenu.load(state, itemMenu, result.item, result.battler)
                state.phase = 'targetMenu'
            end
        end
    end
end

function menu.draw()
    if mainMenu.isActive() then mainMenu.draw() end
    if partyMenu.isActive() then partyMenu.draw() end
    if targetMenu.isActive() then targetMenu.draw() end
    if skillMenu.isActive() then skillMenu.draw() end
    if itemMenu.isActive() then itemMenu.draw() end
end

function menu.keypressed(key)
    if state.phase == 'mainMenu' then mainMenu.keypressed(key) end
    if state.phase == 'partyMenu' then partyMenu.keypressed(key) end
    if state.phase == 'targetMenu' then targetMenu.keypressed(key) end
    if state.phase == 'skillMenu' then skillMenu.keypressed(key) end
    if state.phase == 'itemMenu' then itemMenu.keypressed(key) end
end

return menu